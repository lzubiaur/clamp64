-- sprite.lua
local Node = require 'entities.base.node'

local Sprite = Class('Sprite',Node)

function Sprite:initialize(image,x,y,opt)
  opt = opt or {}
  self.color = opt.color or {255,255,255,255}
  self.img = assert(g.newImage(filename))
  Node.initialize(self,x,y,self.img:getWidth(),self.img:getHeight(),opt)
end

function Sprite:draw()
  g.setColor(self.color)
  g.draw(self.img,self.x,self.y,self.angle,self.sx,self.sy,self.w*self.ax,self.h*self.ay)
  Node.draw(self)
end

return Sprite
