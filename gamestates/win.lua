local Game = require 'common.game'
local Entity = require 'entities.base.entity'
local Play = require 'gamestates.play'

local Win = Game:addState('Win')

function Win:enteredState()
  Log.debug('Entered state Win')
  Beholder.trigger('Win')
  self.swallowTouch = true
  local x,y,w,h = self.visible:screen()
  Entity:new(self.world,x,y,w,h,{zOrder=9})
end

-- function Win:update(dt)
--   self:updateShaders(dt, self.progress.shift, self.progress.alpha)
-- end

function Win:drawAfterCamera()
  g.setColor(30,30,30,180)
  g.rectangle('fill',self.visible:rect(0,conf.height/2-30,conf.widht,60))
  g.setColor(255,255,255,255)
  -- XXX
  g.printf('Cleared!',0,conf.height/2-self.fontHeight/2,conf.width,'center')
end

function Win:keypressed(key, scancode, isrepeat)
  if key == 'space' or key == 'escape' then
    self:gotoState('Play')
  end
end

return Win
