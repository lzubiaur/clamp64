local Test = require 'tests.test'
local Entity = require 'entities.base.entity'
local Node = require 'entities.base.node'
local Sprite = require 'entities.base.sprite'
local Button = require 'entities.ui.button'
local Label = require 'entities.ui.label'

local TestUI = Class('TestUI',Test)

function TestUI:initialize(world)
  Test.initialize(self,world)
  self.name = 'Test UI'

  local visible = game.visible

  -- self:setResolution(1200,768)

  local x,y = visible:pointAt(.5,.5)
  local w,h = visible:pointToPixel(90,20)
  Button:new(world, x,y, w,h, {
    text = 'Touch me',
    onSelected = function()
      Log.info('Button touched')
    end
  })

  x,y = visible:pointAt(.5,.6)
  Label:new(world, x,y, 'This is a label.')

end

return TestUI
