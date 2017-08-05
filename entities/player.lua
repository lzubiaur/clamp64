-- player.lua

local Body = require 'entities.base.body'
local Quad = require 'entities.base.quad'
local Ground = require 'entities.ground'
local Animated = require 'entities.base.animated'
local Node = require 'entities.base.node'

local Player = Class('Player', Body):include(Stateful)

function Player:initialize(world, x,y)
  Lume.extend(self, {
    velocity = 50,
    moved = false,
    polygons = {},
  })
  local w,h = game.visible:pointToPixel(8,6)
  Body.initialize(self, world, x,y, w,h, { vx = 0, vy = 0, zOrder = 3} )

  -- Create an empty node so sprites/animations added later
  --  can be "zOrdered" (e.g. blink)
  self.ship = self:addSprite(Node:new(4,4,10,10))

  local quad = g.newQuad(0,0,10,10,Assets.img.tilesheet:getDimensions())
  self.ship:addChild(Quad:new(Assets.img.tilesheet,quad,0,0))
  self:createEventHandlers()
end

function Player:createEventHandlers()
  Beholder.group(self,function()
    Beholder.observe('ResetGame',function()
      self:onResetGame()
    end)
    Beholder.observe('right',function()
      if self.vx > -1 then self.vx,self.vy,self.moved,self.ship.angle = self.velocity,0,true,math.rad(90) end
    end)
    Beholder.observe('left',function()
      if self.vx < 1 then self.vx,self.vy,self.moved,self.ship.angle = -self.velocity,0,true,math.rad(270) end
    end)
    Beholder.observe('up',function()
      if self.vy < 1 then self.vx,self.vy,self.moved,self.ship.angle = 0,-self.velocity,true,0 end
    end)
    Beholder.observe('down',function()
      if self.vy > -1 then self.vx,self.vy,self.moved,self.ship.angle = 0,self.velocity,true,math.rad(180) end
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
    return other.isPolygonEdge and 'cross' or 'touch'
  end
  return nil
end

function Player:handleCollisions(cx,cy)
  local cols,len = self:move(self.x,self.y,self.collisionsFilter)
  for _,col in ipairs(cols) do
    local other = col.other
    if other.isBoundEdge then return end
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
  local anim = Animated:new(Assets.img.tilesheet,5,5,10,10)
  anim:setAnimation(game.tilesheetGrid('4-6',1),.1,function()
    -- anim.animation:pause()
    anim:setVisible(false)
    Beholder.trigger('lose')
    self:destroy()
  end)
  self.ship:setVisible(false)
  self:addSprite(anim)
end

return Player
