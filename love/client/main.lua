local enet = require 'enet'
local uuid = require 'UUID'
local pent = require 'serpent'

local clients = {}
local client = {}
local me = {}

local function dump(tab)
	return pent.dump(tab, ignors)
end

function client.init()
	me.x, me.y, me.name = 400, 300, uuid(10)
	me.color = { math.random(5, 255), math.random(5, 255), math.random(5, 255) }
	client.fname = "user:" .. me.name
	client.host = enet.host_create()
	client.server = client.host:connect('localhost:18666')
end

function client.draw(self)
	if not self then
		for k,v in pairs(clients) do
			client.draw(v)
		end
		client.draw(me)
		love.graphics.print(client.connected .. "ms", 0, 0)
		if client.error then love.graphics.print(client.error, 400,300) end
	else
		love.graphics.setColor(self.color)
		love.graphics.circle('fill', self.x, self.y, 50, 50)
		love.graphics.setColor(255,255,255)
		love.graphics.print(self.name, self.x - (love.graphics.getFont():getWidth(self.name)/2), self.y - (50 + love.graphics.getFont():getHeight()))
	end
end


function client.update(dt, self)
	if not self then
		self = client
		local dx, dy = 0, 0
		if love.keyboard.isDown('up') then dy = -2 end
		if love.keyboard.isDown('down') then dy = 2 end
		if love.keyboard.isDown('left') then dx = -2 end
		if love.keyboard.isDown('right') then dx = 2 end
		me.y = me.y + dy
		me.x = me.x + dx
		local event = client.host:service()
		if event then
			if event.type == 'connect' then
				event.peer:send("connect=" .. dump(me))
				client.peer = event.peer
			elseif event.type == 'receive' then
				local msg = event.data:sub(1,8)
				if msg == 'message=' then
					local d = assert(loadstring(event.data:sub(9)))
					local client = d()
					clients[client.name] = client
				elseif msg == 'discone=' then
					clients[event.data:sub(9)] = nil
				else

				end
			end
		end
		if dx ~= 0 or dy ~= 0 then
			if client.peer then
				client.peer:send("message=" .. dump(me))
			end
		end
		client.server:ping()
		client.connected = client.server:round_trip_time()
		if client.connected >= 500 then
			client.error = "DISCONNECTED"
		else
			client.error = nil
		end
	end
end

function client.quit()
	if client.peer then
		client.peer:send("discone=" .. me.name)
	end
	local event = client.host:service(100)

	client.server:disconnect_later()
	client.host:flush()
end


function love.load(arg)
	client.init()
	love.draw, love.update, love.quit = client.draw, client.update, client.quit
end
