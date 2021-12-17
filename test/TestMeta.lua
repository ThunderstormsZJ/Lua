require("Core.table")

-----------------------------------Meta__Add-----------------------------------
--region 
  
---@class Point
---@field x number
---@field y number
local Point = setmetatable({}, {
	__add = function(t1, t2)
		return {x = t1.x+t2.x, y = t1.y+t2.y}
	end
})

function Point:New(x, y)
	self.x = x
	self.y = y

	return self
end

-- local p1 = Point:New(1,2)
-- local p2 = Point:New(1,2)

-- local p3 = p1 + p2

-- print(p3.x, p3.y)

--endregion
-----------------------------------Meta__Add-----------------------------------

-----------------------------------Meta__Weak-----------------------------------
--region 
--说明
--1、注意，弱引用table中只有对象可以被回收，而像数字、字符串和布尔这样的“值”是不可回收的。

local NoWeakTest = function()
	local tb = {}
	local key = {} --- (1)
	tb[key] = 1

	key = {} ---- (2)
	tb[key] = 2

	collectgarbage()

	-- (1) 位置得table引用其实已经不再持有引用，但是并没有被清理掉
	for k, v in pairs(tb) do
		print(k, v)
	end
end

print("=======NoWeakTest=======")
NoWeakTest()

local KWeakTest = function()
	local tb = {}
	setmetatable(tb, { __mode = "k" })

	local key1 = {name = "key1"}
	tb[key1] = 1

	local key2 = {name = "key2"}
	tb[key2] = 2

	key2 = nil

	collectgarbage()

	-- 当k值被销毁时（置空）对应的在tb中的条目也会被销毁掉
	for k, v in pairs(tb) do
		print(k.name, v)
	end
end

print("=======KWeakTest=======")
KWeakTest()

local VWeakText = function()
	local tb = {}
	setmetatable(tb, { __mode = "v" })

	local createRgb = function(r, g, b)
		local key = string.format("%s-%s-%s", r, g, b)

		if tb[key] then
			print("RGB Exist")
			return tb[key]
		else
			print("RGB Not Exist")
			tb[key] = {r=r, g=g, b=b}
			return tb[key]
		end
	end

	local color1 = createRgb(122, 233, 255) -- create 
	local color2 = createRgb(255, 255, 255) -- create

	color1 = nil

	collectgarbage()

	color1 = createRgb(122, 233, 255) -- create
	color2 = createRgb(255, 255, 255) -- cache

	table.dump(color1)
	print("")
	table.dump(color2)
end

print("=======VWeakText=======")
VWeakText()

--endregion
-----------------------------------Meta__Weak-----------------------------------