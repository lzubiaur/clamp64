local Test = require 'tests.test'
local Entity = require 'entities.base.entity'
local Node = require 'entities.base.node'
local Sprite = require 'entities.base.sprite'
local Label = require 'entities.ui.label'

local TouchTest = Class('TouchTest',Test)

local function createTouchEntity(world,x,y)
  local ax,ay
  local entity = Entity:new(world,x,y,60,50)

  entity:addChild(Label:new(world,x,y+20,'drag me'))

  Beholder.observe('Pressed',entity,function(x,y)
    ax,ay = entity:getLocalPoint(x,y)
    Log.info('pressed',x,y)
  end)

  Beholder.observe('Moved',entity,function(x,y,dx,dy)
    entity:teleport(x-ax,y-ay)
  end)

  Beholder.observe('Released',entity,function(x,y)
    Log.info('released',x,y)
  end)
end

function TouchTest:initialize(world)
  Test.initialize(self,world)
  self.name = 'Test touch on entity'
  createTouchEntity(world,100,100)
  createTouchEntity(world,200,150)
end

return TouchTest
