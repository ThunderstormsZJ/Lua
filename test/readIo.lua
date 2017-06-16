--[[
    r:  以只读的方式打开文件,文件必须存在
    w:  打开只写文件,若文件存在内容会清空,若不存在会创建文件
    a:  以附加的形式加入到文件中,若不存在会创建文件
    r+: 以读写的方式打开文件,文件必须存在
    w+: 打开和读写文件,若文件存在内容会清空,若不存在会创建文件
    a+: 与a类型,此时文件可写可读
    b:  二进制模式,如果文件是二进制,可加上
    +:  表示文件即可读也可以写
]]
local utils = require("test.utils")
function fileRW(path, modal, isRead, content)
    isRead = isRead or true 
    content = content or ""
    modal = modal or "r"
    local readModal = {"r", "r+", "a+", "+"}
    local writeModal = {"w", "a", "r+", "w+", "a+", "+"}
    print(utils:findElement(writeModal, modal))
    if isRead and not utils:findElement(readModal, modal) then
        error("请输入正确的读模式")
    elseif not isRead and not utils:findElement(writeModal, modal) then
        error("请输入正确的写模式")
    end
    file = assert(io.open(path, modal))
    if isRead then
        -- 读文件
        print(file:read("*a"))

    else
        -- 写文件
        file:write(content)
    end
    
    io.close(file)
end

fileRW("test/read.txt", "r", false, "5.这就是这样的哦")
-- print(utils:findElement(readModal, "r1"))
print(nil or false)