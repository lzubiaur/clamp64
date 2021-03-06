-- hud/base.lua

local Entity = require 'entities.base.entity'
local Node = require 'entities.base.node'

local HUD = Class('HUD'):include(Stateful)

function HUD:initialize()
  self.world = Bump.newWorld(conf.cellSize)
  self.node = Node:new(game.visible:screen())
  self.timer = Timer.new()
end

function HUD:destroy()
  -- no need to call stopObserving(swallowLayer) because Entity:destroy
  -- do it automatically
  self.timer:clear()
end

function HUD:createSwallowTouchLayer(f)
  self.swallowTouch = true
  local x,y,w,h = game.visible:screen()
  self.swallowLayer = Entity:new(self.world,x,y,w,h)
  if f then
    Beholder.group(self.swallowLayer,function()
      Beholder.observe('Released',self.swallowLayer,f)
    end)
  end
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
  self.timer:update(dt)
  self.node:update(dt)
end

return HUD
