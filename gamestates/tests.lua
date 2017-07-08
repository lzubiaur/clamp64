-- teststate.lua
local Game = require 'common.game'
local Test = require 'tests.test'
local EntityTest = require 'tests.entity'
local TouchTest = require 'tests.touch'
local TestStates = require 'tests.states'
local TestMultiRes = require 'tests.multires'
local TestUI = require 'tests.ui'

local TestState = Game:addState('TestState')

local tests = { EntityTest, TouchTest, TestUI, TestMultiRes, TestStates }

function TestState:enteredState()
  if not self.testid then self.testid = 1 end
  Log.info('Run test',self.testid)
  self:createWorld()
  self:createCamera()

  self.test = tests[self.testid]:new(self.world)
end

function TestState:update(dt)
  Game.update(self,dt)
  self.test:update(dt)
end

function TestState:drawAfterCamera(l,t,w,h)
  self.test:draw(l,t,w,h)
end

function TestState:keypressed(key, scancode, isrepeat)
  if key == 'space' then
    if self.testid < #tests then
      self.testid = self.testid + 1
    else
      self.testid = 1
    end
    self:gotoState('TestState')
  elseif key == 'escape' then
    love.event.push('quit')
  end
end

return TestState
