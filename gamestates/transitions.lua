-- transitions.lua

local Game = require 'common.game'

-- TransitionIn

local TransitionIn = Game:addState('TransitionIn')

function TransitionIn:enteredState(callback)
  Log.info 'Enter state TransitionIn'
  self.callback = callback
  self.transition:reset()
end

function TransitionIn:update(dt)
  if self.transition:update(dt) then
    self:popState()
    if self.callback then self.callback() end
  end
  -- Do transition effects (music/screen fade in)
  self:doTransition()
end

function TransitionIn:keypressed(key, scancode, isRepeat)
  -- touche disabled
end

-- TransitionOut

local TransitionOut = Game:addState('TransitionOut')

function TransitionOut:enteredState(callback)
  Log.info 'Enter state TransitionOut'
  -- running backwards
  self.transition:set(self.transition.duration)
  self.callback = callback
end

function TransitionOut:update(dt)
  if self.transition:update(-dt) then
    self:popState()
    if self.callback then self.callback() end
  end
end

function TransitionOut:keypressed(key, scancode, isRepeat)
  -- disable touches
end
