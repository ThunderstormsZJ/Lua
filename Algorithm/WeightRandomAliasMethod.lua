require("Core.table")

-- 别名采样算法
-- 时间复杂度：O(1)/预采样O(n)
-- 离散分布转化为：均匀分布+二项分布
---author JunZhou 2021/12/17/ 15:13
---@alias AliasMethodWeightTB {Index:number, Odd: number}
---@param weights table @权重值列表
---@param contentList table | nil @与权重值索引对应的内容
---@return fun():number,table @返回权重索引和对应内容的索引
function AliasMethodWeightRandom(weights, contentList)
    if table.is_empty(weights) then
        return function()
            return 0, nil
        end
    end

    local count = #weights
    -- 1、 求平均权重
    local sum = 0
    for _, w in ipairs(weights) do
        sum = sum + w
    end
    local avg = sum / count

    -- 2、 初始化别名表
    ---@type AliasMethodWeightTB[]
    local aliases = {}
    for i = 1, count do
        table.insert(aliases, {Index=1, Odd=1})
    end
    -- 3、找到第一个小于平均权重的值
    local sIdx = 1
    while sIdx <= count and weights[sIdx] >= avg do
        sIdx = sIdx + 1
    end

    if sIdx <= count then -- 如果大于总数量，说明所有的权重都是相等的
        -- 4、将大权重分配给小权重（平均化）

        local bIdx = 1
        while bIdx <= count and weights[bIdx] < avg do
            bIdx = bIdx + 1
        end

        ---@type AliasMethodWeightTB
        local big, small = {Index = bIdx, Odd = weights[bIdx]/avg}, {Index = sIdx, Odd = weights[sIdx]/avg}

        while true do
            aliases[small.Index] = {Index = big.Index, Odd = small.Odd}
            big = {Index = bIdx, Odd =  big.Odd - (1 - small.Odd)} -- 计算补充完小权重的大权重还剩多少
    
            if big.Odd < 1 then -- 变成了小权重，查找下一个大权重
                small = big
                bIdx = bIdx + 1
    
                while bIdx <= count and weights[bIdx] < avg do
                    bIdx = bIdx + 1
                end
    
                if bIdx > count then
                    break
                end

                big = {Index = bIdx, Odd = weights[bIdx]/avg}
            else -- 继续查找下一个小权重补充
                sIdx = sIdx + 1
                while sIdx <= count and weights[sIdx] >= avg do
                    sIdx = sIdx + 1
                end

                if sIdx > count then
                    break
                end

                small = {Index = sIdx, Odd = weights[sIdx]/avg}
            end
        end
    end

    return function()
        local n = math.random() * count
        local i = math.floor(n)
        local curAlias = aliases[i + 1]
        local index, odd = curAlias.Index, curAlias.Odd

        local idx
        if n - i > odd then
            idx = index
        else
            idx = i + 1 
        end

        local content
        if not table.is_empty(contentList) then
            content = contentList[idx]
        end

        return idx, content
    end
end

--region For Test
  
local weights = {10, 30, 50, 100, 200, 500, 125, 400}
local a = os.time()
local randomW = AliasMethodWeightRandom(weights)
local b = os.time()
print("Pre Time: ", b-a)

local countMap = {}
local sum = 0
for i, v in ipairs(weights) do
    countMap[v] = 0
    sum = sum + v
end

local countNum = 10
a = os.time()
for i = 1, countNum do
    local index = randomW()
    countMap[weights[index]] = countMap[weights[index]] + 1
end
b = os.time()

print("Gen Time: ", b - a)

local oddSum, realOddSum = 0, 0
for k, v in pairs(countMap) do
    oddSum = oddSum + v/countNum
    realOddSum = realOddSum + k/sum
    print(string.format("Weight: %s Odd: %s Real Odd: %s", k, v/countNum, k/sum))
end

print(string.format("OddSum: %s RealOddSum: %s", oddSum, realOddSum))
--endregion