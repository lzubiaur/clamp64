local Game = require 'common.game'
local Entity = require 'entities.base.entity'
local Play = require 'gamestates.play'
local Button = require 'entities.ui.button'

local Gameover = Game:addState('Gameover')

function Gameover:enteredState()
  Log.debug('Entered state Gameover')
  self.swallowTouch = true
  Entity:new(self.world,0,0,conf.width,conf.height,{zOrder=1})

  Button:new(self.world,conf.width/2-45,250,90,40,{
    text = 'Play again',
    onSelected = function()
      self:gotoState('Play')
    end
  })
end

function Gameover:drawAfterCamera()
  g.setColor(30,30,30,180)
  g.rectangle('fill',0,conf.height/2-30,conf.width,60)
  g.setColor(255,255,255,255)
  g.printf('Game over!',0,-50+conf.height/2-self.fontHeight/2,conf.width,'center')
  g.printf('Meilleur score: '..self.state.highscore,0,conf.height/2-self.fontHeight/2,conf.width,'center')
end

function Gameover:update(dt)
end

function Gameover:keypressed(key, scancode, isrepeat)
  if key == 'space' or key == 'escape' then
    self:gotoState('Play')
  end
end

return Gameover
