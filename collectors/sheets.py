"""Minimal Google Sheets v4 client using a service-account key.

Standard library plus the `openssl` binary. No google-auth, no gspread, no pip
install — which means the container this runs in stays a plain python:3-slim
with nothing to keep patched.

The only thing openssl does is RS256-sign the JWT assertion, because Python's
standard library cannot do RSA signing. Everything else is urllib and json.

The service account must be an Editor on the target spreadsheet. For the
Broadland sheet that is already true:
    887461347076-compute@developer.gserviceaccount.com
"""

import base64
import json
import os
import subprocess
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request

TOKEN_URL = "https://oauth2.googleapis.com/token"
SHEETS_API = "https://sheets.googleapis.com/v4/spreadsheets"
SCOPE = "https://www.googleapis.com/auth/spreadsheets"
JWT_GRANT = "urn:ietf:params:oauth:grant-type:jwt-bearer"


class SheetsError(RuntimeError):
    pass


def _b64url(raw):
    return base64.urlsafe_b64encode(raw).rstrip(b"=")


def _sign_rs256(message, private_key_pem):
    """RSA-SHA256 signature via openssl. Returns raw signature bytes."""
    key_file = None
    try:
        fd, key_file = tempfile.mkstemp(prefix="nsa-sa-", suffix=".pem")
        os.fchmod(fd, 0o600)
        with os.fdopen(fd, "w") as fh:
            fh.write(private_key_pem)
        proc = subprocess.run(
            ["openssl", "dgst", "-sha256", "-sign", key_file],
            input=message, capture_output=True, check=False,
        )
        if proc.returncode != 0:
            raise SheetsError("openssl signing failed: %s"
                              % proc.stderr.decode("utf-8", "replace").strip())
        return proc.stdout
    finally:
        if key_file and os.path.exists(key_file):
            os.unlink(key_file)


class Sheets:
    def __init__(self, credentials_path, timeout=45):
        with open(credentials_path, "r", encoding="utf-8") as fh:
            self.creds = json.load(fh)
        for required in ("client_email", "private_key"):
            if required not in self.creds:
                raise SheetsError(
                    "%s is missing %r — is it a service-account key?"
                    % (credentials_path, required))
        self.timeout = timeout
        self._token = None
        self._token_expiry = 0

    @property
    def client_email(self):
        return self.creds["client_email"]

    # --- auth ---
    def _access_token(self):
        if self._token and time.time() < self._token_expiry - 60:
            return self._token

        now = int(time.time())
        header = {"alg": "RS256", "typ": "JWT"}
        claim = {
            "iss": self.creds["client_email"],
            "scope": SCOPE,
            "aud": TOKEN_URL,
            "iat": now,
            "exp": now + 3600,
        }
        signing_input = b".".join([
            _b64url(json.dumps(header, separators=(",", ":")).encode()),
            _b64url(json.dumps(claim, separators=(",", ":")).encode()),
        ])
        signature = _sign_rs256(signing_input, self.creds["private_key"])
        assertion = signing_input + b"." + _b64url(signature)

        body = urllib.parse.urlencode(
            {"grant_type": JWT_GRANT, "assertion": assertion.decode()}).encode()
        req = urllib.request.Request(
            TOKEN_URL, data=body,
            headers={"Content-Type": "application/x-www-form-urlencoded"})
        try:
            with urllib.request.urlopen(req, timeout=self.timeout) as resp:
                payload = json.loads(resp.read().decode())
        except urllib.error.HTTPError as exc:
            detail = exc.read().decode("utf-8", "replace")[:400]
            raise SheetsError("token request failed (HTTP %s): %s"
                              % (exc.code, detail)) from exc

        self._token = payload["access_token"]
        self._token_expiry = now + int(payload.get("expires_in", 3600))
        return self._token

    # --- api ---
    def _call(self, method, path, params=None, body=None):
        url = "%s/%s" % (SHEETS_API, path.lstrip("/"))
        if params:
            url += "?" + urllib.parse.urlencode(params)
        data = json.dumps(body).encode() if body is not None else None
        req = urllib.request.Request(url, data=data, method=method)
        req.add_header("Authorization", "Bearer " + self._access_token())
        if data:
            req.add_header("Content-Type", "application/json")
        try:
            with urllib.request.urlopen(req, timeout=self.timeout) as resp:
                return json.loads(resp.read().decode() or "{}")
        except urllib.error.HTTPError as exc:
            detail = exc.read().decode("utf-8", "replace")[:500]
            raise SheetsError("%s %s failed (HTTP %s): %s"
                              % (method, url, exc.code, detail)) from exc

    def check_auth(self, spreadsheet_id):
        """Confirm the key works AND can see the spreadsheet. Returns title."""
        meta = self._call("GET", spreadsheet_id,
                          params={"fields": "properties.title,sheets.properties.title"})
        tabs = [s["properties"]["title"] for s in meta.get("sheets", [])]
        return meta["properties"]["title"], tabs

    def read_column(self, spreadsheet_id, tab, column="A"):
        """Every value in one column, header included."""
        rng = "%s!%s:%s" % (tab, column, column)
        got = self._call("GET", "%s/values/%s" % (spreadsheet_id, urllib.parse.quote(rng)))
        return [r[0] if r else "" for r in got.get("values", [])]

    def read_header(self, spreadsheet_id, tab):
        rng = "%s!1:1" % tab
        got = self._call("GET", "%s/values/%s" % (spreadsheet_id, urllib.parse.quote(rng)))
        rows = got.get("values", [])
        return rows[0] if rows else []

    def append_rows(self, spreadsheet_id, tab, rows):
        """Append rows below the last populated row. Returns rows added."""
        if not rows:
            return 0
        rng = "%s!A:A" % tab
        self._call(
            "POST", "%s/values/%s:append" % (spreadsheet_id, urllib.parse.quote(rng)),
            params={"valueInputOption": "RAW",
                    "insertDataOption": "INSERT_ROWS"},
            body={"values": rows},
        )
        return len(rows)
