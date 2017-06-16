tableUtils = {}

function tableUtils:findElement(table, ele) 
    -- 将表的内容转换为key, 然后通过key来查找
    -- 很多值需要查找会提高效率
    reversalTbale = {}
    for k,v in pairs(table) do
        reversalTbale[v] = true
    end

    return reversalTbale[ele] and true
end

return tableUtils