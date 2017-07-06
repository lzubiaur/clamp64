-- teststate.lua
local Game = require 'common.game'
local Test = require 'tests.test'
local TestEntity = require 'tests.testentity'

local Teststate = Game:addState('Teststate')

function Teststate:enteredState()
  Log.info('Entered state tests')
  self:createWorld()
  self:createCamera(conf.width,conf.height)

  self.test = TestEntity:new(self.world)
end

function Teststate:update(dt)
  self.test:update(dt)
end

function Teststate:drawAfterCamera()
  self.test:draw(0,0,conf.width,conf.height)
end

return Teststate
