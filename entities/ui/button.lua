-- button.lua

local Entity = require 'entities.base.entity'

local Button = Class('Button',Entity):include(Stateful)

function Button:initialize(world, x,y, w,h, opt)
  opt = opt or {}
  opt.zOrder = opt.zOrder or 10
  Entity.initialize(self,world, x,y, w,h, opt)

  local defaultOffsetY = game.visible:pointToPixel(opt.oy or 5)
  self.corner = game.visible:pointToPixel(opt.corner or 10)
  self.oy,self.os = game.visible:pointToPixel(0,opt.os or 7) -- offset
  self.text = opt.text or ''
  local onSelected = opt.onSelected or function() print 'Button pressed' end
  self.textColor = opt.textColor or {to_rgb(palette.text)}
  self.color = opt.color or { to_rgb(palette.main) }
  self.shadowColor = rgb_to_color(unpack(self.color)):lighten_by(.7)
  self.shadowColor = { to_rgb(self.shadowColor) }

  Beholder.group(self,function()
    Beholder.observe('Pressed',self,function()
      self.oy = defaultOffsetY
    end)
    Beholder.observe('Moved',self,function(x,y)
      if not self:containsPoint(x,y) then
        self.oy = 0
      else
        self.oy = defaultOffsetY
      end
    end)
    Beholder.observe('Released',self,function(x,y)
      if self:containsPoint(x,y) then onSelected(self) end
      self.oy = 0
    end)
  end)
end

function Button:draw()
  g.setColor(unpack(self.shadowColor))
  g.rectangle('fill',self.x,self.y+self.os,self.w,self.h,self.corner)
  g.setColor(unpack(self.color))
  g.rectangle('fill',self.x,self.y+self.oy,self.w,self.h,self.corner)
  g.setColor(unpack(self.textColor))
  local h = g.getFont():getHeight()/2
  g.printf(self.text,self.x,self.y+self.h/2-h+self.oy,self.w,'center')
end

return Button
