/* Northsaga — site behaviour.
   Three jobs only: the menu, the header state, and the scroll reveal. */

(function () {
  'use strict';

  var body = document.body;
  var toggle = document.getElementById('menuToggle');
  var menu = document.getElementById('menu');
  var header = document.getElementById('siteHeader');

  /* ---- Full-screen menu ---- */
  function setMenu(open) {
    body.dataset.menu = open ? 'open' : 'closed';
    toggle.setAttribute('aria-expanded', String(open));
    var label = toggle.querySelector('.menu-label');
    if (label) label.textContent = open ? 'Close' : 'Menu';
    body.style.overflow = open ? 'hidden' : '';
  }

  if (toggle && menu) {
    setMenu(false);
    toggle.addEventListener('click', function () {
      setMenu(body.dataset.menu !== 'open');
    });

    /* Close on link click and on Escape */
    menu.addEventListener('click', function (e) {
      if (e.target.closest('a')) setMenu(false);
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && body.dataset.menu === 'open') {
        setMenu(false);
        toggle.focus();
      }
    });
  }

  /* ---- Header background once scrolled off the hero ---- */
  if (header) {
    var onScroll = function () {
      header.dataset.scrolled = window.scrollY > 40 ? 'true' : 'false';
    };
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
  }

  /* ---- Scroll reveal (skipped entirely if reduced motion is requested) ---- */
  var reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var items = document.querySelectorAll('.reveal');

  if (reduced || !('IntersectionObserver' in window)) {
    items.forEach(function (el) { el.classList.add('is-in'); });
  } else {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        entry.target.classList.add('is-in');
        io.unobserve(entry.target);
      });
    }, { rootMargin: '0px 0px -12% 0px' });

    items.forEach(function (el, i) {
      el.style.transitionDelay = (i % 6) * 60 + 'ms';
      io.observe(el);
    });
  }

  /* ---- Footer year ---- */
  var year = document.getElementById('year');
  if (year) year.textContent = new Date().getFullYear();
})();
