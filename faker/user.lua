local log = require "util.log"
local stat = require "util.stat"
local dagmgr = require "core.dagmgr"
local tableutil = require "util.table"

local user_meta = {}
user_meta.__index = user_meta




function user_meta.new(req)
    local data = tableutil.deepcopy(req)
--[[
{
    [head1_id] = {node_lvl1, node_lvl2, ...},
    [head2_id] = {node_lvl1, node_lvl2, ...},
    ...
}
]]
    data.node_list = {}
    return setmetatable(data, user_meta)
end
--user_meta.__call = user_meta.init

function user_meta:log(msg, ...)
    log("uid:"..self.uid.." -> "..msg, ...)
end

function user_meta:count()
    for headid, his in pairs(self.node_list) do
        stat.count(headid, his[#his])
    end
    -- for nodeid in pairs(self.nodeidHistory) do
    --     stat.count(nodeid)
    -- end
end

function user_meta:get_cur_node(headid)
    local his = self.node_list[headid]
    if not his or not next(his) then
        return dagmgr.get(headid)
    end
    return dagmgr.get(his[#his])
end

--node转移不允许跨head
--    [head1_id] = {node_lvl1, node_lvl2, ...},
function user_meta:set_node_list(headid, from, to)
    if to.ishead then
        if to.id == headid then
            self.node_list[headid] = {}
            return true
        else
            self:log("node转移不允许跨head", from, to)
            return
        end
    end
    if from.ishead then
        if from.id == headid then
            if to.ishead then
                self:log("node转移不允许跨head", from, to)
                return
            else
                self.node_list[headid] = {to.id}
                return true
            end
        else
            self:log("node转移不允许跨head", from, to)
            return
        end
    end
    -- self:log("from", from)
    -- self:log("to", to)
    local his = self.node_list[headid]
    local node
    for i = #his, 1, -1 do
        node = dagmgr.get(his[i])
        if to.level <= node.level then
            table.remove(his, i)
        else
            table.insert(his, to.id)
            return true
        end
    end
    if #his == 0 then
        self.node_list[headid] = {to.id}
    end
    return true
end

--[[
[id] = {level1_id, level2_id,...}
]]
function user_meta:changenode(headid, from, to)
    if not self:set_node_list(headid, from, to) then
        return
    end
    to:enter(self, headid)
end

return user_meta