-- imagebutton.lua

local Entity = require 'entities.base.entity'
local Button = require 'entities.ui.button'

local ImageButton = Class('ImageButton',Button)

function ImageButton:initialize(world,x,y,opt)
  ort = opt or {}
  if opt.path then
    self.image = g.newImage(opt.path)
  elseif opt.image then
    self.image = opt.image
  else
    error('Path or image missing')
  end
  Button.initialize(self,world,x,y,self.image:getWidth(),self.image:getHeight(),opt)
end

function ImageButton:draw()
  g.setColor(self.shadowColor)
  g.draw(self.image,self.x,self.y+self.os)
  g.setColor(self.color)
  g.draw(self.image,self.x,self.y+self.oy)
end

return ImageButton
