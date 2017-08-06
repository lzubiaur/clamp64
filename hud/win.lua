-- hud/win.lua

local HUD = require 'hud.base'
local ImageButton = require 'entities.ui.imagebutton'

local Win = HUD:addState('Win')

function Win:enteredState()
  -- Quit gameplay (goto main menu)
  self.back = ImageButton:new(self.world,0,0,{
    os = 1, oy = 1,
    image = Assets.img.menu,
    onSelected = function()
      print 'debug'
      Beholder.trigger('GotoMainMenu')
    end
  })
end

function Win:exitedState()
  self.back:destroy()
end

return Win
