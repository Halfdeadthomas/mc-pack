local M = {}

function M.shoot(api)
    api:shootOnce(api:isShootingNeedConsumeAmmo())
end

local function changeMag(api)
    local current_heat = api:getHeatAmount()
    local current_ammo = api:getAmmoAmount()
    if api:hasAmmoInBarrel() then
        current_ammo = current_ammo +1
    end
    local changed_heat = current_ammo
    local changed_ammo = current_heat
    api:setHeatAmount(changed_heat)
    api:setAmmoInBarrel(false)
    api:removeAmmoFromMagazine(api:getAmmoAmount())
    if changed_ammo == 1 then
        api:setAmmoInBarrel(true)
    elseif changed_ammo >1 then
        api:setAmmoInBarrel(true)
        api:putAmmoInMagazine(changed_ammo-1)
    end
end

function M.tick_heat(api, heatTimestamp)
    local cache = api:getCachedScriptData()
     if (cache == nil) then
        cache = {
            reloaded_count = 0,
            needed_count = api:getNeededAmmoAmount(),
            is_tactical = api:getReloadStateType() == TACTICAL_RELOAD_FEEDING,
            interrupted_time = -1,
            ammo = api:getAmmoAmount(),
            mode_init = false,
            mode = BURST
        }   
    end
    api:setOverheatLocked(false)
    if cache.mode_init then
        if not (cache.mode == api:getFireMode()) then
            changeMag(api)
        end
    end
    cache.mode = api:getFireMode()
    cache.mode_init = true
    api:cacheScriptData(cache)
end

function M.start_bolt(api)
    -- Return true to start ticking, since there are nothing needed to be check
    return true
end

function M.tick_bolt(api)
    -- Get total bolt time from script parameter in gun data
    local params = api:getScriptParams()
    local total_bolt_time = params.bolt_time * 1000
    local bolt_feed_time = params.bolt_feed_time * 1000
    if (total_bolt_time == nil or bolt_feed_time == nil) then
        return false
    end
    local bolt_time = api:getBoltTime()
    if (bolt_time < bolt_feed_time) then
        -- Bolt time less than total means we need to keep ticking, return true
        return true
    else
        -- Bolt time greater than total means that the bullet
        -- needs to be put from the magazine into the barrel, and then return false to end ticking.
        if (not api:hasAmmoInBarrel()) then
            if (api:removeAmmoFromMagazine(1) ~= 0) then
                api:setAmmoInBarrel(true);
            end
        end
        return bolt_time < total_bolt_time
    end
end

function M.start_reload(api)
    -- Initialize cache that will be used in reload ticking
    local cache = api:getCachedScriptData()
        cache.reloaded_count = 0
        cache.needed_count = api:getNeededAmmoAmount()
        cache.is_tactical = api:getReloadStateType() == TACTICAL_RELOAD_FEEDING
        cache.interrupted_time = -1
        cache.ammo = api:getAmmoAmount()

    if (not api:hasAmmoInBarrel()) then
        cache.needed_count = cache.needed_count+1
    end
    api:cacheScriptData(cache)
    -- Return true to start ticking
    return true
end

local function getReloadTimingFromParam(param)
    -- Need to convert time from seconds to milliseconds
    local intro_left = param.intro_left * 1000
    local intro_right = param.intro_right * 1000
    local loop = param.loop * 1000
    local ending = param.ending * 1000
    local loop_feed = param.loop_feed * 1000
    -- Check if any timing is nil
    if (intro_left == nil or intro_right == nil or loop == nil or ending == nil or loop_feed == nil) then
        return nil
    end
    return intro_left, intro_right, loop, ending, loop_feed
end

function M.handle_shoot_heat(api)
end

function M.tick_reload(api)
    local ammo_consume = 0
    if api:isReloadingNeedConsumeAmmo() then
        ammo_consume = 1
    end
    local cache = api:getCachedScriptData()
    -- Get all timings from script parameter in gun data
    local param = api:getScriptParams();
    local intro_left, intro_right, loop, ending, loop_feed = getReloadTimingFromParam(param)
    -- Get reload time (The time from the start of reloading to the current time) from api
    local reload_time = api:getReloadTime()
    -- Get cache from api, it will be used to count loaded ammo, mark reload interruptions, etc.
    local interrupted_time = cache.interrupted_time
    -- Handle interrupting reload
    if (interrupted_time ~= -1) then
        local int_time = reload_time - interrupted_time
        if (int_time >= ending) then
            return NOT_RELOADING, -1
        else
            if (cache.is_tactical) then
                return TACTICAL_RELOAD_FINISHING, ending - int_time
            else
                return EMPTY_RELOAD_FINISHING, ending - int_time
            end
        end
    else
        -- if there is no ammo to consume, interrupt reloading
        if (not api:hasAmmoToConsume()) then
            interrupted_time = api:getReloadTime()
        end
    end
    -- Put an ammo into the barrel first
    local reloaded_count = cache.reloaded_count;
    if (reloaded_count <= 0) then
        if (not cache.is_tactical) then
            if (api:getFireMode()==BURST) then
                if (reload_time > loop_feed + intro_left) then
                    reloaded_count = reloaded_count + 1
                end
            else
                if (reload_time > loop_feed + intro_right) then
                    reloaded_count = reloaded_count + 1
                end
            end
        else
            reloaded_count = reloaded_count + 1
        end
    end
    -- Load the ammo into the magazine one by one
    if (reloaded_count > 0) then
        local base_time = (reloaded_count -1) * loop + loop_feed
        if (api:getFireMode()==BURST) then
            base_time = base_time + intro_left
        else
            base_time = base_time + intro_right
        end
        while (base_time < reload_time) do
            if (reloaded_count > cache.needed_count) then
                break
            end
            reloaded_count = reloaded_count + 1
            base_time = base_time + loop
            if (not api:hasAmmoInBarrel()) then
                api:setAmmoInBarrel(true)
            else
                api:putAmmoInMagazine(1)
            end
            api:consumeAmmoFromPlayer(ammo_consume)
        end
    end
    -- Write back cache
    if (reloaded_count > cache.needed_count) then
        interrupted_time = api:getReloadTime() - loop_feed + loop
    end
    cache.interrupted_time = interrupted_time
    cache.reloaded_count = reloaded_count
    api:cacheScriptData(cache)
    -- return reloadstate
    local total_time = cache.needed_count * loop
    if (api:getFireMode()==BURST) then
        total_time = total_time + intro_left
        if (not cache.is_tactical) then
            return EMPTY_RELOAD_FEEDING, total_time - reload_time
        else
            return TACTICAL_RELOAD_FEEDING, total_time - reload_time
        end
    else
        total_time = total_time + intro_right
        if (not cache.is_tactical) then
            return EMPTY_RELOAD_FEEDING, total_time - reload_time
        else
            return TACTICAL_RELOAD_FEEDING, total_time - reload_time
        end
    end
end

function M.interrupt_reload(api)
    local cache = api:getCachedScriptData()
    if (cache ~= nil and cache.interrupted_time == -1) then
        cache.interrupted_time = api:getReloadTime()
    end
end

return M