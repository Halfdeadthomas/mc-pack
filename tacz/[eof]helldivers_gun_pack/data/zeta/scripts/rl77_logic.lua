local M = {}

function M.tick_heat(api, heatTimestamp)
    local cache = api:getCachedScriptData()
    if cache == nil then
        cache = {
            ammo_type = "none",
            x_spread = 0,
            y_spread = 0,
            ammo_speed = 110,
            delay_time = 0,
            friction = 0,
            counter = 0
        }
    end
    api:cacheScriptData(cache)
end

local function checkGunsmithLibVersion() --检测gunsmith lib版本是否支持允许该脚本
    if GUNSMITHLIB_INSTALLED == nil then
        return false
    end
    if (GUNSMITHLIB_MAJOR_VERSION > 4) then
        return true
    elseif (GUNSMITHLIB_MAJOR_VERSION == 4) and (GUNSMITHLIB_MINOR_VERSION >= 4) then
        return true
    else
        return false
    end
end

function M.shoot(api)
    local cache = api:getCachedScriptData()
    cache.ammo_type = "none"
    cache.counter = 0

    local distance = 62.5
    if checkGunsmithLibVersion() then
        distance = math.min(api:gunsmith_getEstimatedRange(),128)--记录准星对准方向的目标的距离
        if distance == 128 then
            distance = 256
        end
    end
    local distance = math.max(distance - 5, 5)
    local speed = api:getCachedProperty("ammo_speed")
    if speed == nil then
        speed = 80
    end
    cache.delay_time = distance / speed - 0.005
    cache.friction = (speed / distance)*0.05

    local spread_index = 0.1
    cache.x_spread = (math.random()-0.5)*spread_index
    cache.y_spread = (math.random()-0.5)*spread_index
    if api:getAttachment("EXTENDED_MAG") == "zeta:jet" then
        cache.ammo_type = "jet"
        api:shootOnce(api:isShootingNeedConsumeAmmo())
    else
        if (api:getFireMode() == SEMI) then
            cache.ammo_type = "cluster_core"
            api:shootOnce(api:isShootingNeedConsumeAmmo())
            cache.ammo_type = "cluster_shard"
            api:shootOnce(false)
            --cache.ammo_type = "cluster_extra"
            --api:shootOnce(false)
        elseif (api:getFireMode() == BURST) then
            cache.ammo_type = "frag_core"
            api:shootOnce(api:isShootingNeedConsumeAmmo())
            cache.ammo_type = "frag_shard"
            api:shootOnce(false)
        end
    end
    api:cacheScriptData(cache)
end


function M.modify_property(api, id, original)
    local cache = api:getCachedScriptData()
    if (id == "bullet_amount") then
        if (cache.ammo_type == "cluster_shard") then
            return 25
        elseif (cache.ammo_type == "cluster_extra") then
            return 25
        elseif (cache.ammo_type == "cluster_core") then
            return 1
        elseif (cache.ammo_type == "frag_core") then
            return 1
        elseif (cache.ammo_type == "frag_shard") then
            return 25
        elseif (cache.ammo_type == "jet") then
            return 25
        end
    elseif (id == "damage") then
        if (cache.ammo_type == "cluster_shard") then
            return 600
        elseif (cache.ammo_type == "cluster_extra") then
            return 0
        elseif (cache.ammo_type == "cluster_core") then
            return 32
        elseif (cache.ammo_type == "frag_core") then
            return 16
        elseif (cache.ammo_type == "frag_shard") then
            return 600
        elseif (cache.ammo_type == "jet") then
            return 12
        end
    elseif (id == "explosion_radius") then
        if (cache.ammo_type == "cluster_core") then
            return 12
        elseif (cache.ammo_type == "cluster_extra") then
            return 4
        elseif (cache.ammo_type == "cluster_shard") then
            return 5
        elseif (cache.ammo_type == "frag_core") then
            return 16
        elseif (cache.ammo_type == "frag_shard") then
            return 6
        elseif (cache.ammo_type == "jet") then
            return 8
        end
    elseif (id == "explosion_damage") then
        if (cache.ammo_type == "cluster_core") then
            return 48
        elseif (cache.ammo_type == "cluster_extra") then
            return 0
        elseif (cache.ammo_type == "cluster_shard") then
            return 80
        elseif (cache.ammo_type == "frag_core") then
            return 64
        elseif (cache.ammo_type == "frag_shard") then
            return 80
        elseif (cache.ammo_type == "jet") then
            return 40
        end
    elseif (id == "ammo_speed") then
        if (cache.ammo_type == "cluster_core") then
            return original
        elseif (cache.ammo_type == "cluster_extra") then
            return original * 0.9975
        elseif (cache.ammo_type == "cluster_shard") then
            return original * 0.995
        elseif (cache.ammo_type == "frag_shard") then
            return original * 0.999
        elseif (cache.ammo_type == "jet") then
            return original * 0.7
        else
            return original * 8/11
        end
    elseif (id == "bullet_gravity") then
        if (cache.ammo_type == "frag_core") then
            return 0
        elseif (cache.ammo_type == "frag_shard") then
            return 0
        elseif (cache.ammo_type == "jet") then
            return 0.098
        end
    elseif (id == "bullet_friction") then
        if (cache.ammo_type == "frag_core")or(cache.ammo_type == "frag_shard") then
            local friction = cache.friction
            return friction
        elseif (cache.ammo_type == "jet") then
            return 0.001
        end
    elseif (id == "explosion_delay") then
        if (cache.ammo_type == "cluster_core") then
            return 0.375
        elseif (cache.ammo_type == "cluster_extra") then
            return 10
        elseif (cache.ammo_type == "cluster_shard") then
            return 10
        else
            local time = cache.delay_time
            if (cache.ammo_type == "frag_core") then
                return time
            elseif (cache.ammo_type == "frag_shard") then
                cache.counter = cache.counter + 1
                return (time + 0.05 + cache.counter * 0.025)
            end
        end
    elseif (id == "bullet_life") then
        return 10
    end
    return original
end

function M.calcSpread(api,num,spread)
    local cache = api:getCachedScriptData()
    local xspread = 0.08
    if (cache.ammo_type == "cluster_core") then
        xspread = 0
    elseif (cache.ammo_type == "frag_core") then
        xspread = 0
    elseif (cache.ammo_type == "cluster_shard") then
        xspread = 0.06
    elseif (cache.ammo_type == "frag_shard") then
        xspread = 0.04
    elseif (cache.ammo_type == "jet") then
        xspread = 0
    end
    local random_x = (math.random()-0.5)*xspread
    local random_y = (math.random()-0.5)*xspread
    return{cache.x_spread*spread + random_x,cache.y_spread*spread + random_y}
end

return M