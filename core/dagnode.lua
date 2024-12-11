local reflex_func = require "core.reflex_func"
local log = require "util.log"
local tableutil = require "util.table"

local dagnode_meta = {}
dagnode_meta.__index = dagnode_meta

function dagnode_meta.new(data)
    if not data.id then
        log("err node cfg [id]", data)
        assert(data.id)
    end
    if not data.level then
        log("err node cfg [level]", data)
        assert(data.level)
    end
	--log("dagnode_meta.new", data)
    return setmetatable(data, dagnode_meta)
end

return dagnode_meta