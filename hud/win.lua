-- hud/win.lua

local HUD = require 'hud.base'
local ImageButton = require 'entities.ui.imagebutton'

local Win = HUD:addState('Win')

function Win:enteredState()
  self:createSwallowTouchLayer()
  -- Quit gameplay (goto main menu)
  self.back = ImageButton:new(self.world,0,0,{
    os = 1, oy = 1,
    image = Assets.img.menu,
    onSelected = function()
      Beholder.trigger('GotoMainMenu')
      self:popState()
    end,
    color = {255,255,255,255}
  })
end

function Win:exitedState()
  self:removeSwallowTouchLayer()
  self.back:destroy()
end

return Win
