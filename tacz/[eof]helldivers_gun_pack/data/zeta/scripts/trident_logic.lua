local M = {}

-- 尝试开火射击时调用
function M.shoot(api)
    api:shootOnce(false)
end

function M.start_reload(api)
    -- Initialize cache that will be used in reload ticking
    local cache = api:getCachedScriptData()
    cache.is_tactical = not(api:isOverheatLocked())
    cache.needed_count = 1
    api:cacheScriptData(cache)
    -- Return true to start ticking
    return true
end

function M.tick_reload(api)
    local cache = api:getCachedScriptData()

    local empty_cooldown = api:getScriptParams().empty_cooldown * 1000
    local empty_feed = api:getScriptParams().empty_feed * 1000
    local reload_cooldown = api:getScriptParams().reload_cooldown * 1000
    local reload_feed = api:getScriptParams().reload_feed * 1000
    local reload_time = api:getReloadTime()

    if (not cache.is_tactical) then
        if (reload_time < empty_feed) then
            return TACTICAL_RELOAD_FEEDING, empty_feed - reload_time
        elseif (reload_time >= empty_feed and reload_time < empty_cooldown) then
            if (cache.needed_count > 0) then
                api:consumeAmmoFromPlayer(cache.needed_count)
                cache.needed_count = 0
            end
            api:setHeatAmount(0)
            api:setOverheatLocked(false)
            return TACTICAL_RELOAD_FINISHING, empty_cooldown - reload_time
        else
            return NOT_RELOADING, -1
        end
    else
        if (reload_time < reload_feed) then
            return EMPTY_RELOAD_FEEDING, reload_feed - reload_time
        elseif (reload_time >= reload_feed and reload_time < reload_cooldown) then
            if (cache.needed_count > 0) then
                api:consumeAmmoFromPlayer(cache.needed_count)
                cache.needed_count = 0
            end
            api:setHeatAmount(0)
            api:setOverheatLocked(false)
            return EMPTY_RELOAD_FINISHING, reload_cooldown - reload_time
        else
            return NOT_RELOADING, -1
        end
    end
end

local function getCoolingValue(api)
    local param = api:getScriptParams()
    local magLevel = api:getMagExtentLevel()
    local maxHeatSheet = {1, param.maxMag1, param.maxMag2, param.maxMag3}
    local coolingSheet = {param.cooldown, param.coolingMag1, param.coolingMag2, param.coolingMag3}
    local max = maxHeatSheet[magLevel+1] -- 实际上是增加热量和散热都除以这个数来实现增大容积的效果
    local cooling = coolingSheet[magLevel+1]
    return max, cooling
end

local function tick_normal(api, heatTimestamp)
    local max, cooling = getCoolingValue(api)
    local delay = api:getCoolingDelay()
    local now = api:getCurrentTimestamp()
    local last = api:getLastShootTimestamp()

    if now - last >= delay then
        local heat = api:getHeatAmount() - cooling/max
        api:setHeatAmount(heat)
    end
end

local function tick_locked(api, heatTimestamp)
    api:setHeatAmount(api:getHeatMax())
end

local function getProcessedTimestamp(api)
    local timestamp = api:getCurrentTimestamp() - 1753977600000 -- 2025年8月1日00:00时间戳（ms）
    timestamp = math.floor(timestamp/100)--以分秒为单位
    return timestamp
end

local function ammoTimestampFix(api)
    api:removeAmmoFromMagazine(2147483647)
    if not api:isOverheatLocked()then
        api:putAmmoInMagazine(getProcessedTimestamp(api))
    end
end

local function heatFeedback(api, heatTimestamp)
    local max, cooling = getCoolingValue(api)
    local ammoTimestamp = api:getAmmoAmount()
    local trueTimestamp = getProcessedTimestamp(api)
    local TimestampFrameGap = (trueTimestamp - ammoTimestamp)*100 -- 单位是分秒,换算成毫秒
    local heat = api:getHeatAmount()
    local delay = api:getCoolingDelay()
    if not(api:isOverheatLocked()) then
        heat = heat - math.max(0,TimestampFrameGap-delay)*(cooling/max)/50 -- 每50毫秒为一帧
    end
    api:setHeatAmount(heat)
end

function M.tick_heat(api, heatTimestamp)
    local cache = api:getCachedScriptData()
    if (cache == nil) then --如果没有就先初始化
        cache = {
            initial = false, -- 初始化
            is_tactical = api:getReloadStateType() == TACTICAL_RELOAD_FEEDING,
            needed_count = 1
        }
    end
    if not(cache.initial)then
        cache.initial = true
        heatFeedback(api, heatTimestamp)
    end
    api:cacheScriptData(cache)
    ammoTimestampFix(api)
    if api:hasHeatData() then
        if api:isOverheatLocked() then
            tick_locked(api, heatTimestamp)
        else
            tick_normal(api, heatTimestamp)
        end
    end
end

-- 警告，此方法是shootOnce的一部分，不要在此处尝试射击，不然会死循环
function M.handle_shoot_heat(api)
    if api:hasHeatData() then
        local max, cooling = getCoolingValue(api)
        local heatMax = api:getHeatMax()
        local heat = math.min(api:getHeatAmount() + api:getHeatPerShot()/max, heatMax)
        api:setHeatAmount(heat)
        if heat >= heatMax then
            api:setOverheatLocked(true);
        end
    end
end

local function safeRequire(module,fallback)
    local safe, mod = pcall(require, module)
    if safe then
        return mod
    else
        return nil
    end
end

local random = safeRequire("tacz_foxtail_simple_random_sheet")
local random_sheet = random.RANDOM
local length = #random_sheet
local function randFunc(input1,input2)
    local index1 = 191.981
    local index2 = 1145.14
    local num = math.floor(index1*input1%1000 + index2*input2)%length + 1
    local output = random_sheet[num]
    return output
end

function M.calcSpread(api, count, spread)
    local spread_multiplier = 0.35 -- 参数
    if api:getAimingProgress() >= 1 then
        spread_multiplier = 0.325
    end
    local y_fix_spread = 0.625
    local counter = count + 1
    local seed = api:getAmmoAmount()
    local x_random_spread = randFunc(seed , counter) -- 从-1到1
    local xx = x_random_spread * spread_multiplier
    local y_random_spread = randFunc(seed , counter + 1) -- 从-1到1
    local yy = y_random_spread * spread_multiplier *y_fix_spread

    
    if counter <=2 then --枪口位置偏移
        xx = xx + 0
        yy = yy + 0.2
    elseif counter <= 4 then
        xx = xx -0.173
        yy = yy -0.1
    elseif counter <=6 then
        xx = xx +0.173
        yy = yy -0.1
    end
    return {xx,yy}
end

return M