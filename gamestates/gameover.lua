local Game = require 'common.game'
local Entity = require 'entities.base.entity'
local Play = require 'gamestates.play'
local Button = require 'entities.ui.button'

local GameOver = Game:addState('GameOver')

function GameOver:enteredState()
  Log.debug('Entered state GameOver')
  self.swallowTouch = true
  local w,h = select(3,self.visible:screen())
  Entity:new(self.world,0,0,w,h,{zOrder=1})

  Button:new(self.world,w/2-45,250,90,40,{
    text = 'Play again',
    onSelected = function()
      self:gotoState('Play')
    end
  })
end

function GameOver:drawAfterCamera()
  g.setColor(255,255,255,255)
  g.printf('Game over!',0,-50+conf.sh/2-self.fontHeight/2,conf.sw,'center')
end

function GameOver:update(dt)
end

function GameOver:keypressed(key, scancode, isrepeat)
  if key == 'space' or key == 'escape' then
    self:gotoState('Play')
  end
end

return GameOver
