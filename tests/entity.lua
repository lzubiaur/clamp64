-- tests.lua
local Test = require 'tests.test'
local Entity = require 'entities.base.entity'
local Node = require 'entities.base.node'
local Sprite = require 'entities.base.sprite'

local EntityTest = Class('EntityTest',Test)

function EntityTest:initialize(world)
  Log.info('Entered state tests')
  self.name = 'Test entity and sprite'

  self:setResolution(960,540)

  -- Add children
  local parent = Entity:new(world,200,200,50,50,{angle=45})

  Timer.script(function(wait)
    wait(.5)
    local child = Entity:new(world,250,250,20,20)
    parent:addChild(child)
    wait(.5)
    parent:teleport(300,300)
    wait(.5)
    parent:setVisible(false)
    wait(.5)
    parent:setVisible(true)
    wait(.5)
    parent:removeChild(child)
    parent:teleport(200,200)

    wait(.5)
    local s1 = Sprite:new('resources/img/gamepad.png',0,0)
    parent:addSprite(s1)
    wait(.5)
    parent:setPosition(200,100)
    wait(.5)
    parent:setVisible(false)
    wait(.5)
    parent:setVisible(true)

    wait(.5)
    local s2 = Sprite:new('resources/img/undo.png',10,10)
    s2:setColor{0,0,255,255}
    s1:addChild(s2)
    wait(.5)
    s1:removeChild(s2)
    wait(.5)
    parent:removeSprite(s1)
    wait(.5)
    parent:destroy()
  end)

end

return EntityTest
