-- body.lua
-- Physic entity

local Entity = require 'entities.base.entity'

local Body = Class('Body',Entity)

function Body:initialize(world,x,y,w,h,opt)
  opt = opt or {}
  Lume.extend(self,{
    mx = opt.mx or 800, my = opt.my or 800, -- maximum velocity
    vx = opt.vx or 0, vy = opt.vy or 0, -- current velocity
    mass = opt.mass or 1,
  })
  Entity.initialize(self,world,x,y,w,h,opt)
end

function Body:applyGravity(dt)
  self.vy = self.vy + self.mass * conf.gravity * dt
  return self.vy
end

function Body:applyVelocity(dt)
  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt
end

function Body:clampVelocity()
  -- self.vx = Lume.sign(self.vx) * Lume.clamp(math.abs(self.vx), 0, self.mx)
  -- self.vy = Lume.sign(self.vy) * Lume.clamp(math.abs(self.vy), 0, self.my)
  self.vx = Lume.clamp(self.vx, -self.mx, self.mx)
  self.vy = Lume.clamp(self.vy, -self.my, self.my)
end

-- code from bump.lua demo
function Body:applyCollisionNormal(nx, ny, bounciness)
  bounciness = bounciness or 0
  local vx, vy = self.vx, self.vy

  if (nx < 0 and vx > 0) or (nx > 0 and vx < 0) then
    vx = -vx * bounciness
  end

  if (ny < 0 and vy > 0) or (ny > 0 and vy < 0) then
    vy = -vy * bounciness
  end

  self.vx, self.vy = vx, vy
end

return Body
