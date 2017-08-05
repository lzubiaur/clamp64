-- player.lua

local Body = require 'entities.base.body'
local Quad = require 'entities.base.quad'
local Ground = require 'entities.ground'
local Animated = require 'entities.base.animated'

local Player = Class('Player', Body)

function Player:initialize(world, x,y)
  Lume.extend(self, {
    velocity = 50,
    moved = false,
    polygons = {},
  })
  local w,h = game.visible:pointToPixel(8,6)
  Body.initialize(self, world, x,y, w,h, { vx = 0, vy = 0, zOrder = 3} )

  local s = Assets.img.tilesheet

  local quad = g.newQuad(0,0,8,8,s:getDimensions())
  ship = Quad:new(s,quad,4,4,{ax=0.5,ay=0.5})
  self.ship = self:addSprite(ship)

  Beholder.group(self,function()
    Beholder.observe('ResetGame',function()
      self:onResetGame()
    end)
    Beholder.observe('right',function()
      if self.vx > -1 then self.vx,self.vy,self.moved,ship.angle = self.velocity,0,true,math.rad(90) end
    end)
    Beholder.observe('left',function()
      if self.vx < 1 then self.vx,self.vy,self.moved,ship.angle = -self.velocity,0,true,math.rad(270) end
    end)
    Beholder.observe('up',function()
      if self.vy < 1 then self.vx,self.vy,self.moved,ship.angle = 0,-self.velocity,true,0 end
    end)
    Beholder.observe('down',function()
      if self.vy > -1 then self.vx,self.vy,self.moved,ship.angle = 0,self.velocity,true,math.rad(180) end
    end)
    self:observeOnce('killed',function()
      self:onKilled()
    end)
    Beholder.observe('checkpoint',function(t)
      Lume.push(t,self.x,self.y,self.w,self.h)
    end)
  end)
end

function Player:onResetGame()
  -- Log.info('Reset Player')
end

function Player:onKilled()
  self.vx,self.vy = 0,0
  Beholder.stopObserving(self)
  self.collisionsFilter = function() return nil end
  self:addExplosion()
  love.audio.play(Assets.sounds.explosion)
end

function Player:update(dt)
  local cx,cy = self:getCenter()
  self:applyVelocity(dt)
  self:resetCollisionFlags()
  self:handleCollisions(cx,cy)
  self:handleEndCollisions(cx,cy)
  Body.update(self,dt)
end

function Player:collisionsFilter(other)
  if other.class.name == 'Segment' then
    return 'cross'
  end
end

function Player:handleCollisions(cx,cy)
  local cols,len = self:move(self.x,self.y,self.collisionsFilter)
  for _,col in ipairs(cols) do
    local other = col.other
    local poly,polygons = other.polygon,self.polygons
    -- Check if it's the first time the player collide with
    -- any edges of this polygon
    if not polygons[poly] then
      polygons[poly] = {
        collide = 1,  -- collision flag: -1 previously colliding, >0 collide
        -- path = path
      }
      Beholder.trigger('entered',poly,cx,cy)
    else
      polygons[poly].collide = polygons[poly].collide + 1
    end
  end

end

function Player:handleEndCollisions(cx,cy)
  for poly,t in pairs(self.polygons) do
    local contained = poly:contains(self:getCenter())
    -- if the player no more collide with any polygon edges (-1)
    -- and the player is outside of the polygon
    if t.collide < 0 and not contained then
      Beholder.trigger('leaved',poly,cx,cy)
      self.polygons[poly] = nil
    elseif self.moved then
      Beholder.trigger('moved',poly,cx,cy)
    end
  end
  self.moved = false
end

function Player:resetCollisionFlags()
  for _,t in pairs(self.polygons) do
    t.collide = -1
  end
end

function Player:addExplosion()
  local s = Assets.img.tilesheet
  local anim = Animated:new(s,0,0,10,10)
  local grid = Anim8.newGrid(10,10,s:getWidth(),s:getHeight())
  anim:setAnimation(grid('4-6',1),.1,function()
    -- anim.animation:pause()
    anim:setVisible(false)
    Beholder.trigger('lose')
    self:destroy()
  end)
  self.ship:setVisible(false)
  self:addSprite(anim)
end

return Player
