local M = {}

function M.modify_property(api, id, original)
    local cache = api:getCachedScriptData()
    if (id == "explode_enabled") then
        if api:getAttachment("EXTENDED_MAG") == "zeta:ap_arrow" then
            return false
        end
    elseif (id == "explosion_damage") then
        if api:getAttachment("EXTENDED_MAG") == "zeta:he_arrow" then
            return original * 80
        end
    elseif (id == "explosion_radius") then
        if api:getAttachment("EXTENDED_MAG") == "zeta:pos_arrow" then
            return original * 2
        end
    end
    return original
end

return M