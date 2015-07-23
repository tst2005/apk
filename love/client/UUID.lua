-- public domain
--by szensk

--bit math
local bit = bit -- requires luajit or lua 5.2 or you can supply numberlua

--possible characters
local chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
local base = string.len(chars)

--localized functions
math.randomseed(os.clock())
local random = math.random
local floor  = math.floor
local concat = table.concat
local sub    = string.sub
local bor    = bit.bor
local band   = bit.band
local rshift = bit.rshift

---Generates a UUID.
-- Generates a RFC4122 Version 4 ID.
-- @param length (Optional) Length of the ID.
-- @return string the UUID
-- @usage file_id = UUID().
function UUID(length)
	local res = {}
	if length then
		for i=1, length do
			j = floor(random() * base + 1)
			res[i] = sub(chars, j, j)
		end
	else
		local r = nil
		res[8], res[13], res[18], res[23] = '-','-','-','-'
		res[14] = '4'
		for i=1, 36 do
			if not res[i] then
				r = floor(random() * base + 1)
				if i == 19 then
					r = bor(band(r, 3), 8) + 1
				end
				res[i] = sub(chars, r, r)
			end
		end
	end
	return concat(res)
end

return UUID
