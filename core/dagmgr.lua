local cjson = require "cjson"
local log = require "util.log"

local nodes = {}
local dagmgr = {nodes = {}, func = {}}
local json_files = {"func"}

function dagmgr.print()
	log("----------------------------------------------------dagmgr.reload:----------------------------------------------------")
	log(cjson.encode(dagmgr.nodecfg))
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

function dagmgr.reload(filename)
	local file, err = io.open("cfg/"..filename..".json", "r")
	if err or not file then
		file = require("cfg."..filename)
		return file
	end
	local content = file:read("*all")
	print(content)
	file:close()
	return cjson.decode(content)
end

function dagmgr.reload_all()
	local reflex_func = require "core.reflex_func"
	for _, filename in ipairs(json_files) do
		local jsonpac = dagmgr.reload(filename)
		dagmgr[filename] = dagmgr[filename] or {}
		for k, v in pairs(jsonpac) do
			dagmgr[filename][k] = reflex_func.parse2val(v)
		end
	end
	dagmgr.nodecfg = dagmgr.reload("nodecfg")

    local newnode = {}
    local dagnode = require "core.dagnode"
	for id, node in pairs(dagmgr.nodecfg.nodes) do
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
	for headid in pairs(dagmgr.nodecfg.headid_list) do
        node = user:get_cur_node(headid)
		-- log("ppppp", node)
        node:process(user, headid)
    end
    
end

return dagmgr