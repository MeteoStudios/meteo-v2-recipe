const fs = require('fs');
const path = require('path');

const ROOT = GetResourcePath(GetCurrentResourceName());
const IMAGES = path.join(ROOT, 'images');
const DATA = path.join(ROOT, 'data');
const STATUS = path.join(DATA, 'status.json');
const SAFE_KIND = /^[a-z]{2,24}$/;
const SAFE_ID = /^[a-z0-9_\-]{1,64}$/i;

fs.mkdirSync(IMAGES, { recursive: true });
fs.mkdirSync(DATA, { recursive: true });

// opened players; manage re-checked per request
const authorized = new Set();
let gate = null;
on('meteo-imagestudio:server:authorize', (src, manage, key) => {
    gate = { manage, key };
    authorized.add(String(src));
});
on('meteo-imagestudio:server:revoke', (src) => authorized.delete(String(src)));

// role taken away mid-session stops uploads
function allowed(src) {
    if (!gate || !authorized.has(String(src))) return false;
    if (GetResourceState(gate.manage) !== 'started') return false;
    try {
        return exports[gate.manage].HasPermission(Number(src), gate.key) === true;
    } catch {
        return false;
    }
}

function readStatus() {
    try {
        return JSON.parse(fs.readFileSync(STATUS, 'utf8'));
    } catch {
        return {};
    }
}

// what exists on disk for a kind, plus items known to be empty (nothing to draw)
function listKind(kind) {
    const dir = path.join(IMAGES, kind);
    const status = readStatus();
    const out = [];
    const seen = new Set();
    const prefix = `${kind}/`;
    let names = [];
    try {
        names = fs.readdirSync(dir);
    } catch {
        names = [];
    }
    for (const name of names) {
        const m = /^(.+)\.(webp|png)$/i.exec(name);
        if (!m) continue;
        let at = 0, size = 0;
        try {
            const st = fs.statSync(path.join(dir, name));
            at = st.mtimeMs;
            size = st.size;
        } catch { /* gone between readdir and stat */ }
        const s = status[`${kind}/${m[1]}`];
        seen.add(m[1]);
        out.push({ id: m[1], file: name, at, size, issues: (s && s.issues) || [] });
    }
    for (const [key, s] of Object.entries(status)) {
        if (!key.startsWith(prefix) || !s || !s.empty) continue;
        const id = key.slice(prefix.length);
        if (!seen.has(id)) out.push({ id, file: '', at: s.at || 0, size: 0, issues: [], empty: true });
    }
    return out;
}

function markEmpty(data) {
    if (safeMode()) return { ok: false };
    const kind = String(data.kind || '');
    const id = String(data.id || '');
    if (!SAFE_KIND.test(kind) || !SAFE_ID.test(id)) return { ok: false };
    const status = readStatus();
    status[`${kind}/${id}`] = { at: Date.now(), issues: [], empty: true };
    fs.writeFileSync(STATUS, JSON.stringify(status, null, 2));
    return { ok: true };
}

// showcase servers never write
const safeMode = () => GetConvar('meteo:safemode', 'false') === 'true';

function saveImage(data) {
    if (safeMode()) return { ok: false };
    const kind = String(data.kind || '');
    const id = String(data.id || '');
    if (!SAFE_KIND.test(kind) || !SAFE_ID.test(id) || !data.image) return { ok: false };
    const m = String(data.image).match(/^data:image\/(webp|png);base64,(.+)$/);
    if (!m) return { ok: false };
    const dir = path.join(IMAGES, kind);
    fs.mkdirSync(dir, { recursive: true });
    const file = `${id}.${m[1]}`;
    const buffer = Buffer.from(m[2], 'base64');
    fs.writeFileSync(path.join(dir, file), buffer);

    const status = readStatus();
    const issues = Array.isArray(data.issues) ? data.issues.filter((i) => typeof i === 'string').slice(0, 8) : [];
    status[`${kind}/${id}`] = { at: Date.now(), issues };
    fs.writeFileSync(STATUS, JSON.stringify(status, null, 2));
    return { ok: true, id, file, at: Date.now(), size: buffer.length, issues };
}

const handlers = {
    list: (data) => ({ ok: true, items: listKind(SAFE_KIND.test(String(data.kind)) ? String(data.kind) : 'vehicles') }),
    save: saveImage,
    empty: markEmpty,
};

// request/reply: the client waits on the id (uploads arrive as latent events)
onNet('meteo-imagestudio:server:request', (id, name, data) => {
    const src = global.source;
    let result = { ok: false };
    if (handlers[name] && allowed(src)) {
        try {
            result = handlers[name](data || {});
        } catch (err) {
            console.log(`[meteo-imagestudio] ${name} failed: ${err.message}`);
        }
    }
    emitNet('meteo-imagestudio:client:reply', src, id, result);
});
