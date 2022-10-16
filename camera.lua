local camera = {}
local window = {}
window.w = love.graphics.getWidth()
window.h = love.graphics.getHeight()

function camera:load()
  self.shakeTimer = 0
  self.shakeCb = nil
  self.x = 0
  self.y = 0
  self.sx = 1
  self.sy = 1
  self.r = 0
end

function camera:set()
  love.graphics.push()
  love.graphics.translate(window.w/2, window.h/2)
  love.graphics.scale(self.sx, self.sy)
  love.graphics.rotate(self.r)
  love.graphics.translate(-window.w/2, -window.h/2)
  love.graphics.translate(-self.x, -self.y)
  if self.shakeCb ~= nil and self.shakeTimer > 0 then
      local x, y = self.shakeCb()
      love.graphics.translate(x, y)
  end
end

function camera:unset()
  love.graphics.pop()
end

function camera:update(dt)
    self.shakeTimer = self.shakeTimer - dt
    if self.shakeTimer < 0 then self.shakeTimer = 0 end
end

function camera:setShake(shakeCb)
    self.shakeCb = shakeCb
end

function camera:shake(time)
    if time > self.shakeTimer then
        self.shakeTimer = time
    end
end

function camera:move(dx, dy)
  self.x = self.x + dx
  self.y = self.y + (dy or 0)
end

function camera:rotate(r)
  self.r = (self.r + r) % (math.pi*2)
end

function camera:scale(sx, sy)
  if sx == nil then
    self.sx = 1
    self.sy = 1
  else
    self.sx = self.sx*(sx)
    self.sy = self.sy*(sy or sx)
  end
end

function camera:setPosition(x, y)
  self.x = x
  self.y = y or self.y
end

function camera:follow(x, y)
    local dx = math.min(x - self.x, 50)
    self.x = self.x + dx / 10

    local dy = math.min(y - self.y, 50)
    self.y = self.y + dy / 10
end

function camera:setRotation(r)
  self.r = r
end

function camera:setScale(sx, sy)
  self.sx = sx
  self.sy = sy or sx
end

function camera:mousePosition()
  return (love.mouse.getX() - window.w/2)/self.sx + window.w/2 + self.x, (love.mouse.getY() - window.h/2)/self.sy + window.h/2 + self.y
end

return camera
