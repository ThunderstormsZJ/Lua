require("Core.CommonDef")
require("Core.Util")

TimeUtil = {}

---Day, Hour, Min, Sec
function TimeUtil:FormatTimeStr(t)
    local str = ""
    if t.Day then
        str = string.format("%s%sT", str, t.Day)
    end
    if t.Hour then
        str = string.format("%s%sH", str, t.Hour)
    end
    if t.Min then
        str = string.format("%s%sM", str, t.Min)
    end
    if t.Sec then
        str = string.format("%s%sS", str, t.Sec)
    end
    return str
end

function TimeUtil:FormatTime(format, time)
    return os.date(format, time)
end

--region 将一个时间戳分解为年月日时分秒结构
---将一个时间戳分解为年月日时分秒结构
---author v_zwenzhou 2021-08-19 15:10:55
---@param time number 时间戳
---@return DateTime
function TimeUtil:ReplaceTime(time)
    if (NumberIsNull(time)) then
        return nil
    end

    ---@type DateTime
    local tb = {}
    tb.Year = tonumber(os.date("%Y",time))
    tb.Month =tonumber(os.date("%m",time))
    tb.Day = tonumber(os.date("%d",time))
    tb.Hour = tonumber(os.date("%H",time))
    tb.Min = tonumber(os.date("%M",time))
    tb.Second = tonumber(os.date("%S",time))
    return tb
end
--endregion 将一个时间戳分解为年月日时分秒

--region 将一个时间戳分解为日时分秒
---将一个时间戳分解为日时分秒，年月通通转化为多少天
---author v_zwenzhou 2021-08-19 15:54:05
---@param time number 时间戳
---@return DateTime
function TimeUtil:ReplaceSurplusTime(time)
    if (NumberIsNull(time)) then
        return nil
    end

    ---@type DateTime
    local tb = {}
    tb.Day = math.floor(time / (3600 * 24))
    tb.Hour = math.floor(time % (3600 * 24) / 3600)
    tb.Min = math.floor(time % 3600 / 60)
    tb.Second = math.floor(time % 60)
    return tb
end
--endregion 将一个时间戳分解为日时分秒

--region 格式化时间，返回字符串(X日X时 | X时X分 | X分)
---格式化剩余时间，返回字符串(X日X时 | X时X分 | X分)
---author v_zwenzhou 2021-08-19 15:24:58
---@param time number 剩余时间秒数
---@param tofloor boolean 如果为true，末尾时间向下取整
---@param timeFormatParams TimeFormatParams 是否显示对应的时间(分钟,秒)
---@return string
function TimeUtil:FormatSurplusTime(time,timeFormatParams)
    local date = self:ReplaceSurplusTime(time)
    local timeStr = ""
    local timeIntervalType = TimeIntervalType.None

    if date then
        if date.Day > 0 then
            if timeFormatParams and not table.is_empty(timeFormatParams) and timeFormatParams.ShowMin then
                timeStr = self:FormatTimeStr({["Day"] = date.Day, ["Hour"] = date.Hour, ["Min"] = date.Min})
            else
                --最小位显示小时的时候,需要把分向上取整
                if date.Min > 0 then
                    date.Hour = date.Hour + 1
                end
                if date.Hour >= 24 then
                    date.Hour = 0
                    date.Day = date.Day + 1
                end
                timeStr = self:FormatTimeStr({["Day"] = date.Day, ["Hour"] = date.Hour})
            end

            timeIntervalType = TimeIntervalType.Min
        elseif date.Hour > 0 then
            --最小位显示分的时候,需要把秒向上取整     
            if date.Second > 0 then
                date.Min = date.Min + 1
            end
            if date.Min >= 60 then
                date.Min = 0
                date.Hour = date.Hour + 1
                if date.Hour >= 24 then
                    date.Hour = 0
                    date.Day = date.Day + 1
                end
            end
            timeStr = self:FormatTimeStr({["Hour"] = date.Hour, ["Min"] = date.Min})
            timeIntervalType = TimeIntervalType.Min
        elseif date.Min > 0 then
            timeStr = self:FormatTimeStr({["Min"] = date.Min, ["Sec"] = date.Second})
            timeIntervalType = TimeIntervalType.Sec
        elseif date.Second > 0 then
            timeStr = self:FormatTimeStr({["Sec"] = date.Second})
            timeIntervalType = TimeIntervalType.Sec
        else
            -- 倒计时为零
        end
    end

    return timeStr, timeIntervalType
end

---格式化剩余时间，大于一天时，规则如FormatSurplusTime，小于一天时，返回hh:mm:ss
---author yongmingxie 2021-09-25 18:34:02
---@param time number 剩余时间秒数
---@param tofloor boolean 如果为true，末尾时间向下取整
---@return string
function TimeUtil:FormatSurplusTimeExt(time)
    local date = self:ReplaceSurplusTime(time)
    local timeStr = ""
    if date then
        if date.Day > 0 then
            timeStr = self:FormatTimeStr({["Day"] = date.Day, ["Hour"] = date.Hour})
        else
            timeStr = string.format("%02d:%02d:%02d",  date.Hour, date.Min, date.Second)
        end
    else
        timeStr = "00:00:00"
    end
    return timeStr
end
--endregion 格式化时间，返回字符串(X日X时 | X时X分 | X分)

--- =========================
--- #time   2021-09-09 14:59:10
--- #author v_qzzqzhao
--- #desc  获取今天的日期字符串
---@return string  如： 20161212
--- #========================
function TimeUtil:GetDateStrOfDay()
    local serverTime = CommonHelper.GetServerTime()
    ---@type DateTime
    local timeDataTB = self:ReplaceTime(serverTime)

    local dateStr = timeDataTB.Year..string.format("%02d", timeDataTB.Month)..string.format("%02d", timeDataTB.Day)
    return dateStr
end

--region 获取当前服务器时间戳转换的时间结构
---获取当前服务器时间戳转换的时间结构
---author v_zwenzhou 2021-08-19 15:19:54
---@return DateTime
function TimeUtil:GetServerDateTime()
    return self:ReplaceTime(CommonHelper.GetServerTime())
end
--endregion 获取当前服务器时间戳转换的时间结构

---将字符串格式的日期时间，转换为time(number类型)
---author hopli 2016/11/04
---@param strDate string 格式"20160715"
---@param strTime string 格式"210000"
---@return number
function TimeUtil:DateTimeString2Time(strDate,strTime)
    -- body
    local nDate = tonumber(strDate) or 0;
    local nTime = tonumber(strTime) or 0;

    if type(nDate) ~= "number" or type(nTime) ~= "number" then
        LuaCM_LuaAssert(false,"err param type");
        return 0;
    end

    nDate = math.floor(nDate);
    nTime = math.floor(nTime);

    local nYear = math.floor(nDate / 10000);
    local nMonth = math.floor(nDate / 100) % 100;
    local nDay = nDate % 100;

    local nHour = math.floor(nTime / 10000);
    local nMin = math.floor(nTime / 100) % 100;
    local nSec = nTime % 100;

    local tbDateTime = {}
    tbDateTime["year"] = nYear
    tbDateTime["month"] = nMonth
    tbDateTime["day"] = nDay

    tbDateTime["hour"] = nHour
    tbDateTime["min"] = nMin
    tbDateTime["sec"] = nSec

    return os.time(tbDateTime) or 0;
end

---转换当地时间戳到格林尼治时间（0时区）
---author hopli 2017/07/06
---@return number
function TimeUtil:CovertLocalTime2Gmt(timestamp)
    --Pass
    if type(timestamp) ~= "number" then
        return 0;
    end
    
    return timestamp + TimeUtil:GetGMTDiffSec()
end

---转换北京时间戳到格林尼治时间（0时区）
---author hopli 2017/07/06
---@return number
function TimeUtil:CovertBeiJingTime2Gmt(timestamp)
    if type(timestamp) ~= "number" then
        return 0;
    end

    local nBeiJingDiffSec = 28800;   --8 * 60 * 60;
    
    return timestamp + nBeiJingDiffSec
end

---获取当地时间与格林尼治的时间差。想要纠正到格林尼治标准时间（0时区）需要加上这里的返回值
---author hopli 2017/07/06
---@return number
function TimeUtil:GetGMTDiffSec()
    --不能用第一天，在某些时区会为负值
    local localTime = os.time{year=1970, month=1, day=2, hour=0}

    return 86400 - localTime            --24 * 60 * 60
end

---获取时间差代表多少天，略去小数。0.5天返回0
---author hopli 2017/03/23
---@return number
function TimeUtil:GetTime2Day(nDiffTime )
    if type(nDiffTime) ~= "number" then
        return 0;
    end

    if nDiffTime < 0 then
        nDiffTime = 0;
    end

    return math.floor(nDiffTime / 86400)
end

---时间差值转换为年 月 日 时 分 秒（这里以北京时区作为转换）
---author hopli 2017/03/31
---@return number,number,number,number,number,number
function TimeUtil:DiffTime2YMDHMS( nDiffSec )
    if nDiffSec < 0 then
        return nil;
    end

    local nTimeTrans = nDiffSec + 57600;   --加上16小时，转换到北京时间的第二天

    local nYear = tonumber(os.date("%Y",nTimeTrans));
    local nMonth = tonumber(os.date("%m",nTimeTrans));
    local nDay = tonumber(os.date("%d",nTimeTrans)) - 1;    --前面加了一天，这里减回去

    local nHour = tonumber(os.date("%H", nTimeTrans));
    local nMin = tonumber(os.date("%M", nTimeTrans));
    local nSec = tonumber(os.date("%S", nTimeTrans));

    return nYear,nMonth,nDay,nHour,nMin,nSec
end

---得到当前时间距离时间戳的时间差
---@param timeStamp number 时间戳
---@return number
function TimeUtil:GetDiffBetweenNow(timeStamp)
    return CommonHelper.GetServerTime() - timeStamp
end

---是否今天的时间
---@param timeStamp number 时间戳
---@param isServerTime boolean timeStamp是否对应服务器时间。否则为本地时间
---@return boolean
function TimeUtil:IsToday(timeStamp, isServerTime)
    local nowTime = 0
    if isServerTime then
        nowTime = CommonHelper.GetServerTime(false)
    else
        nowTime = os.time()
    end

    local timeStr = os.date("%Y-%m-%d", timeStamp)
    local nowTimeStr = os.date("%Y-%m-%d", nowTime)

    return timeStr == nowTimeStr
end

-- 当天时间是否在某个时间段内
function TimeUtil:IsCurDayTime(startTime, endTime)
	if startTime > endTime then
		return false
	end
	local serverTime = CommonHelper.GetServerTime(true)
	local timeNum = os.date("%H%M%S", math.floor(serverTime))
	local time  = tonumber(timeNum);
	return time >= startTime and time <= endTime 
end

--- =========================
--- #time   2021-09-09 15:31:46
--- #author v_qzzqzhao
--- #desc   获取当前时间与每日的目标时间差多少的时间
---@param targetTimeStr string 如 050000 凌晨5点
---@return number
--- #========================
function TimeUtil:GetTimeDifferenceFromDailyTarget(targetTimeStr)
    local curDateStr = TimeUtil:GetDateStrOfDay()

    local targetTimestamp = TimeUtil:DateTimeString2Time(curDateStr, targetTimeStr)

    local serverTime = CommonHelper.GetServerTime();
    if targetTimestamp < serverTime then
        targetTimestamp = targetTimestamp + 24 * 60 * 60
    end

    return targetTimestamp - serverTime;
end

---判断服务器时间是否在给定的时间范围内
---author v_cqqcqiu 2021-08-13 14:59:38
---@return table
function TimeUtil:IsInTimeSection(beginTime,endTime,beginDate,endDate)
    if beginTime == "" or endTime == "" then return false end

    local time = CommonHelper.GetServerTime()
    local YMD = os.date("%Y%m%d", time)
    local appt = TimeUtil:DateTimeString2Time(beginDate and beginDate or YMD,beginTime)
    local disappt = TimeUtil:DateTimeString2Time(endDate and endDate or YMD,endTime)
    return (time>= appt) and (time<=disappt)
end
