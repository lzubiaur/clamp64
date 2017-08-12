-- animated.lua
local Node = require 'entities.base.node'

local Animated = Class('Animated',Node)

function Animated:initialize(image,x,y,w,h,opt)
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
  g.setColor(self.color)
  self.animation:draw(self.image,self.x,self.y,self.angle,self.sx,self.sy,self.w*self.ax,self.h*self.ay)
  Node.draw(self)
end

function Animated:pauseAtEnd()
  self.animation:pauseAtEnd()
end

function Animated:pauseAtStart()
  self.animation:pauseAtStart()
end

function Animated:pause()
  self.animation:pause()
end

function Animated:resume()
  self.animation:resume()
end

function Animated:gotoFrame(i)
  self.animation:gotoFrame(i)
end

return Animated
