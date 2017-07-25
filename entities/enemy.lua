-- enemy.lua

local Body = require 'entities.base.body'

local Enemy = Class('Enemy', Body)

function Enemy:initialize(world,x,y)
  local w,h = game.visible:pointToPixel(10,10)
  Body.initialize(self,world,x,y,w,h,{ vx=100,vy=50, zOrder = -1 })
end

function Enemy:filter(other)
  if other.class.name == 'Segment' then
    return 'bounce'
  elseif other.class.name == 'Player' then
    return 'touch'
  end
  return nil
end

function Enemy:update(dt)
  local cx,cy = self:getCenter()
  self:applyVelocity(dt)
  local cols,len = self:move(self.x,self.y,Enemy.filter)
  for i=1,len do
    local other = cols[i].other
    if other.class.name == 'Segment' then
      local n = cols[i].normal
      self:applyCollisionNormal(self.x*n.x,self.y*n.y,1)
    elseif other.class.name == 'Player' then
      Beholder.trigger('GameOver',self)
    end
  end
end

return Enemy
