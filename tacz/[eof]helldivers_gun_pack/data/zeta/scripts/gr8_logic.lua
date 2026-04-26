-- 定义逻辑机，定式

-- 此地为阶段性换弹实验性脚本，改动基础为tacz:xmag_reload_logic.lua
-- 本逻辑脚本将过热锁定机制挪用，因此与原生过热机制不兼容
-- 你需要在对应data中填写有关参数并按定式填写过热数据
-- 概念-接续点：一个[应当大于0且小于对应换弹类型的feed时长]的数值 战术换弹与非战术换弹有各自的接续点
--             意义为将一个正常换弹的过程分为两个阶段，在[接续点]之后取消换弹时，下一次换弹会进入[接续换弹]，如不取消或过早取消则不触发
-- 概念-接续换弹：在正常的换弹过程在一定时间段被打断之后重新取枪换弹时触发的事件，通常更短(没人规定一定更短)，有对应数值需要填写
--               用于模拟类似Helldivers2中武器换弹过程被打断后阶段性保留换弹进度的机制

local M = {}

-- 当开始换弹的时候调用一次,以cache形式记录本次换弹是否为接续换弹
function M.start_reload(api)
    --开始换弹时如果为热锁状态，则说明本次换弹为接续换弹
    local continue = api:isOverheatLocked()
    local cache = api:getCachedScriptData()
        cache.continue_reload = continue
    api:cacheScriptData(cache)

    -- 关于禁用换弹的处理
    local param = api:getScriptParams();
    local ban_tactical_reload = param.ban_tactical_reload -- 获取是否禁用战术换弹
    local closed_bolt = param.closed_bolt -- 获取是否为闭膛待击
    local hasBulletInBarrel = api:hasAmmoInBarrel()
    -- 如果是open_bolt就只看弹药容量是否不为0
    if not(closed_bolt == 1) then
        hasBulletInBarrel = (api:getAmmoAmount()>0)
    end
    if (ban_tactical_reload == 1) and hasBulletInBarrel then -- 禁用战术换弹为真且枪管里有子弹时返回假也就是不触发换弹
        return false
    end
    return true
end

-- 这是个 lua 函数，用来从枪 data 文件里获取装弹相关的动画时间点，由于 lua 内的时间是毫秒，所以要和 1000 做乘算
local function getReloadTimingFromParam(param)
    -- 前有参数地狱，接下来闭眼会很有用
    -- 如果此data参数为1，则代表采用基于弹匣等级的不同换弹时长，否则统一为基础值，此时你可以不填带有"xmag"的参数
    local different_reload_time = param.different_reload_time
    -- 如果此data参数为1，则代表武器采用膛内留弹机制
    local closed_bolt = param.closed_bolt
    -- 一般格式
    local reload_feed = {param.reload_feed, param.reload_xmag_1_feed, param.reload_xmag_2_feed, param.reload_xmag_3_feed}
    local reload_cooldown = {param.reload_cooldown, param.reload_xmag_1_cooldown, param.reload_xmag_2_cooldown, param.reload_xmag_3_cooldown}
    local empty_feed = {param.empty_feed, param.empty_xmag_1_feed, param.empty_xmag_2_feed, param.empty_xmag_3_feed}
    local empty_cooldown = {param.empty_cooldown, param.empty_xmag_1_cooldown, param.empty_xmag_2_cooldown, param.empty_xmag_3_cooldown}
    -- 接续点
    local reload_division = {param.reload_division, param.reload_xmag_1_division, param.reload_xmag_2_division, param.reload_xmag_3_division}
    local empty_division = {param.empty_division, param.empty_xmag_1_division, param.empty_xmag_2_division, param.empty_xmag_3_division}
    -- 战术换弹的接续
    local continue_feed = {param.continue_feed, param.continue_xmag_1_feed, param.continue_xmag_2_feed, param.continue_xmag_3_feed}
    local continue_cooldown = {param.continue_cooldown, param.continue_xmag_1_cooldown, param.continue_xmag_2_cooldown, param.continue_xmag_3_cooldown}
    -- 非战术换弹的接续
    local follow_feed = {param.follow_feed, param.follow_xmag_1_feed, param.follow_xmag_2_feed, param.follow_xmag_3_feed}
    local follow_cooldown = {param.follow_cooldown, param.follow_xmag_1_cooldown, param.follow_xmag_2_cooldown, param.follow_xmag_3_cooldown}
    --如果不采用时长差异，就把所有扩容换弹时长覆盖成基础时长
    if not(different_reload_time == 1) then
        for i = 2, 4 do
            reload_feed[i] = reload_feed[1]
            reload_cooldown[i] = reload_cooldown[1]
            empty_feed[i] = empty_feed[1]
            empty_cooldown[i] = empty_cooldown[1]
            reload_division[i] = reload_division[1]
            empty_division[i] = empty_division[1]
            continue_feed[i] = continue_feed[1]
            continue_cooldown[i] = continue_cooldown[1]
            follow_feed[i] = follow_feed[1]
            follow_cooldown[i] = follow_cooldown[1]
        end
    end
    for i = 1, 4 do
        -- 将 param 中的时间点转换为毫秒
        -- 如果有nil直接返回nil
        if (reload_feed[i] == nil or reload_cooldown[i] == nil or empty_feed[i] == nil or empty_cooldown[i] == nil or reload_division[i] == nil or empty_division[i] == nil or continue_feed[i] == nil or continue_cooldown[i] == nil or follow_feed[i] == nil or follow_cooldown[i] == nil) then
            return nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
        end
        reload_feed[i] = reload_feed[i] * 1000
        reload_cooldown[i] = reload_cooldown[i] * 1000
        empty_feed[i] = empty_feed[i] * 1000
        empty_cooldown[i] = empty_cooldown[i] * 1000
        reload_division[i] = reload_division[i] * 1000
        empty_division[i] = empty_division[i] * 1000
        continue_feed[i] = continue_feed[i] * 1000
        continue_cooldown[i] = continue_cooldown[i] * 1000
        follow_feed[i] = follow_feed[i] * 1000
        follow_cooldown[i] = follow_cooldown[i] * 1000
    end

    -- 顺序返回获取到的这 10 个数组
    return reload_feed, reload_cooldown, empty_feed, empty_cooldown, reload_division, empty_division, continue_feed, continue_cooldown, follow_feed, follow_cooldown
end

-- 判断这个状态是否是空仓换弹过程中的其中一个阶段。包括空仓换弹的收尾阶段
local function isReloadingEmpty(stateType)
    return stateType == EMPTY_RELOAD_FEEDING or stateType == EMPTY_RELOAD_FINISHING
end

-- 判断这个状态是否是战术换弹过程中的其中一个阶段。包括战术换弹的收尾阶段
local function isReloadingTactical(stateType)
    return stateType == TACTICAL_RELOAD_FEEDING or stateType == TACTICAL_RELOAD_FINISHING
end

-- 判断这个状态是否是任意换弹过程中的其中一个阶段。包括任意换弹的收尾阶段
local function isReloading(stateType)
    return isReloadingEmpty(stateType) or isReloadingTactical(stateType)
end

-- 判断这个状态是否是任意换弹过程中的的收尾阶段
local function isReloadFinishing(stateType)
    return stateType == EMPTY_RELOAD_FINISHING or stateType == TACTICAL_RELOAD_FINISHING
end

local function finishReload(api, is_tactical)
    local param = api:getScriptParams();
    api:setOverheatLocked(false) --换弹正式结束时取消热锁
    local needAmmoCount = api:getNeededAmmoAmount();
    if (api:isReloadingNeedConsumeAmmo()) then
        -- 需要消耗弹药（生存或冒险）的话就消耗换弹所需的弹药并将消耗的数量装填进弹匣
        if (param.fuel_reload==1) then -- 如果采用fuel类型装填，则只消耗一份，否则正常
            api:putAmmoInMagazine(needAmmoCount * api:consumeAmmoFromPlayer(1))
        else
            api:putAmmoInMagazine(api:consumeAmmoFromPlayer(needAmmoCount))
        end
    else
        -- 不需要消耗弹药（创造）的话就直接把弹匣塞满
        api:putAmmoInMagazine(needAmmoCount)
    end
    if (not is_tactical)and(param.closed_bolt==1) then
        local i = api:removeAmmoFromMagazine(1);
        if i ~= 0 then
            api:setAmmoInBarrel(true)
        end
    end
end

function M.tick_reload(api)
    local cache = api:getCachedScriptData()
    -- 从枪 data 文件中获取所有需要传入逻辑机的参数，注意此时的 param 是个列表，还不能直接拿来用
    local param = api:getScriptParams();
    -- 调用刚才的 lua 函数，把 param 里包含的八个参数依次赋值给我们新定义的变量
    local reload_feed, reload_cooldown, empty_feed, empty_cooldown, reload_division, empty_division, continue_feed, continue_cooldown, follow_feed, follow_cooldown = getReloadTimingFromParam(param)
    -- 照例检查是否有参数缺失
    if (reload_feed == nil or reload_cooldown == nil or empty_feed == nil or empty_cooldown == nil or reload_division == nil or empty_division == nil or continue_feed == nil or continue_cooldown == nil or follow_feed == nil or follow_cooldown == nil) then
        return NOT_RELOADING, -1
    end

    -- 获取当前弹匣等级，我们假设最多 3 级
    local mag_level = math.min(api:getMagExtentLevel(), 3) + 1

    local countDown = -1
    local stateType = NOT_RELOADING
    local oldStateType = api:getReloadStateType()
    --如果是接续换弹，则覆盖部分换弹属性
    if (cache.continue_reload) then
        reload_cooldown = continue_cooldown
        reload_feed = continue_feed
        empty_cooldown = follow_cooldown
        empty_feed = follow_feed
    end

    -- 获取换弹时间，在玩家按下 R 的一瞬间作为零点，单位是毫秒。假设玩家在一秒前按下了 R ，那么此时这个时间就是 1000
    local progressTime = api:getReloadTime()

    if isReloadingEmpty(oldStateType) then
        local feed_time = empty_feed[mag_level]
        local finishing_time = empty_cooldown[mag_level]
        if progressTime < feed_time then
            stateType = EMPTY_RELOAD_FEEDING
            countDown = feed_time - progressTime
        elseif progressTime < finishing_time then
            stateType = EMPTY_RELOAD_FINISHING
            countDown = finishing_time - progressTime
        else
            stateType = NOT_RELOADING;
            countDown = -1
        end
    elseif isReloadingTactical(oldStateType) then
        local feed_time = reload_feed[mag_level]
        local finishing_time = reload_cooldown[mag_level]
        if progressTime < feed_time then
            stateType = TACTICAL_RELOAD_FEEDING
            countDown = feed_time - progressTime
        elseif progressTime < finishing_time then
            stateType = TACTICAL_RELOAD_FINISHING
            countDown = finishing_time - progressTime
        else
            stateType = NOT_RELOADING;
            countDown = -1
        end
    else
        stateType = NOT_RELOADING;
        countDown = -1
    end

    if oldStateType == EMPTY_RELOAD_FEEDING and oldStateType ~= stateType then
        finishReload(api,false);
    end

    if oldStateType == TACTICAL_RELOAD_FEEDING and oldStateType ~= stateType then
        finishReload(api, true);
    end
    
    if oldStateType == EMPTY_RELOAD_FEEDING then
        if (progressTime > empty_division[mag_level])and(progressTime < empty_feed[mag_level])and(not cache.continue_reload) then
            api:setOverheatLocked(true) --非接续状态下，越过分划点且未到达feed时打开热锁
        end
    elseif oldStateType == TACTICAL_RELOAD_FEEDING then
        if (progressTime > reload_division[mag_level])and(progressTime < reload_feed[mag_level])and(not cache.continue_reload) then
            api:setOverheatLocked(true) --非接续状态下，越过分划点且未到达feed时打开热锁
        end
    end

    return stateType, countDown
end

function M.handle_shoot_heat(api)
    --绕过热量有关的逻辑
end
function M.tick_heat(api, heatTimestamp)
    local cache = api:getCachedScriptData()
    if cache == nil then
        cache = {
            continue_reload = false,
            ammo_type = "normal",
            x_spread = 0,
            y_spread = 0,
        }
    end
    api:cacheScriptData(cache)
end


function M.shoot(api)
    local cache = api:getCachedScriptData()
    cache.ammo_type = "normal"

    if api:getAttachment("EXTENDED_MAG") == "zeta:gr8_f" then
        local spread_index = 0.12
        cache.x_spread = (math.random()-0.5)*spread_index
        cache.y_spread = (math.random()-0.5)*spread_index
        cache.ammo_type = "ignite"
        api:shootOnce(api:isShootingNeedConsumeAmmo())
        cache.ammo_type = "ignite_shard"
        api:shootOnce(false)
        cache.ammo_type = "ignite_extra"
        api:shootOnce(false)
    elseif api:getAttachment("EXTENDED_MAG") == "zeta:gr8_he" then
        cache.ammo_type = "normal"
        local spread_index = 0.16
        cache.x_spread = (math.random()-0.5)*spread_index
        cache.y_spread = (math.random()-0.5)*spread_index
        api:shootOnce(api:isShootingNeedConsumeAmmo())
        cache.ammo_type = "he"
        api:shootOnce(false)
    else
        cache.ammo_type = "normal"
        local spread_index = 0.1
        cache.x_spread = (math.random()-0.5)*spread_index
        cache.y_spread = (math.random()-0.5)*spread_index
        api:shootOnce(api:isShootingNeedConsumeAmmo())
    end
    api:cacheScriptData(cache)
end

function M.modify_property(api, id, original)
    local cache = api:getCachedScriptData()
    if (id == "explode_enabled") then
        if (cache.ammo_type == "ignite_extra") then
            return false
        end
    elseif (id == "bullet_amount") then
        if (cache.ammo_type == "ignite_extra") then
            return 64
        elseif (cache.ammo_type == "ignite") then
            return 1
        elseif (cache.ammo_type == "he") then
            return 1
        elseif (cache.ammo_type == "ignite_shard") then
            return 8
        end
    elseif (id == "damage") then
        if (cache.ammo_type == "ignite_extra") then
            return 10
        elseif (cache.ammo_type == "ignite_shard") then
            return 8
        elseif (cache.ammo_type == "he") then
            return 10
        end
    elseif (id == "explosion_radius") then
        if (cache.ammo_type == "ignite") then
            return 8
        elseif (cache.ammo_type == "ignite_shard") then
            return 6
        elseif (cache.ammo_type == "he") then
            return 3
        end
    elseif (id == "explosion_damage") then
        if (cache.ammo_type == "ignite") then
            return 80
        elseif (cache.ammo_type == "ignite_shard") then
            return 60
        elseif (cache.ammo_type == "he") then
            return 300
        end
    elseif (id == "ammo_speed") then
        if (cache.ammo_type == "ignite")or(cache.ammo_type == "ignite_shard") then
            return original * 0.4
        elseif (cache.ammo_type == "ignite_extra") then
            return original * 0.3995
        end
    end
    return original
end

function M.calcSpread(api,num,spread)
    local cache = api:getCachedScriptData()
    local xspread = 0.08
    if (cache.ammo_type == "normal") then
        xspread = 0
    elseif (cache.ammo_type == "ignite_shard") then
        xspread = 0.06
    elseif (cache.ammo_type == "he") then
        xspread = 0.06
    end
    local random_x = (math.random()-0.5)*xspread
    local random_y = (math.random()-0.5)*xspread
    return{cache.x_spread*spread + random_x,cache.y_spread*spread + random_y}
end

-- 向模组返回整个逻辑机，定式
return M