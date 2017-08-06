local Game = require 'common.game'
local Entity = require 'entities.base.entity'
local Play = require 'gamestates.play'

local Win = Game:addState('Win')

function Win:enteredState(a,b)
  Log.debug('Entered state Win')
  Beholder.trigger('Win')
  self.img = Assets.img.ditter
  self.img:setWrap('repeat','repeat')
  local x,y,w,h = self.visible:screen()
  self.quad = g.newQuad(x,y,w,h,self.img:getDimensions())
  self.hud:gotoState('Win')
end

function Win:update(dt)
end

-- Disable touch controls (e.g. moving player) but still call 
-- normal touches (e.g. HUD)
function Play:pressed(x,y)
  Game.pressed(self,x,y)
end

function Play:released(x,y)
  Game.released(self,x,y)
end

function Win:drawAfterCamera(l,t,w,h)
  g.setColor(0,30,63,120)
  g.rectangle('fill',0,0,conf.sw,conf.sh)
  g.setColor(0,30,63,100)
  g.draw(self.img,self.quad,self.visible:leftTop())
  g.setColor(255,255,255,255)
  g.printf(
    'Level '..self.state.cli..'\nCleared!\nScore:'..self:getGrandScore(),
    0,conf.sh/2-self.fontHeight/2,conf.sw,'center')
  self.hud:draw(l,t,w,h)
end

function Win:keypressed(key, scancode, isrepeat)
  if key == 'space' or key == 'escape' then
    Beholder.trigger('NextLevel')
  end
end

return Win
