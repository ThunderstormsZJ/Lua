require("Core.table")
require("Core.TimeUtil")

local OpenTime = {
	["EndTime"] = os.time({year =2021, month = 11, day =30, hour =22, min =00, sec = 00}),
	["LimitTimeList"] = {},
	["BeginTime"] = os.time({year =2021, month = 11, day =16, hour = 15, min =00, sec = 00}),
	["LimitType"] = 2,
}

---@class OpenTimeStatus 
---@field IsOpen boolean @是否开启时间
---@field NextSec number @距离下一个节点开启时间戳

---格式化固定格式为时间戳 eg. d=20211111 t=140000
local FormatTimeStampByDateTime = function(d, t)
	return {
		year  = math.floor(d / 10000),
		month = math.floor(math.floor(d / 100) % 100),
		day   = math.floor(d % 100),
		hour  = math.floor(t / 10000),
		min   = math.floor(math.floor(t / 100) % 100),
		sec   = math.floor(t % 100),
	}
end

local GetCurTime = function()
	return os.time()
end

--- 在指定时间戳内
local IsInTimeSecInterval = function(beginTimeStamp, endTimeStamp)
	local curTimeStamp = GetCurTime()
	return curTimeStamp >= beginTimeStamp and curTimeStamp <= endTimeStamp
end

--- 按天控制计算是否区间内
--- 起始时间戳分为两部分
---		【年月日】为总的有效控制时间范围
--- 	【时分秒】控制一天内有效的时间范围
--- 思路：
--- 	1、拆分起始时间，分离【年月日】和【时分秒】
--- 	2、将当前【年月日】 + 起始【时分秒】
--- 	3、根据新组合的起始时间戳和当前比对，进行下一节点的时间运算

local IsInTimeByTimeForEveryDay = function(beginTimeStamp, endTimeStamp)
	local curTimeStamp = GetCurTime()
	local curTimeInfo = os.date("*t", curTimeStamp)
	local beginTimeInfo = os.date("*t", beginTimeStamp)
	local endTimeInfo = os.date("*t", endTimeStamp)
	local curDate = tonumber(string.format("%d%02d%02d", curTimeInfo.year, curTimeInfo.month, curTimeInfo.day))
	local beginTime = tonumber(string.format("%d%02d%02d", beginTimeInfo.hour, beginTimeInfo.min, beginTimeInfo.sec))
	local endTime = tonumber(string.format("%d%02d%02d", endTimeInfo.hour, endTimeInfo.min, endTimeInfo.sec))

	local beginDailyInfo = FormatTimeStampByDateTime(curDate, beginTime)
	local endDailyInfo = FormatTimeStampByDateTime(curDate, endTime)
	local beginDailyStamp = os.time(beginDailyInfo)
	local endDailyStamp = os.time(endDailyInfo)
    ---@type OpenTimeStatus
    local timeStruct = {IsOpen=true, NextSec=0}
	
	if curTimeStamp < beginDailyStamp then
		timeStruct.IsOpen = false
		timeStruct.NextSec = beginDailyStamp - curTimeStamp
	else
		timeStruct.IsOpen = curTimeStamp <= endDailyStamp
		
		-- 加一天
		beginDailyInfo.day = beginDailyInfo.day + 1

		timeStruct.NextSec = os.time(beginDailyInfo) - curTimeStamp
	end

	print(TimeUtil:FormatSurplusTime(timeStruct.NextSec))
	print(timeStruct.IsOpen)
end

local IsInTimeByTimeForDayInWeek = function(beginTimeStamp, endTimeStamp, limitList)
    ---@type OpenTimeStatus
    local timeStruct = {IsOpen=true, NextSec=0}
	local limitCount = #limitList

	if limitCount == 0 then return timeStruct end

	local curTimeStamp = GetCurTime()
	local curTimeInfo = os.date("*t", curTimeStamp)
	local beginTimeInfo = os.date("*t", beginTimeStamp)
	local endTimeInfo = os.date("*t", endTimeStamp)
	local curDate = tonumber(string.format("%d%02d%02d", curTimeInfo.year, curTimeInfo.month, curTimeInfo.day))
	local beginTime = tonumber(string.format("%d%02d%02d", beginTimeInfo.hour, beginTimeInfo.min, beginTimeInfo.sec))
	local endTime = tonumber(string.format("%d%02d%02d", endTimeInfo.hour, endTimeInfo.min, endTimeInfo.sec))

	local beginDailyInfo = FormatTimeStampByDateTime(curDate, beginTime)
	local endDailyInfo = FormatTimeStampByDateTime(curDate, endTime)
	local beginDailyStamp = os.time(beginDailyInfo)
	local endDailyStamp = os.time(endDailyInfo)

	--- 获取第一个大于等于当前天数得限定值索引
	local firstWIndex = 1
	for index, wDay in ipairs(limitList) do
		if wDay >= beginDailyInfo.wday then
			firstWIndex = index
			break
		end
	end
	
	local firstWday = limitList[firstWIndex]

	local nextDayByWday = function(dailyInfo, nextWday) -- 计算下一个星期几是第几天
		dailyInfo.day = dailyInfo.day + (nextWday >= dailyInfo.wday and (nextWday - dailyInfo.wday) or (nextWday + 7 - dailyInfo.wday))
	end

	if firstWday ~= beginDailyInfo.wday then
		nextDayByWday(beginDailyInfo, firstWday)
		timeStruct.IsOpen = false
		timeStruct.NextSec = os.time(beginDailyInfo) - curTimeStamp
	else
		if curTimeStamp < beginDailyStamp then
			timeStruct.IsOpen = false
			timeStruct.NextSec = beginDailyStamp - curTimeStamp
		else
			timeStruct.IsOpen = curTimeStamp <= endDailyStamp

			-- 下一个限制节点
			nextDayByWday(beginDailyInfo, limitList[firstWIndex%limitCount + 1])

			timeStruct.NextSec = os.time(beginDailyInfo) - curTimeStamp
		end
	end

	print(TimeUtil:FormatSurplusTime(timeStruct.NextSec))
	print(timeStruct.IsOpen)
end

local IsInTimeByTimeForDayInMonth = function(beginTimeStamp, endTimeStamp, limitList)
    ---@type OpenTimeStatus
    local timeStruct = {IsOpen=true, NextSec=0}
	local limitCount = #limitList

	if limitCount == 0 then return timeStruct end

	local curTimeStamp = GetCurTime()
	local curTimeInfo = os.date("*t", curTimeStamp)
	local beginTimeInfo = os.date("*t", beginTimeStamp)
	local endTimeInfo = os.date("*t", endTimeStamp)
	local curDate = tonumber(string.format("%d%02d%02d", curTimeInfo.year, curTimeInfo.month, curTimeInfo.day))
	local beginTime = tonumber(string.format("%d%02d%02d", beginTimeInfo.hour, beginTimeInfo.min, beginTimeInfo.sec))
	local endTime = tonumber(string.format("%d%02d%02d", endTimeInfo.hour, endTimeInfo.min, endTimeInfo.sec))

	local beginDailyInfo = FormatTimeStampByDateTime(curDate, beginTime)
	local endDailyInfo = FormatTimeStampByDateTime(curDate, endTime)
	local beginDailyStamp = os.time(beginDailyInfo)
	local endDailyStamp = os.time(endDailyInfo)

	--- 获取第一个大于等于当前天数得限定值索引
	local firstDayIndex = 1
	for index, day in ipairs(limitList) do
		if day >= beginDailyInfo.day then
			firstDayIndex = index
			break
		end
	end
	
	local firstDay = limitList[firstDayIndex]

	local nextDayByMday = function(dailyInfo, nextMday) -- 计算下一个几号是第几天
		dailyInfo.month = nextMday < dailyInfo.day and (dailyInfo.month + 1) or dailyInfo.month
		dailyInfo.day = nextMday
	end

	if firstDay ~= beginDailyInfo.day then
		nextDayByMday(beginDailyInfo, firstDay)
		timeStruct.IsOpen = false
		timeStruct.NextSec = os.time(beginDailyInfo) - curTimeStamp
	else
		if curTimeStamp < beginDailyStamp then
			timeStruct.IsOpen = false
			timeStruct.NextSec = beginDailyStamp - curTimeStamp
		else
			timeStruct.IsOpen = curTimeStamp <= endDailyStamp

			-- 下一个限制节点
			nextDayByMday(beginDailyInfo, limitList[firstDayIndex%limitCount + 1])

			timeStruct.NextSec = os.time(beginDailyInfo) - curTimeStamp
		end
	end

	print(TimeUtil:FormatSurplusTime(timeStruct.NextSec))
	print(timeStruct.IsOpen)
end

print("=======")
table.dump(os.date("*t", GetCurTime()))
print("=======")

print("Current Time:" .. os.date("%Y-%m-%d %H:%M:%S", GetCurTime()))
print("Begin Time:" .. os.date("%Y-%m-%d %H:%M:%S", OpenTime.BeginTime))
print("EndTime Time:" .. os.date("%Y-%m-%d %H:%M:%S", OpenTime.EndTime))

-- print(IsInTimeByTimeForDayInWeek(OpenTime.BeginTime, OpenTime.EndTime, {1,3,5}))
-- print(GetCurTime())
-- for i = 1, 1000 do
-- 	IsInTimeByTimeForDayInMonth(OpenTime.BeginTime, OpenTime.EndTime, {30})
-- end
-- print(GetCurTime())

-- table.dump(os.date("*t", 497301704))
print("=======")
table.dump(os.date("*t", 1952128200))
-- print(os.time({year =2121, month = 11, day =11, hour = 23, min =59, sec = 59}))
-- print(os.time({year =2038, month = 11, day =22, hour = 0, min =0, sec = 0}))
-- print(os.time({year =2021, month = 11, day =22, hour = 23, min =59, sec = 59}))