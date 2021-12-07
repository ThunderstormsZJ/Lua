require("Core.table")
local UIUserTBDef = require("UICore.UIUserTBDef")

---@class UIUserTB
local UIUserTB = {
	EnableCheck = true
}

--用来区分nil
local USERTB_NIL = "33A3649E-53B4"

function UIUserTB:New(userTBName)

    if not UIUserTBDef[userTBName] then
        return nil;
    end

    local newUserTB = {}
    local mt = table.deepCopy(UIUserTBDef[userTBName])
    local key_map = {}
    for k,v in pairs(mt) do
        key_map[k] = true
        if v == USERTB_NIL then
            mt[k] = nil
        end
    end

    if UIUserTB.EnableCheck then
        rawset(newUserTB, "__UIUserTB", key_map)
        mt["__newindex"] = self.NewIndex
        mt["__index"] = self.Index
        setmetatable(newUserTB, mt)
        return newUserTB;
    else
        return mt;
    end
end


--------------------------------------
-- dump 一个具体UIUserTB的数据
-- @return 
--------------------------------------
function UIUserTB:Dump(t)

    if UIUserTB.EnableCheck then
        local mt = getmetatable(t)
        table.dump(mt)
    else
        table.dump(t)
    end

end


function UIUserTB.Index(t, k)

    if not t["__UIUserTB"][k] then
        return nil;
    else
        local mt = getmetatable(t)
        return mt[k]
    end

end

function UIUserTB.NewIndex(t, k, value)

    if not t["__UIUserTB"][k] then
        return nil;
        local mt = getmetatable(t)
    else
        mt[k] = value
    end

end

return UIUserTB