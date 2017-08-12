-- entities/base/colorlayer.lua

local Node = require 'entities.base.node'

local ColorLayer = Class('ColorLayer',Node)

function ColorLayer:initialize(x,y,w,h,opt)
  Node.initialize(self,x,y,w,h,opt)
end

function ColorLayer:draw()
  g.setColor(self.color)
  g.rectangle('fill',self.x,self.y,self.w,self.h)
end

return ColorLayer
