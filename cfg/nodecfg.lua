local log = require "util.log"

local headid_list = {}
local cfg = {nodes = {}, headid_list = headid_list}

local function addnode(node)
    cfg.nodes[node.id] = node
    if node.ishead then
        headid_list[node.id] = true
    end
end
addnode({
    id = "head",

	enter = {["$get"] = { "func", "headaction" }},
	process = {["$get"] = { "func", "headaction" }},
    level = 0,
    ishead = true,
    --test = {['$foreach'] = {{ ["$get"] = { "func" } }, "$ret", "$k"}}
})

--------release

addnode({
    id = "release",
    level = 100,
	buckets = { release_1 = 50, release_2 = 50 },
	enter = {["$get"] = { "func", "enterction" }},
})

addnode({
    id = "release_1",
    level = 100,
    enter = {["$func"] = {["$ret"] = "i am in release_1"}},
    process = {["$func"] = {{["$if"] = {false, {["$go"] = "release"}, "nothing"}}}},
    --process = {["$if"] = {false, {["$ret"] = "true"}, {["$ret"] = "false"}}},
})

addnode({
    id = "release_2",
    level = 100,
    enter = {["$func"] = {["$ret"] = {['$randombyweight'] = {["i am in release_2"] = 50, ['dddddddddddddd']=50}}}},
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
