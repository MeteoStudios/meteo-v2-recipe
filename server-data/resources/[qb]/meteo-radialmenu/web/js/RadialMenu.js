"use strict";

/*
 * RadialMenu — ring of rounded segments with a centre hub.
 *
 * Same public surface as before:
 *   var m = new RadialMenu({ parent, menuItems, onClick });
 *   m.open();  m.close(immediate);
 *
 * Extra options (all optional):
 *   minSegments  pad the ring with blank segments up to this count (default 5, 0 = never pad)
 *   hubAction    centre hub closes / goes back on click            (default true)
 *   rightClickBack  right mouse button goes back one level         (default true)
 *
 * Item shape is unchanged: { id, title, icon, items?, shouldClose?, ... }
 *   icon: Material Icons name ("directions_car"), an inline "<svg ...>" string,
 *         or an image path ending in .png / .svg / .webp
 */

(function (global) {
    var SVG_NS = "http://www.w3.org/2000/svg";
    var TAU = Math.PI * 2;

    /* Geometry, in px of the 500 x 500 design box */
    var G = {
        box: 500,
        c: 250,
        outer: 206,     // ring outer radius
        inner: 112,     // ring inner radius
        gap: 4,         // parallel gap between segments
        corner: 9,      // segment corner radius
        hub: 90,        // hub radius
        needle: 101,    // needle arc radius (sits between hub and ring)
        reach: 44,      // how far outside the ring the cursor still selects
        push: 6         // how far the active segment moves outward
    };

    var T_FAST = 120;

    /* ------------------------------------------------------------------ */
    /* helpers                                                             */
    /* ------------------------------------------------------------------ */

    function post(endpoint, data) {
        if (typeof global.GetParentResourceName !== "function") return;
        try {
            fetch("https://" + global.GetParentResourceName() + "/" + endpoint, {
                method: "POST",
                headers: { "Content-Type": "application/json; charset=UTF-8" },
                body: JSON.stringify(data || {})
            }).catch(function () {});
        } catch (e) { /* not inside NUI */ }
    }

    function svgEl(name, attrs) {
        var el = document.createElementNS(SVG_NS, name);
        for (var k in attrs) el.setAttribute(k, attrs[k]);
        return el;
    }

    function pt(radius, angle) {
        return (G.c + radius * Math.cos(angle)).toFixed(2) + " " + (G.c + radius * Math.sin(angle)).toFixed(2);
    }

    /* Annular sector between a0..a1 with a constant-width gap on both sides.
       Drawn inset by the corner radius; a same-colour round-join stroke of
       2 x corner then gives true rounded corners without any path maths. */
    function segmentPath(a0, a1, full) {
        var k = G.corner;
        var R = G.outer - k;
        var r = G.inner + k;

        if (full) {
            return "M" + pt(R, 0) + "A" + R + " " + R + " 0 1 1 " + pt(R, Math.PI) +
                   "A" + R + " " + R + " 0 1 1 " + pt(R, 0) + "Z" +
                   "M" + pt(r, 0) + "A" + r + " " + r + " 0 1 0 " + pt(r, Math.PI) +
                   "A" + r + " " + r + " 0 1 0 " + pt(r, 0) + "Z";
        }

        var d = G.gap / 2 + k;
        var oR = Math.asin(d / R);
        var oR2 = Math.asin(d / r);
        var largeOuter = (a1 - a0 - 2 * oR) > Math.PI ? 1 : 0;
        var largeInner = (a1 - a0 - 2 * oR2) > Math.PI ? 1 : 0;

        return "M" + pt(R, a0 + oR) +
               "A" + R + " " + R + " 0 " + largeOuter + " 1 " + pt(R, a1 - oR) +
               "L" + pt(r, a1 - oR2) +
               "A" + r + " " + r + " 0 " + largeInner + " 0 " + pt(r, a0 + oR2) + "Z";
    }

    function arcPath(radius, a0, a1) {
        return "M" + pt(radius, a0) + "A" + radius + " " + radius + " 0 " +
               ((a1 - a0) > Math.PI ? 1 : 0) + " 1 " + pt(radius, a1);
    }

    function iconMarkup(icon) {
        icon = icon == null ? "" : String(icon).trim();
        if (icon.charAt(0) === "<") return icon;                              // inline svg
        if (/\.(png|svg|webp|jpe?g|gif)$/i.test(icon)) {
            return '<img src="' + icon.replace(/"/g, "&quot;") + '" alt="">';
        }
        var i = document.createElement("i");
        i.className = "material-icons-round";
        i.textContent = icon || "help";
        return i.outerHTML;
    }

    /* ------------------------------------------------------------------ */
    /* constructor                                                         */
    /* ------------------------------------------------------------------ */

    function RadialMenu(params) {
        params = params || {};
        this.parent = params.parent || document.body;
        this.size = params.size || 375;                 // kept for compatibility
        this.onClick = params.onClick || null;
        this.menuItems = params.menuItems || [];
        this.minSegments = params.minSegments != null ? params.minSegments : 5;
        this.hubAction = params.hubAction !== false;
        this.rightClickBack = params.rightClickBack !== false;

        this.container = null;
        this.currentMenu = null;    // root element while open
        this.menuStack = [];
        this.items = [];            // items of the level on screen
        this.slots = [];            // items + blank fillers
        this.segEls = [];
        this.iconEls = [];
        this.active = -1;           // -1 none, -2 hub, >= 0 segment index
        this.locked = false;
        this.mouse = null;

        this._needle = { cur: 0, target: 0, raf: 0, last: 0, visible: false };
        this._timers = [];

        this._onMove = this._onMove.bind(this);
        this._onDown = this._onDown.bind(this);
        this._onUp = this._onUp.bind(this);
        this._onClick = this._onClick.bind(this);
        this._onContext = this._onContext.bind(this);
        this._onResize = this._onResize.bind(this);
        this._tick = this._tick.bind(this);

        this.init();
    }

    RadialMenu.prototype.init = function () {
        this.container = document.getElementById("radial-container");
        if (!this.container) {
            this.container = document.createElement("div");
            this.container.id = "radial-container";
            this.parent.appendChild(this.container);
        }
    };

    /* ------------------------------------------------------------------ */
    /* open / close                                                        */
    /* ------------------------------------------------------------------ */

    RadialMenu.prototype.open = function () {
        if (this.currentMenu) return;

        var root = document.createElement("div");
        root.className = "radial-menu";
        root.dataset.dir = "in";
        root.style.setProperty("--hub", G.hub * 2 + "px");

        root.innerHTML =
            '<div class="rm-stage">' +
                '<div class="rm-ring">' +
                    '<svg class="rm-svg" viewBox="0 0 500 500" aria-hidden="true"><g class="rm-segs"></g></svg>' +
                    '<div class="rm-icons"></div>' +
                '</div>' +
                '<svg class="rm-svg" viewBox="0 0 500 500" aria-hidden="true"><g class="rm-needle"><path/></g></svg>' +
                '<div class="rm-hub">' +
                    '<div class="rm-hub-icon">' +
                        '<svg class="rm-ico-close" viewBox="0 0 24 24"><path d="M6 6l12 12M18 6L6 18"/></svg>' +
                        '<svg class="rm-ico-back" viewBox="0 0 24 24"><path d="M20 12H5M11 5.5L4.5 12l6.5 6.5"/></svg>' +
                    '</div>' +
                    '<div class="rm-hub-label"></div>' +
                '</div>' +
            '</div>';

        this.currentMenu = root;
        this.ringEl = root.querySelector(".rm-ring");
        this.segsEl = root.querySelector(".rm-segs");
        this.iconsEl = root.querySelector(".rm-icons");
        this.needleEl = root.querySelector(".rm-needle");
        this.hubEl = root.querySelector(".rm-hub");
        this.labelEl = root.querySelector(".rm-hub-label");

        this.menuStack = [];
        this.items = this.menuItems;
        this._renderRing(this.items);

        this.container.appendChild(root);
        this._onResize();
        this._bind(true);

        var self = this;
        requestAnimationFrame(function () {
            if (self.currentMenu === root) root.classList.add("is-open");
        });
    };

    RadialMenu.prototype.close = function (immediate) {
        if (!this.currentMenu) return;

        // Notify FiveM (same payload as before)
        post("closeRadial", { delay: immediate });

        this.menuStack = [];

        if (immediate) {
            this.removeCurrentMenu();
        } else {
            var self = this;
            var root = this.currentMenu;
            this._bind(false);
            this._setActive(-1);
            root.classList.remove("is-open");
            this._later(function () {
                if (self.currentMenu === root) self.removeCurrentMenu();
            }, T_FAST + 20);
        }
    };

    /* Remove from the DOM without telling the game (used when rebuilding). */
    RadialMenu.prototype.destroy = function () {
        this.removeCurrentMenu();
    };

    RadialMenu.prototype.removeCurrentMenu = function () {
        this._bind(false);
        this._timers.forEach(clearTimeout);
        this._timers = [];
        cancelAnimationFrame(this._needle.raf);
        this._needle.raf = 0;
        document.body.classList.remove("rm-can-click");
        if (this.currentMenu && this.currentMenu.parentNode) {
            this.currentMenu.parentNode.removeChild(this.currentMenu);
        }
        this.currentMenu = null;
        this.active = -1;
        this.locked = false;
    };

    /* ------------------------------------------------------------------ */
    /* ring                                                                */
    /* ------------------------------------------------------------------ */

    RadialMenu.prototype.padItemsToMinimum = function (items, minimum) {
        var result = (items || []).slice();
        while (result.length < minimum) {
            result.push({ id: "dummy-" + result.length, title: "", isDummy: true });
        }
        return result;
    };

    RadialMenu.prototype._renderRing = function (items) {
        var slots = this.padItemsToMinimum(items, Math.max(this.minSegments, 1));
        var n = slots.length;
        var step = TAU / n;
        var iconSize = n <= 8 ? 36 : n <= 12 ? 30 : n <= 16 ? 24 : 20;
        var iconRadius = (G.outer + G.inner) / 2;

        this.slots = slots;
        this.step = step;
        this.segEls = [];
        this.iconEls = [];
        this.segsEl.textContent = "";
        this.iconsEl.textContent = "";

        for (var i = 0; i < n; i++) {
            var item = slots[i];
            var mid = -Math.PI / 2 + i * step;          // item 0 sits at the top
            var cos = Math.cos(mid), sin = Math.sin(mid);
            var px = (cos * G.push).toFixed(2) + "px";
            var py = (sin * G.push).toFixed(2) + "px";

            /* segment */
            var g = svgEl("g", { "class": "rm-seg" + (item.isDummy ? " is-empty" : "") });
            g.style.setProperty("--i", i);
            g.style.setProperty("--px", px);
            g.style.setProperty("--py", py);
            g.setAttribute("data-item-id", item.id);

            var shape = svgEl("path", {
                "class": "rm-seg-shape",
                d: segmentPath(mid - step / 2, mid + step / 2, n === 1),
                "fill-rule": "evenodd",
                "stroke-width": G.corner * 2
            });
            g.appendChild(shape);

            if (item.items && item.items.length) {
                /* small solid outward arrow at the rim = "opens another ring" */
                var rm = G.outer - 15;
                var tip = [G.c + cos * (rm + 4), G.c + sin * (rm + 4)];
                var bx = G.c + cos * (rm - 2), by = G.c + sin * (rm - 2);
                g.appendChild(svgEl("path", {
                    "class": "rm-seg-more",
                    d: "M" + (bx + sin * 5).toFixed(2) + " " + (by - cos * 5).toFixed(2) +
                       "L" + tip[0].toFixed(2) + " " + tip[1].toFixed(2) +
                       "L" + (bx - sin * 5).toFixed(2) + " " + (by + cos * 5).toFixed(2) + "Z"
                }));
            }

            this.segsEl.appendChild(g);
            this.segEls.push(g);

            /* icon */
            if (item.isDummy) {
                this.iconEls.push(null);
                continue;
            }
            var ic = document.createElement("div");
            ic.className = "rm-icon";
            ic.style.left = (G.c + cos * iconRadius).toFixed(2) + "px";
            ic.style.top = (G.c + sin * iconRadius).toFixed(2) + "px";
            ic.style.setProperty("--s", iconSize + "px");
            ic.style.setProperty("--i", i);
            ic.style.setProperty("--px", px);
            ic.style.setProperty("--py", py);
            ic.style.setProperty("--vx", (cos * iconRadius).toFixed(1));
            ic.style.setProperty("--vy", (sin * iconRadius).toFixed(1));
            ic.innerHTML = iconMarkup(item.icon);
            this.iconsEl.appendChild(ic);
            this.iconEls.push(ic);
        }

        /* needle spans ~half a segment, capped */
        var span = Math.min(step * 0.5, 0.62);
        this.needleEl.firstChild.setAttribute("d", arcPath(G.needle, -Math.PI / 2 - span / 2, -Math.PI / 2 + span / 2));

        this.currentMenu.classList.toggle("is-sub", this.menuStack.length > 0);
        this.active = -1;
    };

    RadialMenu.prototype._swapRing = function (items, dir) {
        var self = this;
        var root = this.currentMenu;
        this.locked = true;
        this._setActive(-1);
        root.dataset.dir = dir;
        root.classList.toggle("is-sub", this.menuStack.length > 0);
        this.ringEl.classList.add("is-leaving");

        this._later(function () {
            if (self.currentMenu !== root) return;
            self.items = items;
            self._renderRing(items);
            self.ringEl.classList.remove("is-leaving");
            self.locked = false;
            if (self.mouse) self._hit(self.mouse.x, self.mouse.y);
        }, T_FAST);
    };

    RadialMenu.prototype.openSubMenu = function (parentItem) {
        this.menuStack.push({ items: this.items, parent: parentItem });
        this._swapRing(parentItem.items, "in");
    };

    RadialMenu.prototype.goBack = function () {
        if (this.menuStack.length === 0 || this.locked) return;
        var previous = this.menuStack.pop();
        this._swapRing(previous.items, "out");
    };

    /* ------------------------------------------------------------------ */
    /* interaction                                                         */
    /* ------------------------------------------------------------------ */

    RadialMenu.prototype.handleItemClick = function (item) {
        post("playSound", {});

        if (item.items && item.items.length > 0) {
            this.openSubMenu(item);
        } else if (this.onClick) {
            this.onClick(item);
        }
    };

    /* Activate whatever is under the cursor. Returns true if something fired.
       Handy for "release the key to select" setups. */
    RadialMenu.prototype.selectActive = function () {
        if (!this.currentMenu || this.locked) return false;
        if (this.active >= 0) {
            this.handleItemClick(this.slots[this.active]);
            return true;
        }
        if (this.active === -2 && this.hubAction) {
            post("playSound", {});
            if (this.menuStack.length) this.goBack(); else this.close();
            return true;
        }
        return false;
    };

    RadialMenu.prototype.setCenterText = function (text) {
        if (!this.currentMenu) return;
        if (text) this.labelEl.textContent = text;
        this.currentMenu.classList.toggle("has-label", !!text);
    };

    RadialMenu.prototype._hit = function (x, y) {
        if (!this.currentMenu || this.locked) return;
        var dx = (x - this._cx) / this._scale;
        var dy = (y - this._cy) / this._scale;
        var dist = Math.sqrt(dx * dx + dy * dy);
        var idx = -1;

        if (dist <= G.hub + 3) {
            idx = this.hubAction ? -2 : -1;
        } else if (dist <= G.outer + G.reach) {
            var a = Math.atan2(dy, dx) + Math.PI / 2 + this.step / 2;
            a = ((a % TAU) + TAU) % TAU;
            idx = Math.floor(a / this.step) % this.slots.length;
            if (this.slots[idx].isDummy) idx = -1;
        }
        this._setActive(idx);
    };

    RadialMenu.prototype._setActive = function (idx) {
        if (idx === this.active) return;
        var prev = this.active;
        this.active = idx;

        if (prev >= 0) this._mark(prev, "is-active", false), this._mark(prev, "is-pressed", false);
        if (prev === -2) this.hubEl.classList.remove("is-active", "is-pressed");

        if (idx >= 0) {
            this._mark(idx, "is-active", true);
            var item = this.slots[idx];
            this.setCenterText(item.title || item.id);
            this._aimNeedle(idx * (360 / this.slots.length), prev < 0);
        } else {
            this.setCenterText("");
            this._showNeedle(false);
            if (idx === -2) this.hubEl.classList.add("is-active");
        }

        document.body.classList.toggle("rm-can-click", idx !== -1);
    };

    RadialMenu.prototype._mark = function (i, cls, on) {
        if (this.segEls[i]) this.segEls[i].classList.toggle(cls, on);
        if (this.iconEls[i]) this.iconEls[i].classList.toggle(cls, on);
    };

    RadialMenu.prototype._onMove = function (e) {
        this.mouse = { x: e.clientX, y: e.clientY };
        this._hit(e.clientX, e.clientY);
    };

    RadialMenu.prototype._onDown = function (e) {
        if (e.button !== 0) return;
        this._onMove(e);
        if (this.active >= 0) this._mark(this.active, "is-pressed", true);
        if (this.active === -2) this.hubEl.classList.add("is-pressed");
    };

    RadialMenu.prototype._onUp = function () {
        if (this.active >= 0) this._mark(this.active, "is-pressed", false);
        this.hubEl.classList.remove("is-pressed");
    };

    RadialMenu.prototype._onClick = function (e) {
        if (e.button !== 0) return;
        this._onMove(e);
        if (this.active === -1) return;
        e.preventDefault();
        this.selectActive();
    };

    RadialMenu.prototype._onContext = function (e) {
        e.preventDefault();
        if (!this.rightClickBack || !this.menuStack.length || this.locked) return;
        post("playSound", {});
        this.goBack();
    };

    RadialMenu.prototype._onResize = function () {
        if (!this.currentMenu) return;
        var scale = Math.max(0.8, Math.min(1.8, window.innerHeight / 1080));
        this.currentMenu.style.setProperty("--rm-scale", scale.toFixed(3));
        var host = this.container.getBoundingClientRect();
        var cs = getComputedStyle(this.currentMenu);
        this._cx = host.left + parseFloat(cs.left);
        this._cy = host.top + parseFloat(cs.top);
        this._scale = scale;
    };

    RadialMenu.prototype._bind = function (on) {
        var fn = on ? "addEventListener" : "removeEventListener";
        document[fn]("mousemove", this._onMove);
        document[fn]("mousedown", this._onDown);
        document[fn]("mouseup", this._onUp);
        document[fn]("click", this._onClick);
        document[fn]("contextmenu", this._onContext);
        window[fn]("resize", this._onResize);
    };

    RadialMenu.prototype._later = function (fn, ms) {
        this._timers.push(setTimeout(fn, ms));
    };

    /* ------------------------------------------------------------------ */
    /* needle — damped per frame, shortest way round                       */
    /* ------------------------------------------------------------------ */

    RadialMenu.prototype._aimNeedle = function (deg, snap) {
        var n = this._needle;
        n.target = deg;
        if (snap || !n.visible) {
            n.cur = deg;
            this.needleEl.style.transform = "rotate(" + deg.toFixed(2) + "deg)";
        }
        this._showNeedle(true);
        if (!n.raf && n.cur !== n.target) {
            n.last = performance.now();
            n.raf = requestAnimationFrame(this._tick);
        }
    };

    RadialMenu.prototype._showNeedle = function (on) {
        this._needle.visible = on;
        this.needleEl.classList.toggle("is-visible", on);
    };

    RadialMenu.prototype._tick = function (now) {
        var n = this._needle;
        var dt = Math.min((now - n.last) / 1000, 0.05);
        n.last = now;
        var diff = ((n.target - n.cur) % 360 + 540) % 360 - 180;

        if (Math.abs(diff) < 0.08) {
            n.cur = n.target;
            n.raf = 0;
        } else {
            n.cur += diff * (1 - Math.exp(-dt * 24));
            n.raf = requestAnimationFrame(this._tick);
        }
        this.needleEl.style.transform = "rotate(" + n.cur.toFixed(2) + "deg)";
    };

    /* ------------------------------------------------------------------ */
    /* statics kept for compatibility                                      */
    /* ------------------------------------------------------------------ */

    RadialMenu.nextTick = function (callback) {
        setTimeout(callback, 0);
    };

    RadialMenu.setClassAndWaitForTransition = function (element, className) {
        return new Promise(function (resolve) {
            element.className = className;
            setTimeout(resolve, 300);
        });
    };

    /* Warm the fonts so the first open never flashes ligature text. */
    if (document.fonts && document.fonts.load) {
        ['30px "Material Icons Round"', '600 17px "Clash Display"'].forEach(function (f) {
            document.fonts.load(f, f.indexOf("Icons") > -1 ? "help" : "A").catch(function () {});
        });
    }

    global.RadialMenu = RadialMenu;
})(window);
