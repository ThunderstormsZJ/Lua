--====Util.lua
-- (c) copyright 2014, Tencent
-- All Rights Reserved.
--=======================================

----------------------------------------------------
--一些公用函数，或许应该挪到另外一个地方去--
----------------------------------------------------

g_WindowsUserName = nil
g_ClientPlatformId = nil

---@class LogConfig
LogConfig = {
    IsOpenTableToString = false, -- 打开table转字符串
    IsOpenConsoloeLog = false -- 打开控制台日志
}

--=======================================
-- function:  Assert
-- author:    johnduan
-- created:   2014/8/5
-- returns:
-- descrip:
--=======================================
function Assert(bOk)
    if bOk == false then
        local src = debug.getinfo(2, "S").source
        local line = debug.getinfo(2, "l").currentline
        local msg = string.format("Lua Assert:%s,%d", src, line)
        LogError("Assert false.n" .. msg)
    end
end

-- 排序的迭代器
-- see:http://stackoverflow.com/questions/15706270/sort-a-table-in-lua
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do
        keys[#keys + 1] = k
    end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(
            keys,
            function(a, b)
                return order(t, a, b)
            end
        )
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

--=======================================
-- function:   GetLuaString
-- author:     hopli
-- created:    2017/05/22
-- returns:
-- descrip:    为了简单方便调用LUA字符串的GetString
--=======================================
function GetLuaString(strDesc, place_info_table)
    if type(strDesc) ~= "string" then
        return ""
    end

    if place_info_table ~= nil then
        for key, value in pairs(place_info_table) do
            value = CommonHelper.PatternEscapeReplace(value)
            key = "%$" .. key .. "%$"
            strDesc = string.gsub(strDesc, key, tostring(value))
        end
    end
    return strDesc
end

--=======================================
-- function:CharArr2String
-- author:    johnduan
-- created:   2014/8/23
-- returns:
-- descrip: 将服务器解码的char[]变成string
--=======================================
function CharArr2String(charArr)
    local strRet = ""
    for i = 1, #charArr do
        strRet = strRet .. string.char(charArr[i])
    end
    return strRet
end

--=======================================
-- function:   IntArr2String
-- author:     albertzhong
-- created:
-- returns:
-- descrip:
--=======================================
function IntArr2String(intArr, separate)
    local cnt = #intArr
    local str = ""
    if separate == nil then
        separate = ","
    end
    for i = 1, cnt do
        str = str .. tostring(intArr[i])
        if i ~= cnt then
            str = str .. separate
        end
    end
    return str
end

--=======================================
-- function:   StrArr2String
-- author:     albertzhong
-- created:
-- returns:
-- descrip:
--=======================================
function StrArr2String(strArr, separate)
    local cnt = #strArr
    local str = ""
    if separate == nil then
        separate = ","
    end
    for i = 1, cnt do
        str = str .. '"' .. tostring(strArr[i]) .. '"'
        if i ~= cnt then
            str = str .. separate
        end
    end
    return str
end

--=======================================
-- function:   ShuffleTable
-- author:     albertzhong
-- created:
-- returns:
-- descrip:    打乱列表里面的元素
--=======================================
function ShuffleTable(t)
    if type(t) ~= "table" then
        return
    end
    local tab = {}
    local index = 1
    while #t ~= 0 do
        local n = math.random(0, #t)
        if t[n] ~= nil then
            tab[index] = t[n]
            table.remove(t, n)
            index = index + 1
        end
    end
    return tab
end

--=======================================
-- function:  CollectGarbage
-- author:    johnduan
-- created:   2015/1/6
-- descrip:   封装lua的垃圾回收
--=======================================
function CollectGarbage()
    collectgarbage("collect", nil)
    return true
end

--=======================================
-- function:  StepGarbage
-- author:    johnduan
-- created:   2016/12/4
-- descrip:
--=======================================
function StepGarbage(val)
    if not val or val < 0 then
        return
    end

    collectgarbage("step", val or 10)
end

--=======================================
-- function:  DumpStack
-- author:    johnduan
-- created:   2015/7/27
-- descrip:   打印调用堆栈
--=======================================
function DumpStack(beginLevel)
    local logInfo = ""
    beginLevel = beginLevel or 2
    for level = beginLevel, beginLevel + 10 do
        local info = debug.getinfo(level, "nSl")
        if not info then
            break
        end

        if info.what == "C" then -- is a C function?
        else
            logInfo = logInfo .. string.format("%s:%d\n", info.short_src, info.currentline)
        end
    end

    return logInfo
end

--=======================================
-- function:  DumpObject
-- author:    johnduan
-- created:   2014/8/23
-- returns:
-- descrip:
--=======================================
function DumpObject(o)
    table.dump(o)
end

--=======================================
-- function:  file_exists
-- author:    Ares
-- created:   2016/04/5
-- returns:
-- descrip:   判断文件是否存在
--=======================================
function file_exists(path)
    local file = io.open(path, "rb")
    if file then
        file:close()
    end
    return file ~= nil
end

function GetReadableStorageSizeStr(nSize)
    local strSize = ""
    if nSize > 1024 * 1024 * 1024 then
        strSize = string.format("%0.2fGb", nSize * 1.0 / (1024 * 1024 * 1024))
    elseif nSize > 1024 * 1024 then
        strSize = string.format("%0.2fMb", nSize * 1.0 / (1024 * 1024.0))
    elseif nSize > 1024 then
        strSize = string.format("%0.2fKb", nSize * 1.0 / (1024.0))
    else
        strSize = string.format("%db", nSize)
    end
    return strSize
end

g_xlua_util = nil
function GetXLuaUtil()
    if g_xlua_util == nil then
        g_xlua_util = require "Lua.xlua.XluaUtil"
    end

    return g_xlua_util
end

--=======================================
-- function:   BeEditorMode
-- author:     hopli
-- created:    2017/10/13
-- returns:
-- descrip:    是否windows上面使用Unity开发环境
--=======================================
function BeEditorMode()
    --Pass

    return CS_ManualExport.GetRuntimePlat() == ToInt32(CS.UnityEngine.RuntimePlatform.WindowsEditor)
end

--=======================================
-- function:   ToInt32
-- author:     hopli
-- created:    2017/10/13
-- returns:
-- descrip:    C# 对象转int
--=======================================
function ToInt32(obj)
    --Pass

    if type(obj) == "userdata" then
        return CS_Convert.ToInt32(obj)
    end

    return tonumber(obj)
end

--=======================================
-- function:   SetSuperClass
-- author:     hopli
-- created:    2017/10/16
-- returns:
-- descrip:    设置基类(超类)
--=======================================
function SetSuperClass(tbl, super)
    super.__index = super
    setmetatable(tbl, super)
end

--=======================================
-- function:   TODO
-- author:     hopli
-- created:    2017/10/16
-- returns:
-- descrip:
--=======================================
function TODO()
    --Pass

    if _G.g_bDevTest then
        local err = "Func TODO "
        --          assert(false, err);

        local src = debug.getinfo(2, "S").source
        local line = debug.getinfo(2, "l").currentline
        local msg = string.format(err .. " :%s,%d", src, line)
        LogWarning(msg)
    end
end

--=======================================
-- function:   IsNumber
-- author:     hopli
-- created:    2017/10/25
-- returns:
-- descrip:    是否number类型
--=======================================
function IsNumber(val)
    return type(val) == "number"
end

--=======================================
-- function:   IsString
-- author:     hopli
-- created:    2017/10/25
-- returns:
-- descrip:    是否字符串类型
--=======================================
function IsString(val)
    --Pass
    return type(val) == "string"
end

--=======================================
-- function:   IsTable
-- author:     hopli
-- created:    2017/10/25
-- returns:
-- descrip:    是否table类型
--=======================================
function IsTable(val)
    --Pass
    return type(val) == "table"
end

--------------------------------------
-- 是否为nil，包括userdata
-- @return
--------------------------------------
function IsNull(val)
    --Pass

    if type(val) == "nil" then
        return true
    end

    --C#的null只是重载了==操作符，实际上还有值
    if type(val) == "userdata" then
        return CS_LuaUtility.IsNull(val)
    end

    return false
end

---判断字符串是否为nil或者空字符串
---@param val string string字符串
function StringIsNull(val)
    if (type(val) == "nil") then
        return true
    end
    if (type(val) == "string" and val == "") then
        return true
    end

    return false
end

---判断数值类型是否为nil或者为0
---@param val number number类型值
function NumberIsNull(val)
    if (type(val) == "nil") then
        return true
    end
    if (type(val) == "number" and val == 0) then
        return true
    end

    return false
end

---判断Table是否为nil或者数组长度为0
---@param tab table table类型
---@return boolean 是否为空或者数组长度为0
function TableIsNull(tab)
    -- 如果不是Table类型，也返回true
    if (not IsTable(tab)) then
        return true
    end

    if (tab == nil or GetTableLength(tab) == 0) then
        return true
    end

    return false
end

---获取Table的长度
---@param tab table table类型
---@return number 长度
function GetTableLength(tab)
    local len = 0

    if (IsTable(tab)) then
        for _, v in pairs(tab) do
            len = len + 1
        end
    end

    return len
end

--------------------------------------
-- 判定是否为number，出错时打印堆栈
-- @return
--------------------------------------
function AssertNumber(val)
    if type(val) == "number" then
        return true
    else
        RaiseError(1, "AssertNumber() fail. val:" .. tostring(val))
        return false
    end
end

--------------------------------------
-- 判定是否为string，出错时打印堆栈
-- @return
--------------------------------------
function AssertString(val)
    if type(val) == "string" then
        return true
    else
        RaiseError(1, "AssertString() fail. val:" .. tostring(val))
        return false
    end
end

--------------------------------------
-- 判定是否为table，出错时打印堆栈
-- @return
--------------------------------------
function AssertTable(val)
    if type(val) == "table" then
        return true
    else
        RaiseError(1, "AssertTable() fail. val:" .. tostring(val))
        return false
    end
end

--------------------------------------
-- 判定是否不为nil，出错时打印堆栈
-- @return
--------------------------------------
function AssertNotNil(val)
    if type(val) ~= "nil" then
        return true
    else
        RaiseError(1, "AssertTable() fail. val:" .. tostring(val))
        return false
    end
end

--------------------------------------
-- 判定是否为Coroutine，出错时打印堆栈
-- @return
--------------------------------------
function AssertCoroutine(val)
    if type(val) == "thread" then
        return true
    else
        RaiseError(1, "AssertCoroutine() fail. val:" .. tostring(val))
        return false
    end
end

--=======================================
-- function:   JsonDecode
-- author:     johnduan
-- created:    2017/11/24
-- returns:
-- descrip:    从炫斗移植过来， 将json转成table
--=======================================
function JsonDecode(jsStr)
    if not GetJsonIns then
        LuaCM_DoFile("Lua/Lib/JSON.lua")
    end

    return GetJsonIns():decode(jsStr, nil)
end

--=======================================
function JsonEncode(tb)
    if not GetJsonIns then
        LuaCM_DoFile("Lua/Lib/JSON.lua")
    end

    return GetJsonIns():encode(tb)
end

--=======================================
-- function:   StrFormat
-- author:     johnduan
-- created:    2018/3/23
-- returns:
-- descrip:    保护格式化字符串不崩溃
--=======================================
function StrFormat(format, paramsTb)
    --if paramsTb == nil or #paramsTb <= 0 then
    --    return format
    --end

    if not string.find(format, "%%") then
        return format
    end

    local str = nil
    if not paramsTb or type(paramsTb) ~= "table" or #paramsTb <= 0 then
        str = format
    else
        str = string.format(format, table.unpack(paramsTb))
    end

    --local lowerStr = string.lower(str)
    --if string.find(lowerStr, "%%") ~= nil then
    --[[
        if string.find(lowerStr, "%%d") ~= nil or
           string.find(lowerStr, "%%c") ~= nil or
           string.find(lowerStr, "%%i") ~= nil or
           string.find(lowerStr, "%%o") ~= nil or
           string.find(lowerStr, "%%u") ~= nil or
           string.find(lowerStr, "%%x") ~= nil or
           string.find(lowerStr, "%%a") ~= nil or
           string.find(lowerStr, "%%e") ~= nil or
           string.find(lowerStr, "%%g") ~= nil or
           string.find(lowerStr, "%%q") ~= nil or
           string.find(lowerStr, "%%f") ~= nil or
           string.find(lowerStr, "%%s") ~= nil then
           ]]
    --直接去掉%号就行
    --str = string.gsub(str, "%%", "")
    --[[
        end
        ]]
    --end

    local szFmtLog, _ = string.gsub(str, "%%", "")
    return szFmtLog
end


---格式化字符串,并说出去没有%d等格式的字符串，避免在C++输出时crash
function StrFormatOptimize(format, ...)
    
    if not string.find(format, "%%") then
        return format
    end

    local str = nil
    local paramCount = select("#", ...)
    if paramCount <= 0 then
        str = format
    else
        str = string.format(format, ...)
    end

    local szFmtLog, _ = string.gsub(str, "%%", "")
    return szFmtLog
end


--=======================================
-- function:   LogFatal
-- author:     hopli
-- created:    2017/11/27
-- returns:
-- descrip:    致命日志
--=======================================
function LogFatal(format, ...)
    --Pass
    LuaCM_VDLOG(VD_LogLevel.ELogFatal, StrFormat(format, {...}))
end

--=======================================
-- function:   LogError
-- author:     hopli
-- created:    2017/11/27
-- returns:
-- descrip:    错误日志
--=======================================
function LogError(format, ...)
    --Pass

    -- RaiseError(1, format, ...)

    local errContent = StrFormat(format, {...})
    LuaCM_VDLOG(VD_LogLevel.ELogError, errContent)
    
end


--=======================================
-- function:   LogErrorWithoutRaise
-- author:     hopli
-- created:    2017/11/27
-- returns:
-- descrip:    错误日志
--=======================================
function LogErrorWithoutRaise(format, ...)
    --Pass

    local errContent = StrFormat(format, {...})
    LuaCM_VDLOG(VD_LogLevel.ELogError, errContent)
    
end



--------------------------------------
--- 错误日志,windows下输出堆栈。这里的堆栈是相对于调用者的，若stackLevel为0，则是调用方
---
function LogErrorStackLevel(stackLevel, format, ...)
    local baseStackLevel = 4
    LogErrorStackLevelInner(baseStackLevel + stackLevel, format, ...)
end


---抛出一个可预期的错误。上层函数使用不正确引发的异常。
---@param level number @上层函数的层数，0代表当前层数。1代表调用方，2代表更上一层的调用方...
---@param errFormat string @错误描述。支持%s、%d等自动替换
function RaiseError(level, errFormat, ...)

    local errContent = StrFormatOptimize(errFormat, ...)
    local baseStackLevel = 3
    if not WEDO_PUBLIC then
        local stackTrace = DumpStack(baseStackLevel)
        errContent = errContent .. "\nCallStack:\n" .. stackTrace
    end

    LuaCM_VDLOG(VD_LogLevel.ELogError, errContent)

    if not WEDO_PUBLIC and not SIMPLE_GAME then
        --是否需要输出C#堆栈?
        local svnBlameStackTrace = DumpStack(baseStackLevel + level)
        CS_ManualExport.UploadWhoseError(errContent, svnBlameStackTrace, EnumWhoseErrType.LuaError)

    end

end


---上报对应处理人的错误
---@param author string @责任处理人
function RaiseAuthorError(author, format, ...)

    if WEDO_PUBLIC or SIMPLE_GAME then
        return
    end

    local errContent = StrFormat(format, {...})
    local stackTrace = DumpStack(3)
    CS_ManualExport.UploadAuthorError(errContent, stackTrace, author)
end


---抛出一个可预期的错误
---这里level指的是上层调用方的层数。0代表当前函数引发的错误
function RaiseErrorInner(level, errFormat, ...)

    local baseStackLevel = 4
    LogErrorStackLevelInner(baseStackLevel + level, errFormat, ...)
end


--------------------------------------
-- 错误日志,windows下输出堆栈
-- @stackLevel 指定堆栈开始层级。内部会存在3层调用，外部调用方需要考虑
-- @return
--------------------------------------
function LogErrorStackLevelInner(stackLevel, format, ...)
    --Pass

    local errContent = ""
    if #{...} > 0 then
        errContent = StrFormat(format, {...})
    else
        errContent = format
    end

    local stackTrace = ""
    if not WEDO_PUBLIC then
        stackTrace = DumpStack(stackLevel)
        errContent = errContent .. "\nCallStack:\n" .. stackTrace
    end

    LuaCM_VDLOG(VD_LogLevel.ELogError, errContent)

    --if not WEDO_PUBLIC then
    --    -- errContent = "LuaError: "..errContent
    --    CS_ManualExport.UploadWhoseError(errContent, stackTrace, EnumWhoseErrType.LuaError)
    --end
end


--=======================================
-- function:   LogFlow
-- author:     hopli
-- created:    2017/11/27
-- returns:
-- descrip:    Flow日志
--=======================================
function LogFlow(format, ...)
    --Pass

    LuaCM_VDLOG(VD_LogLevel.ELogFlow, StrFormat(format, {...}))
end

--=======================================
-- function:   LogInfo
-- author:     hopli
-- created:    2017/11/27
-- returns:
-- descrip:    LogInfo 日志
--=======================================
function LogInfo(format, ...)
    --Pass

    LuaCM_VDLOG(VD_LogLevel.ELogInfo, StrFormat(format, {...}))
end

--=======================================
-- function:   LogWarning
-- author:     hopli
-- created:    2017/11/27
-- returns:
-- descrip:    LogWarning 日志
--=======================================
function LogWarning(format, ...)
    --Pass

    LuaCM_VDLOG(VD_LogLevel.ELogWarning, StrFormat(format, {...}))
end

--=======================================
-- function:   LogDebug
-- author:     hopli
-- created:    2017/11/27
-- returns:
-- descrip:    LogDebug 日志
--=======================================
function LogDebug(format, ...)
    --Pass

    LuaCM_VDLOG(VD_LogLevel.ELogDebug, StrFormat(format, {...}))
end

--------------------------------------
-- 网络层日志
-- @return
--------------------------------------
function LogNet(format, ...)
    --Pass

    LuaCM_VDLOG(VD_LogLevel.ELogNet, StrFormat(format, {...}))
end

--------------------------------------
-- 打印协议交互日志
-- @return
--------------------------------------
function LogProtocol(log)
    if not CmdDataMgr:IsLogProtocol() then
        return
    end

    LuaCM_Log(ELogType.EProtocolLog, VD_LogLevel.ELogDebug,  log)
end

--------------------------------------
-- 用以替换默认的print
-- @return
--------------------------------------
function Print(...)
    local len = select("#", ...)
    for i = 1, len do
        local val = select(i, ...)
        LogDebug(tostring(val))
    end
end

function DebugTip(...)
    if WEDO_PUBLIC then
        return
    end

    local params = {...}
    local content = ""
    for i = 1, #params do
        local para = tostring(params[i])
        content = content .. "  " .. para
    end

    TipsCtrl:PopDebugMessage(content, true)
end

--=======================================
-- function:   And
-- author:     hopli
-- created:    2017/11/27
-- returns:
-- descrip:    与操作符
--=======================================
function And(l, r)
    --Pass
    return l & r --@sumignore
end

--=======================================
-- function:   Or
-- author:     hopli
-- created:    2017/11/27
-- returns:
-- descrip:    或操作符
--=======================================
function Or(l, r)
    --Pass

    return l | r --@sumignore
end

--=======================================
-- function:
-- author:     zezhongwang
-- descrip:    左移操作
--=======================================
function LShift(l, r)
    return l << r --@sumignore
end

--=======================================
-- function:
-- author:     zezhongwang
-- descrip:    右移操作
--=======================================
function RShift(l, r)
    return l >> r --@sumignore
end

--------------------------------------
-- xlua的TemplateEngine中抽出来,遍历所有的C#列表,然后调用callback(最后一个参数)来遍历
-- @return
--------------------------------------
function ForEachCsList(...)
    local list_count = select("#", ...) - 1
    local callback = select(list_count + 1, ...)
    for i = 1, list_count do
        local list = select(i, ...)
        if list then
            for j = 0, (list.Count or list.Length) - 1 do
                callback(list[j], j)
            end
        else
            RaiseError(1, "ForEachCsList() list is nil. param index:%s", tostring(list))
        end
    end
end

function LUA_DEBUG(strInfo)
    -- if not IsPC() or not strInfo then
    if UNITY_EDITOR then
        LogInfo(strInfo)
    end
end

--------------------------------------
-- 是否为hop的电脑，开发调试时使用
-- @return
--------------------------------------
function HopPC()
    if UNITY_PC then
        return GetPCUserName() == "hopli" or GetPCUserName() == "Hop"
    end

    return false
end

---是否为zwen的电脑，开发调试时使用
------@return boolean
function ZwenPC()
    if UNITY_PC then
        return GetPCUserName() == "v_zwenzhou"
    end

    return false
end

---是否为指定名字PC，开发调试时使用
function IsPCByName(PCName)
    if UNITY_PC then
        return GetPCUserName() == PCName
    end

    return false
end

--------------------------------------
-- 获取PC上的登录用户名称，开发调试时使用
-- @return string
--------------------------------------
function GetPCUserName()
    if UNITY_PC then
        if g_WindowsUserName == nil then
            g_WindowsUserName = LuaCM_GetWindowsUserName()
        end

        return g_WindowsUserName
    end

    return ""
end

function PrivatePC()
    if UNITY_PC then
        if g_WindowsUserName == nil then
            g_WindowsUserName = LuaCM_GetWindowsUserName()
        end
        return g_WindowsUserName == ""
    end
    return false
end

--=======================================
-- function:   LogFlow
-- author:     albertzhong
-- created:
-- returns:
-- descrip:    私人日志
--=======================================
function LogPrivate(format, ...)
    if PrivatePC() then
        LuaCM_VDLOG(VD_LogLevel.ELogDebug, StrFormat(format, {...}))
    end
end

--=======================================
-- function:   TableDumpPrivate
-- author:     albertzhong
-- created:
-- returns:
-- descrip:    私人导出表日志
--=======================================
function TableDumpPrivate(tb)
    if PrivatePC() then
        table.dump(tb, 0, print)
    end
end

-- 用于修改当前的登录平台，用于模拟平台登录
function SetClientPlatformId(platformId)
    if UNITY_PC and not WEDO_PUBLIC then
        g_ClientPlatformId = platformId
    end
end

function GetClientPlatformId()
    -- 如果之前有设置过平台，直接返回，用于模拟平台登录
    if UNITY_PC and not WEDO_PUBLIC and g_ClientPlatformId ~= nil then
        return g_ClientPlatformId
    end

    if UNITY_PC then
        return Protocol.CLIENT_PLATFORM_ID.CPID_PC
    elseif UNITY_IOS then
        return Protocol.CLIENT_PLATFORM_ID.CPID_IOS
    elseif UNITY_ANDROID then
        return Protocol.CLIENT_PLATFORM_ID.CPID_ANDROID
    else
        -- 未定义的平台返回MAX
        return Protocol.CLIENT_PLATFORM_ID.CPID_MAX
    end
end

function OpenWeDoPublic()
    WEDO_PUBLIC = 1
end

--=======================================
-- function:   RunFunc
-- author:     hopli
-- created:    2017/07/29
-- returns:
-- descrip:    执行一个lua函数，通常用以回调
--=======================================
function RunFunc(handler, func, args)
    --Pass
    if handler then
        return func(handler, table.unpack(args))
    else
        return func(table.unpack(args))
    end
end

--=======================================
-- function:  DumpLocals
-- author:    hopli
-- created:   2018/11/17
-- descrip:   打印当前所有局部变量，Upval，调试使用
--=======================================
function DumpLocals(stacklevel)
    stacklevel = stacklevel or 2
    local info = debug.getinfo(stacklevel, "nSlu")
    if not info then
        return ""
    end

    local retInfoStr = ""

    if info.what == "C" then -- is a C function?
        return "DumpLocals err. C function."
    else
        retInfoStr = retInfoStr .. string.format("%s:%d ==> %s\n", info.short_src, info.currentline, info.name)
    end

    -- print("info", info)
    -- print("info.nups", info.nups)
    -- print("info.nparams", info.nparams)
    -- print("info.isvararg", info.isvararg)

    local outputParamFunc = function(name, value)
        local strConcat = ""

        --特殊处理self
        if name == "self" then
            return tostring(name) .. " = [" .. type(value) .. "] " .. tostring(value) .. "\n"
        end

        --过滤部分Table，避免打印太深
        if type(value) == "table" then
            local mt = getmetatable(value)
            if mt == PanelBase then
                local printVal = "[table] " .. value:GetName() .. ":" .. value:GetPanelID()
                strConcat = strConcat .. tostring(name) .. " = " .. printVal .. "\n"
            elseif mt == UIViewComponentBase then
                local printVal = "[table] " .. value:GetName() .. ":" .. value:GetUIViewCompID()
                printVal = printVal .. " in panel:" .. value:GetPanelName() .. ":" .. value:GetPanelID()
                strConcat = strConcat .. tostring(name) .. " = " .. printVal .. "\n"
            else
                strConcat =
                    strConcat .. tostring(name) .. " = [" .. type(value) .. "] " .. Library:Value2String(value) .. "\n"
            end
        else
            strConcat =
                strConcat .. tostring(name) .. " = [" .. type(value) .. "] " .. Library:Value2String(value) .. "\n"
        end

        return strConcat
    end

    retInfoStr = retInfoStr .. "locals:\n"
    local index = 1
    while true do
        local name, value = debug.getlocal(stacklevel, index)
        if not name then
            break
        end
        retInfoStr = retInfoStr .. outputParamFunc(name, value)
        index = index + 1
    end

    retInfoStr = retInfoStr .. "upvalue:\n"
    index = -1
    while true do
        local name, value = debug.getlocal(stacklevel, index)
        if not name then
            break
        end
        retInfoStr = retInfoStr .. outputParamFunc(name, value)
        index = index - 1
    end

    return retInfoStr
end

--------------------------------------
-- 打印当前局部变量、upvalues信息
-- @return
--------------------------------------
function PrintLocals(message, printFunc)
    printFunc = printFunc or _G.print

    if message then
        printFunc(message)
    end
    printFunc(DumpLocals(3))
    printFunc(DumpStack())
end

--------------------------------------
-- 将一个文本定义的Table还原为Lua的Table结构。调试使用，可以方便构造协议数据
-- @return
--------------------------------------
function DoTable(str)
    if WEDO_PUBLIC then
        return nil
    end

    local ret = load("return " .. str)()
    return ret
end

--------------------------------------
-- 将文件路径中的反斜杠改为正斜杠，用于lua文件系统
-- @return
--------------------------------------
function String_conversion(value)
    local path = ""
    for i = 1, #value do
        --获取当前下标字符串
        local tmp = string.sub(value, i, i)
        --如果为'\\'则替换
        if tmp == "\\" then
            path = path .. "/"
        else
            path = path .. tmp
        end
    end
    return path
end

function LogToConsole(log)
    if LogConfig.IsOpenConsoloeLog then
        CS_LuaUtility.Log(log)
    end
end

function LogToConsoleError(log)
    if LogConfig.IsOpenConsoloeLog then
        CS_LuaUtility.LogError(log)
    end
end

function LogToTableConsoloe(ta, title)
    if LogConfig.IsOpenConsoloeLog then
        local log = TableToString(ta)
        if title then
            log = title .. log
        end
        LogToConsole(log)
    end
end

function TableToString(tbVar)
    if LogConfig.IsOpenTableToString then
        return Library:Value2String(tbVar)
    end
    return "TableToString ..."
end

--------------------------------------
-- 格式化字节数到方便阅读的文本
-- @return
--------------------------------------
function FormatBytes(bytes)
    if bytes < 1024 then
        return tostring(bytes) .. "B"
    elseif bytes < 1048576 then
        return tostring(bytes / 1024) .. "KB"
    elseif bytes < 1073741824 then
        return tostring(bytes / 1048576) .. "MB"
    else
        return tostring(bytes / 1073741824) .. "GB"
    end
end

--------------------------------------
-- 当前函数是否执行在主线程里（非协程）
-- @return
--------------------------------------
function IsMainThread()
    local co, isMainThread = coroutine.running()
    return isMainThread
end

---格式化数值，返回整数部分
---author v_zwenzhou 2020/04/01/ 17:52
---@param num number 数值
---@return number @
function FormatNum(num)
    local t1, t2 = math.modf(num)
    return t1
end

---反转table
---author v_zwenzhou 2020/04/01/ 17:52
---@param tab table
---@return table @
function ReverseTable(tab)
    local tmp = {}
    for i = 1, #tab do
        local key = #tab
        tmp[i] = table.remove(tab)
    end

    return tmp
end

---直接执行一段lua字符串代码
function DoString(codeContent)
    local fun = load(codeContent)
    return fun()
end

---比较两个时间戳，返回相差多少时间
---@param beginTime number 开始时间
---@param endTime number 结束时间
function TimeDiff(beginTime, endTime)
    local n_beginTime = os.date("*t", beginTime)
    local n_endTime = os.date("*t", endTime)
    local isCarry = false
    local diff = {}
    local maxDay = os.date("*t", os.time {year = n_beginTime.year, month = n_beginTime.month + 1, day = 0}).day
    local colMax = {60, 60, 24, maxDay, 12, 0}

    n_endTime.hour = n_endTime.hour - (n_endTime.isdst and 1 or 0) + (n_beginTime.isdst and 1 or 0) -- handle dst
    for i, v in ipairs({"sec", "min", "hour", "day", "month", "year"}) do
        diff[v] = n_endTime[v] - n_beginTime[v] + (isCarry and -1 or 0)
        isCarry = diff[v] < 0
        if isCarry then
            diff[v] = diff[v] + colMax[i]
        end
    end
    return diff
end


local local_lua_pcall = pcall
---安全执行一个函数，会捕捉异常
function PCall(stackLevel, func, ...)
    
    local isSucc, result = local_lua_pcall(func, ...)
    if not isSucc then

        local errContent = result
        if not WEDO_PUBLIC then
            --C# 捕捉的报错，已处理堆栈
            if string.find(result, "c# exception:") then
                --C#中引发的异常，C#已经RaiseError
                -- RaiseError(stackLevel + 1, errContent)
                LogErrorWithoutRaise(errContent)
            else
                RaiseError(stackLevel + 1, errContent)
                local stackTrace = DumpStack(stackLevel + 3)
                errContent = errContent .. "\nCallStack:\n" .. stackTrace
            end
        end

        TipsCtrl:OnException(errContent)
        return nil
    end

    return result

end

function GetHash1(str)
	local seed  = 16384000   --128*128*1000
	local hash  = 0;
	local count = string.len(str)
	local len   = count
	while count > 0 do
		local _index = len - count + 1
		local num = string.byte(string.sub(str, _index, _index))
		hash = hash + seed + count *num * num;
		count = count - 1
	end
	
	return hash & 0x7FFFFFFF;
end

---获取文字长度
---author v_zwenzhou 2021-02-25 17:29:31
---@param str string 字符串
---@return number
function GetUTF8Length(str)
    local len = 0
    local current = 1
    while current <= #str do
        local char = string.byte(str,current)
        current = current + Chsize(char)
        len = len + 1
    end
    return len
end

---从指定位置读取指定长度的字符串
---author v_zwenzhou 2021-02-25 17:29:31
---@param str string 字符串
---@param startChar number 起始位置
---@param numChars number 读取长度
---@return string
function UTF8Sub(str, startChar, numChars)
    local startIndex = 1
    while startChar > 1 do
        local char = string.byte(str,startIndex)
        startIndex = startIndex + Chsize(char)
        startChar = startChar - 1
    end

    local currentIndex = startIndex

    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + Chsize(char)
        numChars = numChars - 1
    end

    return str:sub(startIndex,currentIndex - 1)
end

---获取字符的大小
---author v_zwenzhou 2021-02-25 17:29:31
---@param char string 字符串
---@return number
function Chsize(char)
    if not char then
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end

---RawAssets/StreamingAssets目录
---author rivershlin 2021/04/12/ 10:52
---@return string @
function RawAssetsPath()
    local rawAssetsPath = "RawAssets/"
    return rawAssetsPath
end

---保留指定小数位
---@param num number 源数字
---@param n number 小数位数
function GetNumber(num, n)
    if (not IsNumber(num)) then
        return num
    end

    n = n or 0
    n = math.floor(n)
    if n < 0 then
        n = 0
    end
    local nDecimal = 10 ^ n
    local nTemp = math.floor(num * nDecimal)
    local nRet = nTemp / nDecimal
    return nRet
end

---读取数字将二进制转换成table（ps:3->11->1,2 | 96->1100000->32,64）
---author v_yccycai 2021-09-08 10:16:20
---@return table
function ConvertBinaryNumToTable(number)
    local resultTable = {}
    if number >= 1 then
        local index = 0
        local power = index-1
        local tmpNum = (number>>power)
        repeat
            index = index + 1
            power = index-1
            tmpNum = (number>>power)
            local dataNum = tmpNum & 1
            if dataNum > 0 then
                table.insert(resultTable,math.floor(2^power))
            end
        until(tmpNum == 1)
    end

    return resultTable
end

