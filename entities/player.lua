-- player.lua

local Body = require 'entities.base.body'
local Quad = require 'entities.base.quad'
local Ground = require 'entities.ground'
local Animated = require 'entities.base.animated'
local Node = require 'entities.base.node'

local Player = Class('Player', Body):include(Stateful)

function Player:initialize(world, x,y)
  Lume.extend(self, {
    velocity = conf.playerVelocity,
    moved = false,
    polygons = {},
  })
  local w,h = game.visible:pointToPixel(8,6)
  Body.initialize(self, world, x,y, w,h, { vx = 0, vy = 0, zOrder = 3} )

  -- Create an empty node so sprites/animations added later
  --  can be "zOrdered" (e.g. blink)
  self.ship = self:addSprite(Node:new(4,4,12,12))

  -- engine animation
  -- local anim = Animated:new(Assets.img.tilesheet,0,0,12,12)
  -- anim:setAnimation(game.tilesheetGrid('1-3',7),.1)
  -- self.ship:addChild(anim)

  self.ship:addChild(Quad:new(Assets.img.tilesheet,game:tilesheetFrame(5,7)))

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
    Beholder.observe('slowmo',function()
      self.velocity = self.velocity / 2
      self.vx = self.vx / 2
      self.vy = self.vy / 2
    end)
    Beholder.observe('normalSpeed',function()
      self.velocity = conf.playerVelocity
      self.vx = self.vx * conf.slowMotionScale
      self.vy = self.vy * conf.slowMotionScale
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
  self:warnForCloseEnemies()
  Body.update(self,dt)
end

function Player:collisionsFilter(other)
  if other.class.name == 'Segment' then
    return other.isPolygonEdge and 'cross' or 'touch'
  elseif other.class.name == 'Xup' or other.class.name == 'Diamond' or other.class.name == 'SlowMotion' then
    return 'cross'
  elseif other.class.name == 'Cannon' or other.class.name == 'Barrier' then
    return 'touch'
  end
  return nil
end

function Player:handleCollisions(cx,cy)
  local cols,len = self:move(self.x,self.y,self.collisionsFilter)
  for _,col in ipairs(cols) do
    local other = col.other
    if other.isBoundEdge or other.class.name == 'Cannon' or other.class.name == 'Barrier' then
      return
    elseif other.class.name == 'Xup' then
      Beholder.trigger('xup',other)
      return
    elseif other.class.name == 'SlowMotion' then
      Beholder.trigger('slowmo',other,other.timeout)
      return
    elseif other.class.name == 'Diamond' then
      if not other.isTouched then
        -- Diamonds are not destroy immediately so the event might be called more than once
        other.isTouched = true
        Beholder.trigger('diamond',other)
      end
      return
    end
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

function Player:warnForCloseEnemies()
  local items,len = self.world:queryRect(self.x-50,self.y-50,self.x+self.w+100,self.y+self.h+100,function(item) return item.class.name == 'Enemy' end)
  local warnings,count = {},0
  for i=1,len do
    local other,cx,cy = items[i],self:getCenter()
    if other:isOutsideVisibleScreen() then
      count = count + 1
      table.insert(warnings,{other:getCenter()})
    end
  end
  if count > 0 then
    local cx,cy = self:getCenter()
    Beholder.trigger('warning',cx,cy,warnings,count)
  end
end

function Player:addExplosion()
  local anim = Animated:new(Assets.img.tilesheet,4,4,12,12)
  anim:setAnimation(game.tilesheetGrid('4-6',1,4,6),.1,function()
    -- anim.animation:pause()
    anim:setVisible(false)
    Timer.after(0.2,function() Beholder.trigger('lose') end)
    self:destroy()
  end)
  self.ship:setVisible(false)
  self:addSprite(anim)
end

return Player
