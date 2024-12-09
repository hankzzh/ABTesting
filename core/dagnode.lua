local reflex_func = require "core.reflex_func"
local log = require "util.log"
local tableutil = require "util.table"

local dagnode_meta = {}
dagnode_meta.__index = dagnode_meta

local action_list = {"enter", "process"}
function dagnode_meta.new(cfg)
    if not cfg.id then
        log("err node cfg [id]", cfg)
        assert(cfg.id)
    end
    if not cfg.level then
        log("err node cfg [level]", cfg)
        assert(cfg.level)
    end
    local data = tableutil.deepcopy(cfg)
	-- log("dagnode_meta.new", cfg)
    for _, v in ipairs(action_list) do
        data[v] = reflex_func.parse2val(cfg[v])
    end

    return setmetatable(data, dagnode_meta)
end

return dagnode_meta