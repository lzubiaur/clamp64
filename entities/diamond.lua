-- entities/diamond.lua

local Entity = require 'entities.base.entity'
local Quad = require 'entities.base.quad'

local Diamond = Class('Diamond',Entity)

function Diamond:initialize(world,x,y,w,h)
  Entity.initialize(self,world,x,y,8,8)
  local quad = Quad:new(Assets.img.tilesheet,game:tilesheetFrame(2,8),4,4)
  self:addSprite(quad)
  local timer = Timer.every(.3,function() quad:setVisible(not quad:isVisible()) end)
  Beholder.group(self,function()
    Beholder.observe('diamond',self,function()
      if not self.tween then
        quad:setVisible(true)
        Timer.cancel(timer)
        love.audio.play(Assets.sounds.sfx_coin_cluster3)
        self.tween = Tween.new(.8,quad,{sx=3,sy=3,color={255,255,255,0}})
      end
    end)
  end)
end

function Diamond:update(dt)
  if self.tween and self.tween:update(dt) then
    self:destroy()
  end
end

return Diamond
