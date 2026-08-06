/* Northsaga — schematic zoom.

   A drawing is fitted to the viewport width by CSS, so the whole shape is
   visible at rest on any screen. That makes the type small on a phone, which
   is the trade this script pays for: fit first, then let the reader zoom in.

   One job only. If this file fails to load, the drawing is still complete and
   still scrollable — you just do not get the controls.

   Zoom is a width on the stage, not a transform, so the SVG re-renders at the
   new size and stays sharp. The viewport scrolls, so panning is native on
   touch and needs no code.  */

(function () {
  'use strict';

  var STEPS = [1, 1.5, 2, 3, 4];
  var figures = document.querySelectorAll('.schematic');
  if (!figures.length) return;

  function nearest(z) {
    var best = 0;
    for (var i = 1; i < STEPS.length; i++) {
      if (Math.abs(STEPS[i] - z) < Math.abs(STEPS[best] - z)) best = i;
    }
    return best;
  }

  figures.forEach(function (fig) {
    var viewport = fig.querySelector('.schematic-viewport');
    var stage = fig.querySelector('.schematic-stage');
    var caption = fig.querySelector('figcaption');
    if (!viewport || !stage) return;

    /* The drawing's own width, from the inline --sch-w the generator writes. */
    var intrinsic = parseFloat(stage.style.getPropertyValue('--sch-w')) || 0;
    var index = 0;

    /* ---- controls ---- */
    var bar = document.createElement('div');
    bar.className = 'schematic-controls';
    bar.innerHTML =
      '<button type="button" class="sch-btn" data-zoom="out" aria-label="Zoom out">' +
      '<span aria-hidden="true">−</span></button>' +
      '<span class="sch-level" role="status">100%</span>' +
      '<button type="button" class="sch-btn" data-zoom="in" aria-label="Zoom in">' +
      '<span aria-hidden="true">+</span></button>' +
      '<button type="button" class="sch-btn sch-btn--text" data-zoom="fit">Fit</button>' +
      '<span class="sch-hint">Pinch or scroll to move around</span>';

    fig.insertBefore(bar, caption);

    var level = bar.querySelector('.sch-level');
    var outBtn = bar.querySelector('[data-zoom="out"]');
    var inBtn = bar.querySelector('[data-zoom="in"]');

    /* Set the zoom, keeping whatever was in the middle of the viewport in the
       middle of it. Without this, zooming in on a wide drawing throws the
       reader back to the left-hand edge every time. */
    function apply(next, originX, originY) {
      next = Math.max(0, Math.min(STEPS.length - 1, next));
      if (next === index) return;

      var before = STEPS[index];
      var after = STEPS[next];
      var ox = originX === undefined ? viewport.clientWidth / 2 : originX;
      var oy = originY === undefined ? viewport.clientHeight / 2 : originY;
      var fx = (viewport.scrollLeft + ox) / before;
      var fy = (viewport.scrollTop + oy) / before;

      index = next;
      stage.style.width = after === 1
        ? ''
        : 'min(' + (after * 100) + '%, ' + (intrinsic * after) + 'px)';

      viewport.scrollLeft = fx * after - ox;
      viewport.scrollTop = fy * after - oy;

      level.textContent = Math.round(after * 100) + '%';
      fig.dataset.zoomed = after > 1 ? 'true' : 'false';
      outBtn.disabled = index === 0;
      inBtn.disabled = index === STEPS.length - 1;
    }

    outBtn.disabled = true;

    bar.addEventListener('click', function (e) {
      var btn = e.target.closest('[data-zoom]');
      if (!btn) return;
      var dir = btn.dataset.zoom;
      apply(dir === 'in' ? index + 1 : dir === 'out' ? index - 1 : 0);
    });

    /* ---- trackpad pinch and ctrl+wheel ---- */
    viewport.addEventListener('wheel', function (e) {
      if (!e.ctrlKey) return;              /* a plain wheel still scrolls */
      e.preventDefault();
      var rect = viewport.getBoundingClientRect();
      apply(index + (e.deltaY < 0 ? 1 : -1),
            e.clientX - rect.left, e.clientY - rect.top);
    }, { passive: false });

    /* ---- two-finger pinch ----
       Only while two fingers are down, so a one-finger drag still scrolls the
       viewport natively and the page still scrolls past the drawing. */
    var startDist = 0;
    var startZoom = 1;

    function spread(t) {
      var dx = t[0].clientX - t[1].clientX;
      var dy = t[0].clientY - t[1].clientY;
      return Math.sqrt(dx * dx + dy * dy);
    }

    viewport.addEventListener('touchstart', function (e) {
      if (e.touches.length !== 2) return;
      startDist = spread(e.touches);
      startZoom = STEPS[index];
    }, { passive: true });

    viewport.addEventListener('touchmove', function (e) {
      if (e.touches.length !== 2 || !startDist) return;
      e.preventDefault();
      var rect = viewport.getBoundingClientRect();
      var cx = (e.touches[0].clientX + e.touches[1].clientX) / 2 - rect.left;
      var cy = (e.touches[0].clientY + e.touches[1].clientY) / 2 - rect.top;
      apply(nearest(startZoom * (spread(e.touches) / startDist)), cx, cy);
    }, { passive: false });

    viewport.addEventListener('touchend', function () { startDist = 0; });

    /* ---- drag to pan, mouse only ---- */
    var dragging = false;
    var lastX = 0;
    var lastY = 0;

    viewport.addEventListener('pointerdown', function (e) {
      if (e.pointerType !== 'mouse' || fig.dataset.zoomed !== 'true') return;
      dragging = true;
      lastX = e.clientX;
      lastY = e.clientY;
      viewport.setPointerCapture(e.pointerId);
    });

    viewport.addEventListener('pointermove', function (e) {
      if (!dragging) return;
      viewport.scrollLeft -= e.clientX - lastX;
      viewport.scrollTop -= e.clientY - lastY;
      lastX = e.clientX;
      lastY = e.clientY;
    });

    viewport.addEventListener('pointerup', function () { dragging = false; });
    viewport.addEventListener('pointercancel', function () { dragging = false; });

    /* ---- double click or double tap toggles fit and 200% ---- */
    viewport.addEventListener('dblclick', function (e) {
      var rect = viewport.getBoundingClientRect();
      apply(index === 0 ? 2 : 0, e.clientX - rect.left, e.clientY - rect.top);
    });
  });
})();
