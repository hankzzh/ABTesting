local log = require "util.log"

local headid_list = {}
local cfg = {nodes = {}, headid_list = headid_list}

--[[node
id:唯一标识
enter:进入执行动作
process:节点中执行动作
level:节点层级

支持指令
$randombyweight:随机权重算法
--$roundbyweight:轮循权重算法
$ret:返回结果
$go:跳转到节点
$and:逻辑--且
$or:逻辑--或
$if:逻辑--条件二选一
$not:
$>:
$>=:
$<:
$<=:
$><:
$=><:
$><=:
$=><=:
$==:
]]
local function addnode(node)
    cfg.nodes[node.id] = node
    if node.ishead then
        headid_list[node.id] = true
    end
end
addnode({
    id = "head",
	enter = { ["$get"] = { "func", "headaction" } },
	process = { ["$get"] = { "func", "headaction" } },
    level = 0,
    ishead = true,
})

--------release

addnode({
    id = "release",
    level = 100,
	buckets = { release_1 = 50, release_2 = 50 },
	--enter = { ["$go"] = { ["$randombyweight"] = { release_1 = 50, release_2 = 150 } } },
	enter = { ["$get"] = { "func", "enter"} },
})

addnode({
    id = "release_1",
    level = 100,
    enter = {["$func"] = {{["$ret"] = "i am in release_1"}}},
    process = {["$func"] = {{["$if"] = {false, {["$go"] = "release"}, "nothing"}}}},
    --process = {["$if"] = {false, {["$ret"] = "true"}, {["$ret"] = "false"}}},
})

addnode({
    id = "release_2",
    level = 100,
    enter = {["$func"] = {{["$ret"] = {['$randombyweight'] = {["i am in release_2"] = 50, ['dddddddddddddd']=50}}}}},
    process = {["$func"] = {{["$go"] = "release"}}},
})

---------test

addnode({
    id = "test",
    level = 100,
    enter = {["$func"] = {["$ret"] = "i am in test"}},
    process = {["$func"] = {["$go"] = "test"}},
})

return cfg
