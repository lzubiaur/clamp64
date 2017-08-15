-- Label.lua

local Entity = require 'entities.base.entity'

local Label = Class('Label',Entity):include(Stateful)

function Label:initialize(world, x,y, text, opt)
  opt = opt or {}
  opt.zOrder = opt.zOrder or 10
  self.text = text or 'label'
  self.color = opt.color or {to_rgb(palette.text)}
  self.sx,self.sy = opt.sx or 1,opt.sy or 1

  -- XXX width and height can be wrong if new lines are created when text is aligned
  local w = 0
  if type(text) == 'table' then
    for i=2,#self.text,2 do
      w = w + g.getFont():getWidth(self.text[i])
    end
  else
    w = g.getFont():getWidth(self.text)
  end
  local h = g.getFont():getHeight()
  self.limit = opt.limit or w

  self.shadowColor = {53,58,80,255}

  Entity.initialize(self,world, x,y, w,h, opt)
end

function Label:draw()
  -- self:drawBoundingBox()
  g.setColor(self.shadowColor)
  g.printf(self.text,self.x+1,self.y+1-self.h/2,self.limit,'center',0,self.sx,self.sy)
  g.setColor(self.color)
  g.printf(self.text,self.x,self.y-self.h/2,self.limit,'center',0,self.sx,self.sy)
end

return Label
