-- entities/barrier.lua

local Entity = require 'entities.base.entity'

local Barrier = Class('Barrier',Entity)

function Barrier:initialize(world,x,y,w,h)
  Entity.initialize(self,world,x,y,w,h)
end

return Barrier
