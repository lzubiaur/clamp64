-- button.lua

local Entity = require 'entities.base.entity'

local Button = Class('Button',Entity):include(Stateful)

-- Options:
-- corner: round corner size (min 0)
-- onSelected: callback function when button is pressed
-- text
-- textColor
-- color
-- shadowColor
-- oy: vertical offset
-- os: shadow offset
-- sx,sy: text scale factor
-- angle: text angle

function Button:initialize(world, x,y, w,h, opt)
  opt = opt or {}
  opt.zOrder = opt.zOrder or 10
  Entity.initialize(self,world, x,y, w,h, opt)

  self.setEnabled = function(self,value)
    if value then
      self:gotoState('enabled',opt)
    else
      self:gotoState('disabled')
    end
  end

  self:setEnabled(true)
end

function Button:draw()
  g.setColor(self.shadowColor)
  g.rectangle('fill',self.x,self.y+self.os,self.w,self.h,self.corner)
  g.setColor(self.color)
  g.rectangle('fill',self.x,self.y+self.oy,self.w,self.h,self.corner)
  g.setColor(self.textColor)
  local h = g.getFont():getHeight()/2
  g.printf(self.text,self.x,self.y+self.h/2-h+self.oy,self.w,'center',self.a,self.sx,self.sy)
end

-- Normal state

local Enabled = Button:addState('enabled')

function Enabled:enteredState(opt)
  local defaultOffsetY = game.visible:pointToPixel(opt.oy or 5)
  self.corner = game.visible:pointToPixel(opt.corner or 10)
  self.oy,self.os = game.visible:pointToPixel(0,opt.os or 7) -- offset
  self.text = opt.text or ''
  local onSelected = opt.onSelected or function() end
  self.textColor = opt.textColor or {to_rgb(palette.text)}
  self.color = opt.color or { to_rgb(palette.main) }
  self.shadowColor = rgb_to_color(unpack(self.color)):lighten_by(.7)
  self.shadowColor = { to_rgb(self.shadowColor) }
  self.a = opt.angle or 0
  self.sx = opt.sx or 1
  self.sy = opt.sy or 1

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

-- Disabled state

local Disabled = Button:addState('disabled')

function Disabled:enteredState()
  Beholder.stopObserving(self)

  self.color = {60,60,60,255}
  self.shadowColor = {30,30,30,255}
  self.textColor = {120,120,120,255}

  self.shadowColor = rgb_to_color(unpack(self.color)):lighten_by(.7)
  self.shadowColor = { to_rgb(self.shadowColor) }

end

return Button
