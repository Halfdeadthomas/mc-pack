local M = {}

function M.shoot(api)
    if api:getFireMode()==AUTO then
        api:shootOnce(api:isShootingNeedConsumeAmmo())
    elseif api:getFireMode()==SEMI then
        for i = 0, 7-1, 1 do
        api:shootOnce(api:isShootingNeedConsumeAmmo())
        end
    elseif api:getFireMode()==BURST then
        local count = api:getAmmoAmount()
        for i = 0, count-1, 1 do
        api:shootOnce(api:isShootingNeedConsumeAmmo())
        end
    end
end

return M