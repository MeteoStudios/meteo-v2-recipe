"use strict";

var QBRadialMenu = null;
var toggleConfig = false;
var keybindConfig = false;

// Hold-to-open setups only: releasing the key picks whatever is highlighted
// (if nothing is highlighted it just closes, like before).
var SELECT_ON_RELEASE = false;

function isKeybind(e) {
    return keybindConfig && String(e.key).toLowerCase() === String(keybindConfig).toLowerCase();
}

window.addEventListener("message", function (event) {
    var data = event.data || {};
    if (data.action !== "ui") return;

    toggleConfig = data.toggle;
    keybindConfig = data.keybind;

    if (data.radial) {
        createMenu(data.items);
        QBRadialMenu.open();
    } else if (QBRadialMenu) {
        QBRadialMenu.close(true);
    }
});

function createMenu(items) {
    if (QBRadialMenu) QBRadialMenu.destroy();

    QBRadialMenu = new RadialMenu({
        parent: document.body,
        size: 375,
        menuItems: items,
        onClick: function (item) {
            if (item.shouldClose) {
                QBRadialMenu.close(true);
            }

            if (item.items == null && item.shouldClose != null) {
                fetch("https://" + GetParentResourceName() + "/selectItem", {
                    method: "POST",
                    headers: { "Content-Type": "application/json; charset=UTF-8" },
                    body: JSON.stringify({ itemData: item }),
                }).catch(function () {});
            }
        },
    });
}

// Bound once (the old file added a new listener on every open).
document.addEventListener("keyup", function (e) {
    if (!QBRadialMenu || toggleConfig !== false || !isKeybind(e)) return;
    if (SELECT_ON_RELEASE && QBRadialMenu.selectActive()) return;
    QBRadialMenu.close();
});

document.addEventListener("keydown", function (e) {
    if (!QBRadialMenu || e.repeat) return;
    if (e.key === "Escape" || (toggleConfig !== false && isKeybind(e))) {
        QBRadialMenu.close();
    }
});
