local Test = require 'tests.test'
local Entity = require 'entities.base.entity'
local Node = require 'entities.base.node'
local Sprite = require 'entities.base.sprite'

local TouchTest = Class('TouchTest',Test)

function TouchTest:initialize(world)
  Test.initialize(self,world)
  self.name = 'Test touch on entity'

  local ax,ay
  local entity = Entity:new(world,200,200,50,50)
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

return TouchTest
