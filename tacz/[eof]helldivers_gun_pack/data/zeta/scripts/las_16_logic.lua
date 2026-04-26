local M = {}

function M.shoot(api)
    api:safeAsyncTask(function ()
        api:shootOnce(api:isShootingNeedConsumeAmmo())
        return false
    end,0,0,1)
    api:safeAsyncTask(function ()
        local ammo_count = api:getAmmoAmount()
        if (ammo_count ~= 0 and ammo_count < 75) then
        api:putAmmoInMagazine(1)
        end
        return true
    end,75*10000,0,1)
end

return M