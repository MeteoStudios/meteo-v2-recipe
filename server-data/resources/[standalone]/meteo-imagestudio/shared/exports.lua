-- exports['meteo-imagestudio']:GetImageBase('vehicles') .. 'adder.webp'
exports('GetImageBase', function(folder)
    if type(folder) ~= 'string' or not folder:match('^[a-z]+$') then return nil end
    if Config.imageCdn and Config.imageCdn ~= '' then
        return Config.imageCdn .. folder .. '/'
    end
    return ('https://cfx-nui-%s/images/%s/'):format(GetCurrentResourceName(), folder)
end)
