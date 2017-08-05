-- animated.lua
local Node = require 'entities.base.node'

local Animated = Class('Animated',Node)

function Animated:initialize(image,x,y,w,h,opt)
  opt = opt or {}
  self.color = opt.color or {255,255,255,255}
  self.image = image
  Node.initialize(self,x,y,w,h,opt)
end

function Animated:setAnimation(frames,durations,onLoop)
  self.animation = Anim8.newAnimation(frames,durations,onLoop)
end

function Animated:update(dt)
  self.animation:update(dt)
end

function Animated:draw()
  Node.draw(self)
  g.setColor(self.color)
  self.animation:draw(self.image,self.x,self.y,self.angle,self.sx,self.sy,self.w*self.ax,self.h*self.ay)
end

return Animated
