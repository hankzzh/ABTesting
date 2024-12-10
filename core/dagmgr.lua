local cjson = require "cjson"
local log = require "util.log"

local nodecfg = require "cfg.nodecfg"
local nodes = {}
local dagmgr = {nodes = {}, func = {}}
local json_files = {"func"}

function dagmgr.print()
	log("----------------------------------------------------dagmgr.reload:----------------------------------------------------")
	log(cjson.encode(nodecfg))
	log("----------------------------------------------------support fun:------------------------------------------------------")
	for _, filename in ipairs(json_files) do
		local path = "cfg." .. filename
		local jsonpac = require(path)
		log(cjson.encode(jsonpac))
	end
	log("----------------------------------------------------support cmd:------------------------------------------------------")
	local reflex_func = require "core.reflex_func"
	reflex_func.help()
	log("----------------------------------------------------------------------------------------------------------------------")
end

function dagmgr.reload()
	local reflex_func = require "core.reflex_func"
	for _, filename in ipairs(json_files) do
		local path = "cfg." .. filename
		local jsonpac = require(path)
		dagmgr[filename] = dagmgr[filename] or {}
		for k, v in pairs(jsonpac) do
			dagmgr[filename][k] = reflex_func.parse2val(v)
		end
	end
    local newnode = {}
    local dagnode = require "core.dagnode"
	for id, node in pairs(nodecfg.nodes) do
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
	for headid in pairs(nodecfg.headid_list) do
        node = user:get_cur_node(headid)
		-- log("ppppp", node)
        node:process(user, headid)
    end
    
end

return dagmgr