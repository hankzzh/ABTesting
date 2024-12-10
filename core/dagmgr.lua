local cjson = require "cjson"
local log = require "util.log"

local nodes = {}
local _package = {}
local _cache = {}
local dagmgr = {nodes = {}, _package = _package, _cache = _cache}

function dagmgr.print()
	log("----------------------------------------------------dagmgr.print:----------------------------------------------------")
	log(cjson.encode(dagmgr._cache))
	log("----------------------------------------------------support cmd:------------------------------------------------------")
	local reflex_func = require "core.reflex_func"
	reflex_func.help()
	log("----------------------------------------------------------------------------------------------------------------------")
end

function dagmgr.reload(name, path_name_without_ext)
	if not name or not path_name_without_ext then
		log("dagmgr.reload param", name, path_name_without_ext)
	end
	local fullname = "cfg/" .. path_name_without_ext..".json"
	local file, err = io.open(fullname, "r")
	local content
	if err or not file then
		fullname = "cfg." .. string.gsub(path_name_without_ext, "/", ".")
		content = require(fullname)
	else
		local content = file:read("*all")
		file:close()
		content = cjson.decode(content)
	end

	_cache[name] = content
	local reflex_func = require "core.reflex_func"
	_package[name] = reflex_func.parse2val(content)
	return content
end

function dagmgr.reload_all()
	_package = {}
	_cache = {}
	dagmgr._package = _package
	dagmgr._cache = _cache
	log("----------------------------------------------------dagmgr.reload_all----------------------------------------------------")
	local include = dagmgr.reload("_include", "include")
	for _, filecfg in ipairs(include) do
		dagmgr.reload(table.unpack(filecfg))
	end

    local newnode = {}
    local dagnode = require "core.dagnode"
	for id, node in pairs(dagmgr._package.nodecfg.nodes) do
        newnode[id] = dagnode.new(node)
    end
    nodes = newnode
    dagmgr.nodes = newnode
end

function dagmgr.get(id)
	log("get----------", id, nodes)
	return nodes[id]
end

function dagmgr.process(user)
    local node
	for headid in pairs(dagmgr._cache.nodecfg.headid_list) do
        node = user:get_cur_node(headid)
		log("ppppp", node)
        node:process(user, headid)
    end
    
end

return dagmgr