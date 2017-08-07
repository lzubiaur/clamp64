-- hud/win.lua

local HUD = require 'hud.base'
local Button = require 'entities.ui.button'
local ImageButton = require 'entities.ui.imagebutton'

local Win = HUD:addState('Win')

function Win:enteredState()
  self:createSwallowTouchLayer(function()
    Beholder.trigger('NextLevel')
  end)
  -- Quit gameplay (goto main menu)
  -- self.back = ImageButton:new(self.world,0,0,{
  --   os = 1, oy = 1,
  --   image = Assets.img.quit,
  --   onSelected = function()
  --     Beholder.trigger('GotoMainMenu')
  --     self:popState()
  --   end,
  --   color = {255,255,255,255}
  -- })

  -- Next level button
  -- Button:new(self.world,18,30,28,10,{
  --   os = 1, oy = 1, corner = 4,
  --   text = 'Next',
  --   onSelected = function()
  --     Beholder.trigger('NextLevel')
  --   end,
  -- })

end

function Win:exitedState()
  self:removeSwallowTouchLayer()
  -- self.back:destroy()
end

return Win
