-- multires.lua
local Test = require 'tests.test'
local Entity = require 'entities.base.entity'
local Node = require 'entities.base.node'
local Sprite = require 'entities.base.sprite'
local Label = require 'entities.ui.label'

local describe, it, expect = Lust.describe, Lust.it, Lust.expect

local TestMultiRes = Class('TestMultiRes',Test)

function TestMultiRes:initialize(world)
  self.name = 'Test multi resolution'

  describe('multi resolution support',function()

    it('scales resolution',function()
      love.window.setMode(1024,768)
      setupMultiResolution()
      game:createCamera()
      expect(conf.resolution).to.equal('medium')
      local w,h = game.visible:size()
      expect(w).to.equal(800)
      expect(h).to.equal(480)
      Entity:new(world,game.visible:screen())
    end)

    it('converts from point to pixel', function()
      local x,y = game.visible:pointToPixel(320,180)
      expect(x).to.equal(400)
      expect(y).to.equal(240)
      local w,h = game.visible:size()
      expect(w).to.equal(800)
      expect(h).to.equal(480)
    end)

  end)

end

return TestMultiRes
