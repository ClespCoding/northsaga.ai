/* site.js — vanilla, no dependencies, no build step.

   Three jobs:
     1. the full-screen menu overlay
     2. the mark drawing itself once on load (the site's only orchestrated moment)
     3. quiet reveals on scroll

   prefers-reduced-motion is honoured in CSS; JS only avoids adding work. */

(function () {
  "use strict";

  var root = document.documentElement;
  root.classList.add("js");

  var reduced = window.matchMedia("(prefers-reduced-motion: reduce)");

  /* ------------------------------------------------------------- menu -- */

  var toggle = document.querySelector("[data-menu-toggle]");
  var menu = document.getElementById("menu");

  if (toggle && menu) {
    var lastFocus = null;

    var focusables = function () {
      return menu.querySelectorAll('a[href], button:not([disabled])');
    };

    var setMenu = function (open) {
      menu.setAttribute("data-open", open ? "true" : "false");
      menu.setAttribute("aria-hidden", open ? "false" : "true");
      toggle.setAttribute("aria-expanded", open ? "true" : "false");
      toggle.setAttribute("aria-label", open ? "Close menu" : "Open menu");
      root.classList.toggle("is-menu-open", open);
      document.body.style.overflow = open ? "hidden" : "";

      if (open) {
        lastFocus = document.activeElement;
        var first = focusables()[0];
        if (first) first.focus();
      } else if (lastFocus) {
        lastFocus.focus();
        lastFocus = null;
      }
    };

    var isOpen = function () {
      return menu.getAttribute("data-open") === "true";
    };

    toggle.addEventListener("click", function () {
      setMenu(!isOpen());
    });

    /* Follow a link, then close — cleanUrls means same-page anchors need the
       overlay out of the way before the scroll happens. */
    menu.addEventListener("click", function (e) {
      if (e.target.closest("a")) setMenu(false);
    });

    document.addEventListener("keydown", function (e) {
      if (!isOpen()) return;

      if (e.key === "Escape") {
        setMenu(false);
        return;
      }

      if (e.key !== "Tab") return;

      var items = focusables();
      if (!items.length) return;

      var first = items[0];
      var last = items[items.length - 1];

      if (e.shiftKey && document.activeElement === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    });

    setMenu(false);
  }

  /* ------------------------------------------------------------- mark -- */
  /* The one orchestrated moment. Fires once, on load, and never again. */

  var mark = document.querySelector("[data-mark]");
  if (mark && !reduced.matches) {
    requestAnimationFrame(function () {
      mark.classList.add("mark--draw");
    });
  }

  /* ----------------------------------------------------------- reveal -- */

  var reveals = document.querySelectorAll(".reveal");

  if (!reveals.length) return;

  if (reduced.matches || !("IntersectionObserver" in window)) {
    for (var i = 0; i < reveals.length; i++) reveals[i].classList.add("is-in");
    return;
  }

  var observer = new IntersectionObserver(
    function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        entry.target.classList.add("is-in");
        observer.unobserve(entry.target);
      });
    },
    { rootMargin: "0px 0px -12% 0px", threshold: 0.08 }
  );

  reveals.forEach(function (el) {
    observer.observe(el);
  });
})();
