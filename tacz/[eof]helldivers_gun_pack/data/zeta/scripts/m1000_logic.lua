local M = {}

local function autoReload(api)
    local ammo = 1
    if (api:isReloadingNeedConsumeAmmo()) then
        ammo = api:consumeAmmoFromPlayer(1)
    end
    api:putAmmoInMagazine(api:getMaxAmmoCount()*ammo)
end
-- 尝试开火射击时调用
function M.shoot(api)
    api:shootOnce(api:isShootingNeedConsumeAmmo())
end

function M.start_reload(api)
    return false
end


local function tick_normal(api, heatTimestamp)
    local delay = api:getCoolingDelay()
    local now = api:getCurrentTimestamp()

    if now - heatTimestamp >= delay then
        local heat = api:getHeatAmount() - api:calcHeatReduction(heatTimestamp)
        api:setHeatAmount(heat)
    end
end

function M.tick_heat(api, heatTimestamp)
    if api:hasHeatData() then
        tick_normal(api, heatTimestamp)
    end
    if (api:getAmmoAmount()==0)then
        autoReload(api)
    end
end

-- 警告，此方法是shootOnce的一部分，不要在此处尝试射击，不然会死循环
function M.handle_shoot_heat(api)
    if api:hasHeatData() then
        local heatMax = api:getHeatMax()
        local heat = math.min(api:getHeatAmount() + api:getHeatPerShot(), heatMax)
        api:setHeatAmount(heat)
    end
end

return M