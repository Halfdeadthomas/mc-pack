local default = require("zeta_machinegun_state_machine")

local GUN_KICK_TRACK_LINE = default.GUN_KICK_TRACK_LINE
local STATIC_TRACK_LINE = default.STATIC_TRACK_LINE
local BOLT_CAUGHT_TRACK = default.BOLT_CAUGHT_TRACK
local MAIN_TRACK = default.MAIN_TRACK
local bolt_caught_states = default.bolt_caught_states
local main_track_states = default.main_track_states

local start_state = setmetatable({}, {__index = main_track_states.start})
local gun_kick_state = setmetatable({}, {__index = default.gun_kick_state})
local normal_states = setmetatable({}, {__index = bolt_caught_states.normal})
local caught_states = setmetatable({}, {__index = bolt_caught_states.bolt_caught})
local idle_state = setmetatable({}, {__index = main_track_states.idle})

local function isNoAmmo(context)
    return (not context:hasBulletInBarrel()) and (context:getAmmoCount() <= 0)
end

-- 播放丢枪动画的方法
local function runPutAwayAnimation(context)
    local put_away_time = context:getPutAwayTime()
    -- 此处获取的轨道是位于主轨道行上的主轨道
    local track = context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK)
    -- 播放 put_away 动画,并且将其过渡时长设为从上下文里传入的 put_away_time * 0.75
    context:runAnimation("put_away", track, false, PLAY_ONCE_HOLD, put_away_time * 0.75)
    -- 设定动画进度为最后一帧
    context:setAnimationProgress(track, 1, true)
    -- 将动画进度向前拨动 {put_away_time}
    context:adjustAnimationProgress(track, -put_away_time, false)
end

function gun_kick_state.transition(this, context, input)
    if (input == INPUT_SHOOT) then
        local track = context:findIdleTrack(GUN_KICK_TRACK_LINE, false)
        if (context:isCrawl()) then
            context:runAnimation("shoot_bipod", track, true, PLAY_ONCE_STOP, 0)
        else
            context:runAnimation("shoot", track, true, PLAY_ONCE_STOP, 0)
        end
    end
    return nil
end

function start_state.transition(this, context, input)
    -- 玩家手里拿到枪的那一瞬间会自动输入一个 draw 的信号,不用手动触发
    if (input == INPUT_DRAW) then
        -- 收到 draw 信号后在主轨道行的主轨道上播放掏枪动画,然后转到闲置态
        if (context:isCrawl()) then
            context:runAnimation("bipod_draw", context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK), false, PLAY_ONCE_STOP, 0)
        else
            context:runAnimation("draw", context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK), false, PLAY_ONCE_STOP, 0)
        end
        return this.main_track_states.idle
    end
end

function idle_state.transition(this, context, input)
    if (input == INPUT_PUT_AWAY) then
        local put_away_time = context:getPutAwayTime()
        -- 此处获取的轨道是位于主轨道行上的主轨道
        local track = context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK)
        -- 播放 put_away 动画,并且将其过渡时长设为从上下文里传入的 put_away_time * 0.75
        if (context:isCrawl()) then
            context:runAnimation("bipod_put_away", track, false, PLAY_ONCE_HOLD, put_away_time * 0.75)
        else
            context:runAnimation("put_away", track, false, PLAY_ONCE_HOLD, put_away_time * 0.75)
        end
        -- 设定动画进度为最后一帧
        context:setAnimationProgress(track, 1, true)
        -- 将动画进度向前拨动 {put_away_time}
        context:adjustAnimationProgress(track, -put_away_time, false)
        return this.main_track_states.idle
    end
    if (input == INPUT_INSPECT) then
        if (not context:isCrawl()) then
            if (isNoAmmo(context)) then
                context:runAnimation("inspect_empty", context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK), false, PLAY_ONCE_STOP, 0.2)
            else
                context:runAnimation("inspect", context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK), false, PLAY_ONCE_STOP, 0.2)
            end
        end
        return this.main_track_states.inspect
    end
    if (input == INPUT_RELOAD) then
        if (context:isCrawl()) then
            if (isNoAmmo(context)) then
                context:runAnimation("reload_bipod_empty", context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK), false, PLAY_ONCE_STOP, 0.2)
            else
                context:runAnimation("reload_bipod_tactical", context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK), false, PLAY_ONCE_STOP, 0.2)
            end
        else
            if (isNoAmmo(context)) then
                context:runAnimation("reload_empty", context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK), false, PLAY_ONCE_STOP, 0.2)
            else
                context:runAnimation("reload_tactical", context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK), false, PLAY_ONCE_STOP, 0.2)
            end
        end
        return this.main_track_states.idle
    end
    return main_track_states.idle.transition(this, context, input)
end

function normal_states.entry(this, context)
    context:runAnimation("static_ammo_display", context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK), false, PLAY_ONCE_STOP, 0)
    return this.bolt_caught_states.normal
end


function normal_states.update(this, context)
    if (isNoAmmo(context)) then
        context:stopAnimation(context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK))
        context:trigger(this.INPUT_BOLT_CAUGHT)
    else
        local a = context:getAmmoCount()
        local b = 6
        if (a < b) then
            context:setAnimationProgress(context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK),(b-a)*0.5,false)
        else
            context:setAnimationProgress(context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK),0.1,false)
        end
    end
end

local M = setmetatable({
    bolt_caught_states = setmetatable({
        normal = normal_states
    }, {__index = bolt_caught_states}),
    main_track_states = setmetatable({
		start = start_state,
        idle = idle_state
    }, {__index = main_track_states}),
    gun_kick_state = gun_kick_state
}, {__index = default})

function M:initialize(context)
    default.initialize(self, context)
end

return M