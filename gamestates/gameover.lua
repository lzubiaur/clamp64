local Game = require 'common.game'
local Entity = require 'entities.base.entity'
local Play = require 'gamestates.play'
local Button = require 'entities.ui.button'

local GameOver = Game:addState('GameOver')

function GameOver:enteredState()
  Log.debug('Entered state GameOver')
  -- local cx,cy = self.visible:center()
  -- w,h = self.visible:pointToPixel(30,16)
  -- Button:new(self.hud.world,cx,cy,w,h,{
  --   text = 'Play again',
  --   onSelected = function()
  --     self:gotoState('Play')
  --   end
  -- })
  self.hud:gotoState('Gameover')
end

function GameOver:exitedState()
  self.hud:popState()
  self:collectGarbage()
end

function GameOver:drawAfterCamera()
  g.setColor(255,241,232,255)
  g.printf('Gameover',0,conf.sh/2-self.fontHeight/2,conf.sw,'center')
end

-- function GameOver:released()
--   self:gotoState('Start')
-- end

-- function GameOver:update(dt)
-- end

function GameOver:keypressed(key, scancode, isrepeat)
  if key == 'space' or key == 'escape' then
    self:gotoState('Start')
  end
end

return GameOver
