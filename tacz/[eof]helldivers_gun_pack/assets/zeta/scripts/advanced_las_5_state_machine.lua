local default = require("tacz_default_state_machine")
local GUN_KICK_TRACK_LINE = default.GUN_KICK_TRACK_LINE
local STATIC_TRACK_LINE = default.STATIC_TRACK_LINE
local MAIN_TRACK = default.MAIN_TRACK
local BOLT_CAUGHT_TRACK = default.BOLT_CAUGHT_TRACK
local main_track_states = default.main_track_states
local bolt_caught_states = default.bolt_caught_states

local idle_state = setmetatable({
    bayonet_counter = 0
}, {__index = main_track_states.idle})
local gun_kick_state = setmetatable({}, {__index = default.gun_kick_state})
local bolt_caught = setmetatable({
    mode = -1,
    sound_lock = 0,
    trigger = 0
}, {__index = bolt_caught_states.bolt_caught})
local normal = setmetatable({}, {__index = bolt_caught_states.normal})

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

-- 播放换弹动画的方法
local function runReloadAnimation(context)
    -- 此处获取的轨道是位于主轨道行上的主轨道
    local track = context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK)
    -- 根据当前整枪内是否还有弹药决定是播放战术换弹还是空枪换弹
    if (context:isOverHeat()) then
        context:runAnimation("reload_empty", track, false, PLAY_ONCE_STOP, 0.2)
    else
        context:runAnimation("reload_tactical", track, false, PLAY_ONCE_STOP, 0.2)
    end
end

-- 播放检视动画的方法
local function runInspectAnimation(context)
    -- 此处获取的轨道是位于主轨道行上的主轨道
    local track = context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK)
    -- 根据当前整枪内是否还有弹药决定是播放普通检视还是空枪检视
    if (context:isOverHeat()) then
        context:runAnimation("inspect_empty", track, false, PLAY_ONCE_STOP, 0.2)
    else
        context:runAnimation("inspect", track, false, PLAY_ONCE_STOP, 0.2)
    end
end

function normal.update(this, context)
    local t1 = context:getLastShootTimestamp()
    local t2 = context:getCurrentTimestamp()
    local itv = context:getShootInterval()
    local edge =50
    if (t2 - t1 > 2*itv+edge) then
        bolt_caught.sound_lock = 0
        context:stopAnimation(context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK))
        if(bolt_caught.trigger == 1)then
            bolt_caught.trigger = 0
            context:runAnimation("shoot_loop_end", context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK), true, PLAY_ONCE_STOP, 0)
        end
    else
        bolt_caught.trigger = 1
    end
    if (context:isOverHeat()) then
        context:trigger(this.INPUT_BOLT_CAUGHT)
    end
end

function normal.entry(this, context)
    context:stopAnimation(context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK))
    this.bolt_caught_states.normal.update(this, context)
end

function normal.transition(this, context, input)
    if (input == this.INPUT_BOLT_CAUGHT) then
        return this.bolt_caught_states.bolt_caught
    end
end

function bolt_caught.entry(this, context)
    bolt_caught.sound_lock = 0
    if(bolt_caught.trigger == 1)then
        bolt_caught.trigger = 0
        context:runAnimation("shoot_loop_end", context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK), true, PLAY_ONCE_STOP, 0)
    end
    context:stopAnimation(context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK))
    context:runAnimation("static_bolt_caught", context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK), true, PLAY_ONCE_HOLD, 0)
    if (bolt_caught.mode == 1) then
        context:setAnimationProgress(context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK), 1, false)
    else
        bolt_caught.mode = 1
    end
end

function bolt_caught.update(this, context)
    if (not context:isOverHeat()) then
        context:trigger(this.INPUT_BOLT_NORMAL)
    end
end

function bolt_caught.transition(this, context, input)
    if (input == this.INPUT_BOLT_NORMAL) then
        bolt_caught.mode = -1
        return this.bolt_caught_states.normal
    end
end

function idle_state.transition(this, context, input)
    if (input == INPUT_PUT_AWAY) then
        runPutAwayAnimation(context)
        this.main_track_states.final.isfinal = 1
        -- 丢枪后转到最终态
        return this.main_track_states.final
    end
    if (input == INPUT_RELOAD) then
        runReloadAnimation(context)
        return this.main_track_states.idle
    end
    if (input == INPUT_SHOOT) then
        if (bolt_caught.sound_lock ==0)then
            context:runAnimation("shoot_loop", context:getTrack(STATIC_TRACK_LINE, BOLT_CAUGHT_TRACK), true, LOOP, 0)
            bolt_caught.sound_lock = 1
        end
        context:popShellFrom(0)
        return this.main_track_states.idle
    end
    if (input == INPUT_BOLT) then
        context:runAnimation("bolt", context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK), false, PLAY_ONCE_STOP, 0.2)
        return this.main_track_states.idle
    end
    if (input == INPUT_INSPECT and context:getAimingProgress() < 1) then
        runInspectAnimation(context)
        return this.main_track_states.inspect
    end
    if (input == INPUT_BAYONET_MUZZLE) then
        local counter = this.main_track_states.bayonet_counter
        local animationName = "melee_bayonet_" .. tostring(counter + 1)
        this.main_track_states.bayonet_counter = (counter + 1) % 3
        context:runAnimation(animationName, context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK), false, PLAY_ONCE_STOP, 0.2)
        return this.main_track_states.idle
    end
    if (input == INPUT_BAYONET_STOCK) then
        context:runAnimation("melee_stock", context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK), false, PLAY_ONCE_STOP, 0.2)
        return this.main_track_states.idle
    end
    if (input == INPUT_BAYONET_PUSH) then
        context:runAnimation("melee_push", context:getTrack(STATIC_TRACK_LINE, MAIN_TRACK), false, PLAY_ONCE_STOP, 0.2)
        return this.main_track_states.idle
    end
end

local M = setmetatable({
    bolt_caught_states = setmetatable({
        normal = normal,
        bolt_caught = bolt_caught
    }, {__index = bolt_caught_states}),
    main_track_states = setmetatable({
        idle = idle_state
    }, {__index = main_track_states}),
    gun_kick_state = gun_kick_state
}, {__index = default})

function M:initialize(context)
    default.initialize(self, context)
end

return M