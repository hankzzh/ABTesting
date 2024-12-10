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
		_cache[name] = cjson.encode(content)
	else
		local content = file:read("*all")
		file:close()
		_cache[name] = content
		content = cjson.decode(content)
	end

	local reflex_func = require "core.reflex_func"
	_package[name] = reflex_func.parse2val(content)
	return content
end

function dagmgr.reload_all()
	dagmgr.nodes = {}
	dagmgr._package = {}
	dagmgr._cache = {}
	log("----------------------------------------------------dagmgr.reload_all----------------------------------------------------")
	local include = dagmgr.reload("_include", "include")
	for _, filecfg in ipairs(include) do
		dagmgr.reload(table.unpack(filecfg))
	end

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