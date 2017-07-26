-- states.lua

local Test = require 'tests.test'
local Entity = require 'entities.base.entity'
local Node = require 'entities.base.node'
local Sprite = require 'entities.base.sprite'
local Label = require 'entities.ui.label'

local describe, it, expect = Lust.describe, Lust.it, Lust.expect

local TestStates = Class('TestStates',Test)

function TestStates:initialize(world)
  self.name = 'Test states'

  describe('game states',function()
  end)
end

return TestStates
