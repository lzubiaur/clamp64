-- Label.lua

local Entity = require 'entities.base.entity'

local Label = Class('Label',Entity):include(Stateful)

function Label:initialize(world, x,y, text, opt)
  opt = opt or {}
  opt.zOrder = opt.zOrder or 10
  self.text = text or 'label'
  self.color = opt.color or {to_rgb(palette.text)}

  local w = g.getFont():getWidth(self.text)
  local h = g.getFont():getHeight()
  self.limit = opt.limit or w

  Entity.initialize(self,world, x,y, w,h, opt)
end

function Label:draw()
  -- self:drawBoundingBox()
  g.setColor(self.color)
  g.printf(self.text,self.x,self.y-self.h/2,self.limit,'center')
end

return Label
