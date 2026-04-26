local M = {}

function M.tick_heat(api, heatTimestamp)
    local cache = api:getCachedScriptData()
    if (cache == nil) then
        cache = {
            guided = true
        }
    end

    local lock = true
    if (api:getFireMode() == SEMI) then
        if (api:getAimingProgress() >= 0.9) then
            lock = false
        end
    else
        lock = false
    end
    api:setOverheatLocked(lock)

    api:cacheScriptData(cache)
end

function M.shoot(api)
    local cache = api:getCachedScriptData()

    if (api:getFireMode() == SEMI) then
        cache.guided = true
    else
        cache.guided = false
    end
    api:shootOnce(api:isShootingNeedConsumeAmmo())

    api:cacheScriptData(cache)
end

function M.modify_property(api, id, original)
    local cache = api:getCachedScriptData()
    if (id == "ammo_speed") then
        if not(cache.guided) then
            return 1280
        end
    elseif (id == "bullet_life") then
        if not(cache.guided) then
            return 0.1
        end
    end
    return original
end

function M.handle_shoot_heat(api)
end

return M