local M = {}
--这托史山的原理是取消每一次开火的同时累积“进度”，进度满时触发真正的射击
--切莫相信史山
local max = 80  -- 满蓄力进度需求
local step = 1 -- 一次伪射击进度增幅（你最好别输入怪东西）

function M.start_reload(api)
    return false
end

function M.shoot(api)
    -- 不调用射击逻辑
    -- 从脚本缓存中获取蓄力进度
    local cache = api:getCachedScriptData()
    if (cache == nil) then --如果没有就先初始化
        cache = {
            proc = 0 -- 初始值(蓄力进度)
        }
    end

    -- 别忘：时间单位是ms
    local t1 = api:getLastShootTimestamp()
    local t2 = api:getCurrentTimestamp()
    local itv = api:getShootInterval()
    if (t2 - t1 < itv + 50) then
        -- 没有松手（50ms宽限）
        if (cache.proc < max) then --没有蓄满时按住，也就是继续增加数值
            cache.proc = cache.proc + step
        elseif (cache.proc >= max) then --蓄满了还按着，那发射
            api:shootOnce(false)
            cache.proc = 0
        end
    else
        -- 松手太久了再接的，清零进度
        cache.proc = 0
    end

    -- 写回脚本缓存
    api:cacheScriptData(cache)
end

local function tick_locked(api, heatTimestamp)
    local delay = api:getCoolingDelay()
    local now = api:getCurrentTimestamp()
    local last = api:getLastShootTimestamp()

    if now - last >= delay then
        local heat = api:getHeatAmount() - 2
        api:setHeatAmount(heat)
        if heat<=0 then
            api:setOverheatLocked(false);
        end
    end
end

local function tick_normal(api, heatTimestamp)
    api:setHeatAmount(0)
end

local function getProcessedTimestamp(api)
    local timestamp = api:getCurrentTimestamp() - 1753977600000 -- 2025年8月1日00:00时间戳
    timestamp = math.floor(timestamp/100)--以分秒为单位
    return timestamp
end

local function ammoTimestampFix(api)
    api:removeAmmoFromMagazine(2147483647)
    api:putAmmoInMagazine(getProcessedTimestamp(api))
end

local function heatFeedback(api, heatTimestamp)
    local ammoTimestamp = api:getAmmoAmount()
    local trueTimestamp = getProcessedTimestamp(api)
    local TimestampFrameGap = (trueTimestamp - ammoTimestamp)*100 -- 单位是分秒,换算成毫秒
    local heat = api:getHeatAmount()
    local delay = api:getCoolingDelay()
    if (api:isOverheatLocked()) then
        heat = heat - math.max(0,TimestampFrameGap-delay)*2/50 -- 每50毫秒为一帧
    end
    api:setHeatAmount(heat)
    if heat<=0 then
        api:setOverheatLocked(false);
    end
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
        local heatMax = api:getHeatMax()
        local heat = math.min(api:getHeatAmount() + api:getHeatPerShot(), heatMax)
        api:setHeatAmount(heat)
        if heat >= heatMax then
            api:setOverheatLocked(true);
        end
    end
end

return M