-- xup.lua (1-up)

local Entity = require 'entities.base.entity'
local Quad = require 'entities.base.quad'

local Xup = Class('Xup',Entity)

function Xup:initialize(world,x,y)
  Entity.initialize(self,world,x,y,game.visible:pointToPixel(8,8))
  local sprite = Quad:new(Assets.img.tilesheet,game:tilesheetFrame(1,3),4,4)
  self:addSprite(sprite)
  Timer.every(0.3,function() sprite.hidden = not sprite.hidden end)
  Beholder.group(self,function()
    Beholder.observe('xup',self,function() self:destroy() end)
  end)
end

return Xup
