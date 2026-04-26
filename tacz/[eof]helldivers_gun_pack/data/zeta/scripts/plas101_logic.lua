--foxatl
local M = {}
local max = 20  -- 满蓄力进度需求
local step =1 -- 一次伪射击进度增幅
local edge =50 --宽限，松手多久时触发，单位ms
local spread_index = 0.125 --扩散参数 调节此参数可改变综合射击准度（数据内部的不准确度依然生效）

function M.shoot(api)
    local cache = api:getCachedScriptData()
    local mode = api:getFireMode()
    if mode == AUTO then
        local t1 = api:getLastShootTimestamp()
        local t2 = api:getCurrentTimestamp()
        local itv = api:getShootInterval()
        -- 别忘：时间单位是ms
        if (t2 - t1 <= itv+edge) then
            -- 没有松手（宽限为edge/ms）
            if cache.proc >= max then
                cache.proc = max
            else
                cache.proc = cache.proc+step
                cache.trigger = true
            end
        else
            cache.proc = 0
            cache.trigger = false
        end
        api:cacheScriptData(cache)
    else
        api:shootOnce(api:isShootingNeedConsumeAmmo())
    end
    cache.x_spread = (math.random()-0.5)*spread_index
    cache.y_spread = (math.random()-0.5)*spread_index
    api:cacheScriptData(cache)
end

function M.handle_shoot_heat(api)
end

function M.tick_heat(api,heatTimestamp)
    local cache = api:getCachedScriptData()
    if (cache == nil) then --如果没有就先初始化
            cache = {
                proc = 0, -- 初始值(蓄力进度)
                trigger = false, -- 是否正在连按
                overCharge = false, --是否过蓄
                x_spread = 0,
                y_spread = 0,
                timer = 0, --计时器
                shoot_power = 0
        }
    end
    if (cache.timer)>0 then
        local delay_timer = cache.timer
        cache.timer = math.max(delay_timer -1,0)
        api:setOverheatLocked(true)
    else
        api:setOverheatLocked(false)
    end
    local mode = api:getFireMode()
    if mode == AUTO then
        local t1 = api:getLastShootTimestamp()
        local t2 = api:getCurrentTimestamp()
        local itv = api:getShootInterval()
        if ((cache.trigger)and(t2 - t1 > 2*itv+edge)) then
            --松手且有蓄力进度,则按照蓄力进度执行复数次发射逻辑，清除蓄力进度
            cache.trigger = false
            local proc = cache.proc
            cache.proc=0
            cache.shoot_power = proc/max
            if proc>=0 then
                if proc>=20 then
                    cache.overCharge = true
                    api:shootOnce(api:isShootingNeedConsumeAmmo())
                    cache.overCharge = false
                else
                    api:shootOnce(api:isShootingNeedConsumeAmmo())
                end
            end
        end
    else
        --哈？
    end
    api:cacheScriptData(cache)
end

function M.calcSpread(api,num,spread)
    local cache = api:getCachedScriptData()
    return{cache.x_spread*spread,cache.y_spread*spread}
end

function M.modify_property(api, id, original)
    local cache = api:getCachedScriptData()
    if (id == "explosion_radius") then
        if cache.overCharge then
            return 2.5 * original
        end
    elseif (id == "damage") then
        if (api:getFireMode() == AUTO) then
            return (original * (1 + cache.shoot_power))
        end
        cache.shoot_power = 0
        api:cacheScriptData(cache)
    elseif (id == "explosion_damage") then
        if cache.overCharge then
            return (4 * original)
        end
    end
    return original
end

return M