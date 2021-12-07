--[[
    Filename:    table.lua
    Author:      arescc 
    Datetime:    2014-07-25 19:33:43
    Description: Extentions for `table` module
--]]



--[[
    @desc Get all values in a table.
    @param t  The target table.
    @return An array contains all values.
]]
table.values = function (t)
    local ret = {}
    for _,v in pairs(t) do
        table.insert(ret, v)
    end
    return ret
end

--[[
    @desc Get all keys in a table.
    @param t  The target table.
    @param cmp  Comparation function used for sorting the values.
    @return An array contains all keys. If `cmp` is provided, keys will be
        sorted by their correponding values.
]]
table.keys = function (t, cmp)
    local ret = {}
    if cmp == nil then
        for k in pairs(t) do
            table.insert(ret, k)
        end
    else
        local reverse_map = {}
        local values = {}
        for k,v in pairs(t) do
            reverse_map[v] = k
            table.insert(values, v)
        end
        table.sort(values, cmp)
        for i,v in ipairs(values) do
            table.insert(ret, reverse_map[v])
        end
    end
    return ret
end

--[[
    @desc Get the capacity of a table (the number of key-value pairs).
    @return The capacity of `t`.
]]
table.capacity = function (t)
    local cnt = 0
    local a = nil
    while true do
        a = next(t, a)
        if a==nil then
            break
        end
        cnt = cnt+1
    end
    return cnt
end

table.len = table.capacity


--是否空Table
table.is_empty = function (t)

    if type(t) ~= "table" then
        return true;
    end

    return type(_G.next( t )) == "nil"

end





--[[
    @desc Copy all key-value pairs to another one.
    @param src  The source table.
    @param dest The destination. An empty table will be created if it's nil.
    @return The destination table.
]]
table.copy = function (src, dest)
    local u = dest or {}
    for k, v in pairs(src) do
        u[k] = v
    end
    return setmetatable(u, getmetatable(src))
end

--[[
    @desc Copy all key-value pais to another one. If the value is a table, it
        will also be deep copied.
    @param src  The source table.
    @param dest The destination. An empty table will be created if it's nil.
    @return The destination table.
]]
table.deepCopy = function (src, dest)
    local function _deepCopy(from ,to)
        for k, v in pairs(from) do
            if type(v)~="table" then
                to[k] = v
            else
                to[k] = {}
                _deepCopy(v, to[k])
            end
        end
        return setmetatable(to, getmetatable(from))
    end
    return _deepCopy(src, dest or {})
end

--[[
    @desc Find value in a table.
    @param t  The target table.
    @param value  The value to search for.
    @param startKey The key (excluded) from which the searching starts.
    @return (k,v) if successes, nil if fails.
]]
table.find = function (t, value, startKey)
    local k, v = next(t, startKey)
    while k~=nil do
        if v==value then
            return k, v
        end
        k, v = next(t, k)
    end
    return nil
end

--[[
    @desc
    ...
]]
table.indexOf = function (t, value, start)
    local k, v = table.find(t, value, start)
    if k and v then
        return k
    end    
    return nil
end


--=======================================
-- function:   find_if
-- author:     hopli
-- created:    2017/09/11
-- returns:    
-- descrip:    
--=======================================
table.find_if = function( t, compare )

    for k, v in pairs(t) do
       if compare(k, v) then
           return k, v;
       end 

    end

    return nil
end


--=======================================
-- function:   remove_val_first
-- author:     hopli
-- created:    2017/09/11
-- returns:    
-- descrip:    删除一次指定value
--=======================================
table.remove_val_first = function( t, val )

--    for i = #t, 1, -1 do 
--        if t[i] == val then 
--            table.remove(t,i) 
--        end 
--    end 

    local k, v = next(t)
    while k ~= nil do
        if v == val then
            table.remove(t, k);
            return true;
        else
            k, v = next(t, k)
        end
        
    end

    return false
end

--=======================================
-- function:   remove_val
-- author:     hopli
-- created:    2017/09/11
-- returns:    
-- descrip:    递归删除所有指定value
--=======================================
table.remove_val = function( t, val )

    for k, v in pairs(t) do
        if v == val then
            table.remove(t, k);
        end
    end
    
end

--=======================================
-- function:   remove_if_first
-- author:     hopli
-- created:    2017/09/16
-- returns:    
-- descrip:    删除符合提交的第一个值
--=======================================
table.remove_if_first = function( t, compare )

    for k, v in pairs(t) do
       if compare(k, v) then
           table.remove(t, k)
           return true;
       end 

    end

    return false

end


--=======================================
-- function:   remove_if
-- author:     hopli
-- created:    2017/09/16
-- returns:    
-- descrip:    递归删除所有符合条件的value
--=======================================
table.remove_if = function( t, compare )

    while table.remove_if_first(t, compare) do

    end

end




--=======================================
-- function:   cmp
-- author:     hopli
-- created:    2017/09/11
-- returns:    
-- descrip:    两个table比较，只比较第一层
--=======================================
table.cmp = function( t1, t2 )

    if type(t1) ~= "table" or type(t2) ~= "table" then
        return false;
    end

    local keys1 = table.keys(t1)
    local keys2 = table.keys(t2)

    if #keys1 ~= #keys2 then
        return false;
    end

    for k, v in pairs(t1) do
        if v ~= t2[k] then
            return false;
        end

    end

    return true;

end



--=======================================
-- function:   dump
-- author:     
-- created:    2017/09/18
-- returns:    
-- descrip:    输出table的每个字段
--=======================================
table.dump = function(t, indent, print_func, level)
    --Pass

    print_func = print_func or _G.print

    --打印层次控制
    if level then
        if level < 0 then
            print_func("[Level Limit]");
            return ;
        else
            level = level - 1
        end
    end

--    local ignoreList = {'"Super"', '"super"', '"__index"', '"mUI"', '"mTarget"'}
    local ignoreList = {'"Super"', '"super"', '"__index"'}

    if type(t) == "nil" then
        print_func("table.dump() param is nil")
        return ;
    elseif table.is_empty(t) then
        print_func("")
        return ;
    end

    indent = indent or 0
    for k, v in pairs(t) do
        if type(k) == "string" then
            k = string.format("%q", k)
        end
        local szSuffix = ""
        if type(v) == "table" then
            szSuffix = "{"
        end
        local szPrefix = string.rep("    ", indent)
        local formatting = szPrefix.."["..tostring(k).."]".." = "..szSuffix
        if type(v) == "table" then

            local ignore = false
            if type(k) == "string" then
                for _, ignoreName in pairs(ignoreList) do
                    if ignoreName == k then
                        ignore = true
                        break;
                    end
                end
            end

            if not ignore then
                print_func(formatting)
                if level then
                    table.dump(v, indent + 1, print_func, level - 1)
                else
                    table.dump(v, indent + 1, print_func)
                end
                
                print_func(szPrefix.."},")
            else
                print_func(szPrefix.."["..k.."]".." = "..tostring(v).."   --filter table")
            end
        else
            local szValue = ""
            if type(v) == "string" then
                szValue = string.format("%q", v)
            else
                szValue = tostring(v)
            end
            print_func(formatting..szValue..",")
        end
    end

end



--=======================================
-- function:   resize
-- author:     hopli
-- created:    2017/10/16
-- returns:    
-- descrip:    重新调整t的容量大小，并以init_val进行初始化，通常用于数组等类型
--=======================================
table.resize = function(t, size, init_val)

    for i = 1, size do
        t[i] = t[i] or init_val
    end

    --删除不在范围内的值
    for k, v in pairs(t) do
        if type(k) ~= "number" or k <= 0 or k > size then
            t[k] = nil
        end
    end


end


--------------------------------------
-- list 合并。修改为直接改变t1，降低GC。 2019.03.04
-- @return 
--------------------------------------
table.extend_list = function(t1, t2)

    -- local t = {}
    -- for i = 1, #t1 do
    --     table.insert(t, t1[i])
    -- end

    local t = t1

    for i = 1, #t2 do
        table.insert(t, t2[i])
    end

    return t;
end


--------------------------------------
-- map 合并。优先使用t1的值。修改为直接改变t1，降低GC。 2019.03.04
-- @return 
--------------------------------------
table.extend_map = function(t1, t2)

    -- local t = {}
    -- for k, v in pairs(t1) do
    --     t[k] = v
    -- end

    local t = t1
    
    for k, v in pairs(t2) do
        t[k] = v
    end
    

    return t;
end


--------------------------------------
-- 使value唯一。如果t本身为list，可能会打乱顺序
-- @return 
--------------------------------------
table.unique = function(t)

    local t1 = {}
    for k, v in pairs(t) do
        t1[v] = k
    end

    t2 = {}
    for k, v in pairs(t1) do
        t2[v] = k
    end 

    return t2;

end


table.removekey = function(t, key)
    local element = t[key]
    t[key] = nil
    return element
end

---逐项清空table，避免GC。一般高频调用时用这来避免GC
table.clear = function(t)
    
    for k, v in pairs(t) do
        t[k] = nil
    end
end

table.safe_concat = function(t, sep, i, j)
    local ret = {}
    for k, v in pairs(t) do
        ret[k] = tostring(v)
    end
    return table.concat(ret, sep, i, j)
end

--获取table的元素个数
table.count = function(t)
    if type(t) ~= "table" then return 0 end 
    local c = 0
    for k, v in pairs(t) do
        c = c + 1
    end
    return c
end

--安全获取table中的深层子树，一旦有空引用立刻返回nil
table.safeget = function (t, ...)
    if type(t) ~= "table" then
        return t
    end
    local count = select("#", ...)
    if count == 0 then
        return t 
    end
    local key = ...
    local result = table.safeget(t[key], select(2, ...))
    return result
end

table.GetValueByIndex = function(t, _index)
    if type(t) ~= "table" then
        return nil
    end

    local index = 1
    for i,v in pairs(t) do
        if index == _index then
            return v
        end
        index = index + 1
    end
    return nil
end