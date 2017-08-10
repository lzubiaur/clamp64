-- entities/bullet.lua

local Body = require 'entities.base.body'
local Quad = require 'entities.base.quad'

local Bullet = Class('Bullet',Body)

function Bullet:initialize(world,x,y,dx,dy)
  self.dx,self.dy = dx,dy
  self:addSprite(Quad:new(Assets.img.tilesheet,game:tilesheetFrame(6,4)))
  Body.initialize(self,world,x,y,1,1,{
    vx = dx*conf.bulletVelocity, vy = dy*conf.bulletVelocity,
    busy = true,
    zOrder = 2,
  })
  Beholder.group(self,function()
    self:observeOnce('lose',function()
      self:destroy()
    end)
  end)
end

function Bullet:filter(other)
  if other.class.name == 'Player' and not other.isInvincible then
    return 'touch'
  end
  return nil
end

function Bullet:update(dt)
  self:applyVelocity(dt)
  local items,len = self:move(self.x,self.y,Bullet.filter)
  if self:isOutsideVisibleScreen() then
    self:destroy()
  end
  if len > 0 then
    Beholder.trigger('killed')
  end
end

-- function Bullet:draw()
--   g.setColor(255,255,255,255)
--   g.line(self.x+3*self.dx,self.y+3*self.dy,self.x-3*self.dx,self.y-3*self.dy)
-- end

return Bullet
