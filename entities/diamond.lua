-- entities/diamond.lua

local Entity = require 'entities.base.entity'
local Quad = require 'entities.base.quad'

local Diamond = Class('Diamond',Entity)

function Diamond:initialize(world,x,y,w,h)
  Entity.initialize(self,world,x,y,8,8)
  local quad = Quad:new(Assets.img.tilesheet,game:tilesheetFrame(2,8))
  self:addSprite(quad)
  local timer = Timer.every(.3,function() quad:setVisible(not quad:isVisible()) end)
  Beholder.group(self,function()
    Beholder.observe('diamond',self,function()
      Timer.cancel(timer)
      love.audio.play(Assets.sounds.sfx_coin_cluster3)
      self:destroy()
    end)
  end)
end

return Diamond
