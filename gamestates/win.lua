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
end

function Win:update(dt)
end

function Win:drawAfterCamera()
  g.setColor(0,30,63,120)
  g.rectangle('fill',0,0,conf.sw,conf.sh)
  g.setColor(0,30,63,100)
  g.draw(self.img,self.quad,self.visible:leftTop())
  g.setColor(255,255,255,255)
  g.printf(
    'Level '..self.state.cli..'\nCleared!\nScore:'..self:getGrandScore(),
    0,conf.sh/2-self.fontHeight/2,conf.sw,'center')
end

function Win:keypressed(key, scancode, isrepeat)
  if key == 'space' or key == 'escape' then
    Beholder.trigger('NextLevel')
  end
end

return Win
