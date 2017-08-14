-- enemy.lua

local Body = require 'entities.base.body'
local Quad = require 'entities.base.quad'

local Enemy = Class('Enemy', Body)

function Enemy:initialize(world,x,y,opt)
  opt = opt or {}
  opt.dx = opt.dx or 1 -- default direction
  opt.dy = opt.dy or 1
  local w,h = game.visible:pointToPixel(8,8)
  Body.initialize(self,world,x,y,w,h,{ vx=opt.dx*conf.enemyVelocity,vy=opt.dy*conf.enemyVelocity, zOrder = -1, busy=conf.sleepingEnemies })
  local s = Assets.img.tilesheet
  local quad = g.newQuad(12,0,12,12,s:getDimensions())
  self:addSprite(Quad:new(s,quad,6,6))

  self.quad2 = Quad:new(s,g.newQuad(24,0,12,12,s:getDimensions()),6,6,{ax=.5,ay=.5})
  self:addSprite(self.quad2)
  Beholder.group(self,function()
    Beholder.observe('killed',function()
      self.killed = true
    end)
    Beholder.observe('start',function()
      self.killed= false
    end)
    Beholder.observe('slowmo',function()
      self.vx = self.vx / conf.slowMotionScale
      self.vy = self.vy / conf.slowMotionScale
    end)
    Beholder.observe('normalSpeed',function()
      self.vx = self.vx * conf.slowMotionScale
      self.vy = self.vy * conf.slowMotionScale
    end)
  end)
end

function Enemy:filter(other)
  if other.class.name == 'Segment' or other.class.name == 'Barrier' then
    return 'bounce'
  elseif other.class.name == 'Player' then
    if self.killed or other.isInvincible then return nil end
    return 'cross'
  end
  return nil
end

function Enemy:update(dt)
  self.quad2.angle = self.quad2.angle + 10 * dt
  local cx,cy = self:getCenter()
  self:applyVelocity(dt)
  local cols,len = self:move(self.x,self.y,Enemy.filter)
  for i=1,len do
    local other = cols[i].other
    if other.class.name == 'Segment' or other.class.name == 'Barrier' then
      local n = cols[i].normal
      self:applyCollisionNormal(self.x*n.x,self.y*n.y,1)
    elseif other.class.name == 'Player' then
      Beholder.trigger('killed',self)
    end
  end
end

return Enemy
