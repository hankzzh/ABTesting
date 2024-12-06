local reflex_func = require "core.reflex_func"
local log = require "util.log"

local dagnode_meta = {}
dagnode_meta.__index = dagnode_meta

local action_list = {"enter", "process"}
function dagnode_meta.new(cfg)
    assert(cfg.id)
    assert(cfg.level)
    local data = {
        id = cfg.id,
        level = cfg.level,
        ishead = cfg.ishead,
    }
    for _, v in ipairs(action_list) do
        data[v] = reflex_func.parse(cfg[v])
    end

    return setmetatable(data, dagnode_meta)
end

return dagnode_meta