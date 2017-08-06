-- hud/base.lua

local Entity = require 'entities.base.entity'
local Node = require 'entities.base.node'

local HUD = Class('HUD'):include(Stateful)

function HUD:initialize()
  self.world = Bump.newWorld(conf.cellSize)
  self.node = Node:new(game.visible:screen())
end

function HUD:destroy()
  Beholder.stopObserving(self)
end

function HUD:createSwallowTouchLayer()
  self.swallowTouch = true
  local x,y,w,h = game.visible:screen()
  self.swallowLayer = Entity:new(self.world,x,y,w,h)
end

function HUD:removeSwallowTouchLayer()
  if self.swallowLayer then
    self.swallowTouch = false
    self.swallowLayer:destroy()
  end
end

function HUD:draw(l,t,w,h)
  local items,len = self.world:queryRect(l,t,w,h)
  table.sort(items,Entity.sortByZOrderAsc)
  for i=1,len do
    if not items[i].hidden then
      items[i]:draw()
    end
  end
  self.node:draw()
end

function HUD:update(dt)
end

return HUD
