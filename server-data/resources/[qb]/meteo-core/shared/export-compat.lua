-- Backward compatibility for the resource rename. Do not edit.
-- Aliases every native export under the legacy 'qbx_core' name so other resources (and this
-- resource's own qb bridge, which calls exports.qbx_core:Foo()) keep working after the folder
-- is renamed. This MUST live outside rename.lua because the renamer regenerates rename.lua.
local nativeExports = exports

local function exportHandler(exportName, func)
    nativeExports(exportName, func)
    AddEventHandler(('__cfx_export_%s_%s'):format('qbx_core', exportName), function(setCB)
        setCB(func)
    end)
end

exports = setmetatable({}, {
    __index = function(_, key) return nativeExports[key] end,
    __newindex = function(_, key, value) nativeExports[key] = value end,
    __call = function(_, exportName, func) return exportHandler(exportName, func) end,
})
