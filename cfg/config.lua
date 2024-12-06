local log = require "util.log"

local headid_list = {}
local cfg = {nodes = {}, headid_list = headid_list}

--[[node
id:Ψһ��ʶ
enter:����ִ�ж���
process:�ڵ���ִ�ж���
level:�ڵ�㼶

֧��ָ��
$randombyweight:���Ȩ���㷨
--$roundbyweight:��ѭȨ���㷨
$ret:���ؽ��
$go:��ת���ڵ�
$and:�߼�--��
$or:�߼�--��
$if:�߼�--������ѡһ
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
