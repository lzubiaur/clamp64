-- entities/slowmo.lua

local Entity = require 'entities.base.entity'
local Quad = require 'entities.base.quad'

local SlowMotion = Class('SlowMotion',Entity)

function SlowMotion:initialize(world,x,y,timeout)
  self.timeout = timeout or conf.slowMotionDefaultTimeout
  Entity.initialize(self,world,x,y,game.visible:pointToPixel(6,6))
  local sprite = Quad:new(Assets.img.tilesheet,game:tilesheetFrame(2,9),3,3)
  self:addSprite(sprite)
  Timer.every(0.3,function() sprite.hidden = not sprite.hidden end)
  Beholder.group(self,function()
    Beholder.observe('slowmo',self,function() self:destroy() end)
  end)
end

return SlowMotion
