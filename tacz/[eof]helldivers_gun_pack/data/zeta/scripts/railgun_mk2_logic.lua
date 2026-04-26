--foxatl
local M = {}
local max = 60  -- 满蓄力进度需求
local step =1 -- 一次伪射击进度增幅
local edge =50 --宽限，松手多久时触发，单位ms
local spread_index = 0.125 --扩散参数 调节此参数可改变综合射击准度（数据内部的不准确度依然生效）

function M.shoot(api)
        local t1 = api:getLastShootTimestamp()
        local t2 = api:getCurrentTimestamp()
        local itv = api:getShootInterval()
        local cache = api:getCachedScriptData()
        -- 别忘：时间单位是ms
        if (t2 - t1 <= itv+edge) then
            -- 没有松手（宽限为edge/ms）
            if cache.proc>max then
                cache.proc = max
                cache.overCharge = true
                api:shootOnce(api:isShootingNeedConsumeAmmo())
                cache.overCharge = false
                cache.trigger = false
                cache.proc = 0
            else
                if api:getFireMode() == BURST then
                    cache.proc = cache.proc+step
                else
                    cache.proc = math.min(10, cache.proc+step)
                end
                cache.trigger = true
            end
        else
            cache.proc = 0
            cache.trigger = false
        end
        cache.procd = cache.proc
        cache.x_spread = (math.random()-0.5)*spread_index
        cache.y_spread = (math.random()-0.5)*spread_index
        api:cacheScriptData(cache)
end

function M.tick_heat(api,heatTimestamp)
    local cache = api:getCachedScriptData()
        if (cache == nil) then --如果没有就先初始化
            cache = {
                proc = 0, -- 初始值(蓄力进度)
                procd = 0, --处理后值
                trigger = false, -- 是否正在连按
                overCharge = false, --是否过蓄
                x_spread = 0,
                y_spread = 0,
                damage_multiplier = 1
        }
        end
        local t1 = api:getLastShootTimestamp()
        local t2 = api:getCurrentTimestamp()
        local itv = api:getShootInterval()
        api:setOverheatLocked(false)
        if ((cache.trigger)and(t2 - t1 > 2*itv+edge)and(api:getAmmoCountInMagazine()>=1)) then
            --松手且有蓄力进度,则按照蓄力进度执行复数次发射逻辑，清除蓄力进度
            cache.trigger = false
            if cache.procd>=0 then
                if cache.procd>=9 then
                    cache.damage_multiplier = math.max(1, 1+((cache.procd - 10)/50)*1.5)
                    api:shootOnce(api:isShootingNeedConsumeAmmo())
                end
            end
            cache.procd=0
            --哈？
        end
        local process_display = 0
        if (cache.procd / max) < (1/6) then
            process_display = 4 * cache.procd/ max
        else
            process_display = 2/3 + math.pow((cache.procd/ max - (1/6)), 0.5)*(2/5)
        end
        api:setHeatAmount(process_display)
    api:cacheScriptData(cache)
end

function M.modify_property(api, id, original)
    local cache = api:getCachedScriptData()
    if (id == "explosion_radius") then
        if cache.overCharge then
            return 4
        end
    elseif (id == "explosion_damage") then
        if cache.overCharge then
            return 48
        end
    elseif (id == "damage") then
        return original * cache.damage_multiplier
    elseif (id == "explode_enabled") then
        if cache.overCharge then
            return true
        end
    elseif (id == "ammo_speed") then
        if cache.overCharge then
            return 1
        end
    end
    return original
end

function M.calcSpread(api,num,spread)
    local cache = api:getCachedScriptData()
    if cache.overCharge then
        return{(math.random()-0.5)*4,(math.random()-0.5)*4}
    else
        return{cache.x_spread*spread,cache.y_spread*spread}
    end
end

return M