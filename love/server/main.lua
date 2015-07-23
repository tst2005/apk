local enet = require 'enet'
local pent = require 'serpent'

local clients = {}

local function dump(tab)
	return pent.dump(tab, ignors)
end

local function draw(self)
	love.graphics.setColor(self.color)
	love.graphics.circle('fill', self.x, self.y, 50, 50)
	love.graphics.setColor(255,255,255)
	love.graphics.print(self.name, self.x - (love.graphics.getFont():getWidth(self.name)/2), self.y - (50 + love.graphics.getFont():getHeight()))
end

local server = {}

function server.init()
	server.host = enet.host_create "localhost:18666"
	server.peers = {}
end

function server.update(dt)
	local event = server.host:service()
	if event then
		if event.type == "receive" then
			local msg = event.data:sub(1,8)
			if msg == 'connect=' then
				local d = assert(loadstring(event.data:sub(9)))
				local client = d()
				clients[client.name] = client
				server.peers[client.name] = event.peer
				for k,v in pairs(clients) do
					if k ~= client.name then
						event.peer:send('message='..dump(v))
						server.peers[k]:send(event.data)
					end
				end
			elseif msg == 'message=' then
				local d = assert(loadstring(event.data:sub(9)))
				local client = d()
				clients[client.name] = client
				for k,v in pairs(server.peers) do
					if k ~= client.name then
						v:send(event.data)
					end
				end
			elseif msg == 'discone=' then
				local name = event.data:sub(9)
				clients[name] = nil
				server.peers[name] = nil
				for k,v in pairs(server.peers) do
					v:send(event.data)
				end
			end
		end
	end
end

function server.draw()
	for k,v in pairs(clients) do
		draw(v)
	end
end

function love.load(arg)
	server.init()
	love.draw, love.update, love.quit = server.draw, server.update, server.quit
end
