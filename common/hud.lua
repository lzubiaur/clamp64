local Button = require 'entities.ui.button'
local ImageButton = require 'entities.ui.imagebutton'

local Game = Class('Game'):include(Stateful)

local HUD = Class('HUD')

function HUD:initialize(world,opt)
  opt = opt or {}
  -- Quit gameplay (goto main menu)
  self.back = ImageButton:new(world,0,0,{
    path = 'resources/img/arrow-left.png',
    onSelected = function()
      Beholder.trigger('GotoMainMenu')
    end
  })
  Beholder.group(self,function()
    Beholder.observe('Win',function()
      self.back.hidden = true
    end)
  end)
end

function HUD:draw()
  -- g.setColor(to_rgb(palette.text))
  -- g.printf('Level '..self.currentLevel,0,0,conf.width,'center')
end

function HUD:update(dt)
end

return HUD
