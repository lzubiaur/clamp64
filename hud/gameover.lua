-- hud/gameover.lua

local HUD = require 'hud.base'
local ImageButton = require 'entities.ui.imagebutton'

local Gameover = HUD:addState('Gameover')

function Gameover:enteredState()
  -- Quit gameplay (goto main menu)
  self.back = ImageButton:new(self.world,0,0,{
    os = 1, oy = 1,
    image = Assets.img.menu,
    onSelected = function()
      Beholder.trigger('GotoMainMenu')
    end
  })
  self.back:setVisible(false)
  Beholder.group(self,function()
    Beholder.observe('Win',function()
      self.back.hidden = true
    end)
  end)
end

function Gameover:exitedState()
end

return Gameover
