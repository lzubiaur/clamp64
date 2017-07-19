-- enemy.lua

local Body = require 'entities.base.body'

local Enemy = Class('Enemy', Body)

function Enemy:initialize(world,x,y)
  local w,h = game.visible:pointToPixel(10,10)
  Body.initialize(self,world,x,y,w,h,{ vx=100,vy=50, zOrder = -1 })
end

function Enemy:update(dt)
  local cx,cy = self:getCenter()
  self:applyVelocity(dt)
  local cols,len = self:move(self.x,self.y,function(self,other)
    return other.class.name == 'Segment' and 'bounce' or nil
  end)
  for i=1,len do
    local n = cols[i].normal
    self:applyCollisionNormal(self.x*n.x,self.y*n.y,1)
  end
end

return Enemy
