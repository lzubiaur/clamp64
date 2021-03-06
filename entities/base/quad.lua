-- quad.lua
local Node = require 'entities.base.node'

local Quad = Class('Quad',Node)

function Quad:initialize(image,quad,x,y,opt)
  self.image,self.quad = image,quad
  local w,h = select(3,quad:getViewport())
  Node.initialize(self,x,y,w,h,opt)
end

function Quad:draw()
  g.setColor(self.color)
  g.draw(self.image,self.quad,self.x,self.y,self.angle,self.sx,self.sy,self.w*self.ax,self.h*self.ay,self.kx,self.ky)
  Node.draw(self)
end

return Quad
