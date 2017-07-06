-- teststate.lua
local Game = require 'common.game'
local Test = require 'tests.test'
local EntityTest = require 'tests.entity'
local TouchTest = require 'tests.touch'

local TestState = Game:addState('TestState')

local tests = { EntityTest, TouchTest }

function TestState:enteredState()
  if not self.testid then self.testid = 1 end
  Log.info('Run test',self.testid)
  self:createWorld()
  self:createCamera(conf.width,conf.height)

  self.test = tests[self.testid]:new(self.world)
end

function TestState:update(dt)
  Game.update(self,dt)
  self.test:update(dt)
end

function TestState:drawAfterCamera()
  self.test:draw(0,0,conf.width,conf.height)
end

function TestState:keypressed(key, scancode, isrepeat)
  if key == 'space' then
    if self.testid < #tests then
      self.testid = self.testid + 1
    else
      self.testid = 1
    end
    self:gotoState('TestState')
  end
end

return TestState
