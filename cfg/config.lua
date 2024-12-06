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
local headaction = {["$go"] = {["$randombyweight"] = {release = 90, test = 10}}}
addnode({
    id = "head",
    enter = headaction,
    process = headaction,
    level = 0,
    ishead = true,
})

--------release

addnode({
    id = "release",
    level = 100,
    --enter = {["$ret"] = "i am in release"},
    enter = {["$go"] = {["$randombyweight"] = {release_1 = 50, release_2 = 150}}},
})

addnode({
    id = "release_1",
    level = 100,
    enter = {["$ret"] = "i am in release_1"},
    process = {["$if"] = {false, {["$go"] = "release"}, "nothing"}},
    --process = {["$if"] = {false, {["$ret"] = "true"}, {["$ret"] = "false"}}},
})

addnode({
    id = "release_2",
    level = 100,
    enter = {["$ret"] = {['$randombyweight'] = {["i am in release_2"] = 50, ['dddddddddddddd']=50}}},
    process = {["$go"] = "release"},
})

---------test

addnode({
    id = "test",
    level = 100,
    enter = {["$ret"] = "i am in test"},
    process = {["$go"] = "test"},
})

addnode({
    id = "test111",
    level = 100,
    aaa = {["$tf"] = {100, "template.bucket.bucket1", "template.bucket.bucket2"}},
    process = {['$func'] = {
        name = 'tf',
        body = {
            ['$if'] = {
                {['$<'] = {['$user'] = {uid = 1}}, {['$args'] = 1}},
                {['$ret'] = {['$cfg'] = {['$args'] = 2}}},
                {['$ret'] = {['$cfg'] = {['$args'] = 3}}},
            }
        },
    }},
})

return cfg
