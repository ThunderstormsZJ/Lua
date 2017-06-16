local table = {
	1, 3, nil, intable = {3, 4, 5}, 5
}

local table = {
	[1]=1, 
    [2]=3, 
    [2]=4,
    [4]=5,
    [5]=7 
}

function testA()
	a = 3
	print(a)
end

function testB()
    --[[
        table 中的其他table遍历的时候会直接的跳过
        但是pairs会在最后打印出table的地址
        pairs在下标重复的情况下会打印最后一个重复的值
    ]]
    -- pairs 会输出table中所有的key, value
    for i, v in pairs(table) do
		print("pairs:", i, v)
	end
    print("");
    -- ipairs 遇到nil会直接结束循环,并且在标记了下标的情况下若不是连续的也会直接结束循环
	for i, v in ipairs(table) do
		print("ipairs:", i, v)
	end
end

testB()
