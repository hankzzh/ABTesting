local cjson = require "cjson"
local log = require "util.log"

local config = require "cfg.config"
local nodes = {}
local dagmgr = {nodes = {}}

function dagmgr.reload()
    local newnode = {}
    local dagnode = require "core.dagnode"
    log("----------------------------------------------------dagmgr.reload:----------------------------------------------------")
    log(cjson.encode(config))
    log("----------------------------------------------------------------------------------------------------------------------")
    for id, node in pairs(config.nodes) do
        newnode[id] = dagnode.new(node)
    end
    nodes = newnode
    dagmgr.nodes = newnode
end

function dagmgr.get(id)
    return nodes[id]
end

function dagmgr.process(user)
    local node
    for headid in pairs(config.headid_list) do
        node = user:get_cur_node(headid)
        node:process(user, headid)
    end
    
end

return dagmgr