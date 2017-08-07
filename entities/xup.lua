-- xup.lua (1-up)

local Entity = require 'entities.base.entity'

local Xup = Class('Xup',Entity)

function Xup:initialize(world,x,y)
  Entity.initialize(self,world,x,y,game.visible:pointToPixel(8,8))
end

return Xup
