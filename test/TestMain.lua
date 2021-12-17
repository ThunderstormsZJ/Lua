
-- print("Memory:" .. collectgarbage("count"))

local a = os.clock()

local s = ''
local t = {}

for i = 1,3000000 do
	t[#t + 1] = 'a'
end

s = table.concat(t, "")

local b = os.clock()

print(b - a)