local M = {}
local length =3 --扩散长度参数
local div = 0.5 --扩散宽度参数
local bullet_amount=16 --与data一致

local function degtorad(deg)
    local rad = math.pi*deg/180
    return rad
end

function M.calcSpread(api, count, spread)
    local angle = 0
    if spread == 0 then --此spread==后面的数字需与data中的下蹲扩散相等
        angle = -60
        spread = 5
    end
    local offset = -0.5+0.5*(bullet_amount)
    local itp = (offset-count)/bullet_amount*spread/7.5
    local xx =math.cos(degtorad(angle))*itp*length+(math.random()-0.5)*div
    local yy =math.sin(degtorad(angle))*itp*length+(math.random()-0.5)*div
    return {xx,yy}
end

function M.modify_property(api, id, original)
    local cache = api:getCachedScriptData()
    if (id == "bullet_amount") then
        local mag = api:getAttachment("EXTENDED_MAG")
        if (mag == "tacz:ammo_mod_he") then
            return 10
        elseif (mag == "tacz:ammo_mod_hp") then
            return 20
        end
    end
    return original
end

return M