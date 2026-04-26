local M = {}

function M.modify_property(api, id, original)
    local cache = api:getCachedScriptData()
    if (id == "bullet_amount") then
        if api:getAttachment("EXTENDED_MAG") == "zeta:jet" then
            return 12
        end
    elseif (id == "explosion_damage") then
        if api:getAttachment("EXTENDED_MAG") == "zeta:jet" then
            return 24
        end
    elseif (id == "ammo_speed") then
        if api:getAttachment("EXTENDED_MAG") == "zeta:jet" then
            return original * 0.8
        end
    elseif (id == "inaccuracy") then
        if api:getAttachment("EXTENDED_MAG") == "zeta:jet" then
            return 0
        end
    end
    return original
end

return M