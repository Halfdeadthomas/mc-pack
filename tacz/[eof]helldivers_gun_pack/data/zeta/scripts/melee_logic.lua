local M = {}
function M.start_reload(api)
    return false
end
function M.shoot(api)
    api:shootOnce(false)
end
return M