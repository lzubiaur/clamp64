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

  -- local cx,cy = self.visible:center()
  -- w,h = self.visible:pointToPixel(30,16)
  -- Button:new(self.hud.world,cx,cy,w,h,{
  --   text = 'Play again',
  --   onSelected = function()
  --     self:gotoState('Play')
  --   end
  -- })
end

function GameOver:drawAfterCamera()
  g.setColor(255,255,255,255)
  local x,y = self.visible:center()
  local img = Assets.img.gameover
  g.draw(img,x-img:getWidth()/2,y)
end

function GameOver:pressed()
  self:gotoState('Play')
end

-- function GameOver:update(dt)
-- end

function GameOver:keypressed(key, scancode, isrepeat)
  if key == 'space' or key == 'escape' then
    self:gotoState('Play')
  end
end

return GameOver
