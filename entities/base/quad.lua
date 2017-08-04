-- sprite.lua
local Node = require 'entities.base.node'

local Quad = Class('Quad',Node)

function Quad:initialize(image,quad,x,y,opt)
  opt = opt or {}
  self.color = opt.color or {255,255,255,255}
  self.image,self.quad = image,quad
  local w,h = select(3,quad:getViewport())
  Node.initialize(self,x,y,w,h,opt)
end

function Quad:draw()
  Node.draw(self)
  g.setColor(self.color)
  g.draw(self.image,self.quad,self.x,self.y,self.angle,1,1,self.w*self.ax,self.h*self.ay)
  self:drawBoundingBox({0,255,0,255})
end

return Quad
