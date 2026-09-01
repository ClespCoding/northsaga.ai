"""Offline test of the service-account JWT assembly and RS256 signing.

Generates a throwaway RSA key, builds the assertion exactly as sheets.py does,
then verifies the signature with openssl and checks the claim set. This covers
everything on the auth path except Google accepting the token — no network, no
real credentials.

    python3 tests/test_sheets.py
"""

import base64
import json
import os
import subprocess
import sys
import tempfile
import time

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import sheets as sheets_mod   # noqa: E402

FAILURES = []


def check(label, got, want):
    if got == want:
        print("  ok   %s" % label)
    else:
        print("  FAIL %s\n       got  %r\n       want %r" % (label, got, want))
        FAILURES.append(label)


def b64url_decode(data):
    return base64.urlsafe_b64decode(data + "=" * (-len(data) % 4))


def main():
    workdir = tempfile.mkdtemp(prefix="nsa-test-")
    key_path = os.path.join(workdir, "key.pem")
    pub_path = os.path.join(workdir, "pub.pem")
    creds_path = os.path.join(workdir, "sa.json")

    print("\ngenerating throwaway RSA key")
    subprocess.run(["openssl", "genrsa", "-out", key_path, "2048"],
                   check=True, capture_output=True)
    subprocess.run(["openssl", "rsa", "-in", key_path, "-pubout", "-out", pub_path],
                   check=True, capture_output=True)
    with open(key_path, encoding="utf-8") as fh:
        private_key = fh.read()
    print("  ok   key generated")

    with open(creds_path, "w", encoding="utf-8") as fh:
        json.dump({
            "type": "service_account",
            "client_email": "887461347076-compute@developer.gserviceaccount.com",
            "private_key": private_key,
        }, fh)

    print("\ncredential loading")
    api = sheets_mod.Sheets(creds_path)
    check("client_email read",
          api.client_email,
          "887461347076-compute@developer.gserviceaccount.com")

    print("\nrejects a non-service-account file")
    bad_path = os.path.join(workdir, "bad.json")
    with open(bad_path, "w", encoding="utf-8") as fh:
        json.dump({"installed": {"client_id": "x"}}, fh)
    try:
        sheets_mod.Sheets(bad_path)
        check("raises SheetsError", False, True)
    except sheets_mod.SheetsError as exc:
        check("raises SheetsError naming the missing field",
              "client_email" in str(exc) or "private_key" in str(exc), True)

    print("\nJWT assembly and RS256 signing")
    now = int(time.time())
    header = {"alg": "RS256", "typ": "JWT"}
    claim = {
        "iss": api.client_email,
        "scope": sheets_mod.SCOPE,
        "aud": sheets_mod.TOKEN_URL,
        "iat": now,
        "exp": now + 3600,
    }
    signing_input = b".".join([
        sheets_mod._b64url(json.dumps(header, separators=(",", ":")).encode()),
        sheets_mod._b64url(json.dumps(claim, separators=(",", ":")).encode()),
    ])
    signature = sheets_mod._sign_rs256(signing_input, private_key)
    check("signature is 2048-bit", len(signature), 256)

    # Verify with openssl — proves it is a real RS256 signature over the input.
    sig_path = os.path.join(workdir, "sig.bin")
    with open(sig_path, "wb") as fh:
        fh.write(signature)
    verify = subprocess.run(
        ["openssl", "dgst", "-sha256", "-verify", pub_path, "-signature", sig_path],
        input=signing_input, capture_output=True)
    check("openssl verifies signature", verify.returncode, 0)

    # A tampered payload must fail verification.
    verify_bad = subprocess.run(
        ["openssl", "dgst", "-sha256", "-verify", pub_path, "-signature", sig_path],
        input=signing_input + b"x", capture_output=True)
    check("tampered input rejected", verify_bad.returncode != 0, True)

    print("\nclaim set")
    decoded = json.loads(b64url_decode(signing_input.split(b".")[1].decode()))
    check("aud is Google token endpoint", decoded["aud"], sheets_mod.TOKEN_URL)
    check("scope is spreadsheets", decoded["scope"],
          "https://www.googleapis.com/auth/spreadsheets")
    check("expiry within an hour", 0 < decoded["exp"] - decoded["iat"] <= 3600, True)
    check("no padding in base64url", b"=" in signing_input, False)

    print("\nkey file cleanup")
    check("no temp key files left behind",
          [f for f in os.listdir(tempfile.gettempdir()) if f.startswith("nsa-sa-")],
          [])

    print("\n%s" % ("FAIL: %d check(s) failed" % len(FAILURES) if FAILURES else "PASS"))
    return 1 if FAILURES else 0


if __name__ == "__main__":
    sys.exit(main())
