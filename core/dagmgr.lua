local cjson = require "cjson"
local log = require "util.log"

local _package = {}
local _cache = {}
local dagmgr = {_package = _package, _cache = _cache}

function dagmgr.print()
	log("----------------------------------------------------dagmgr.print:----------------------------------------------------")
	log(cjson.encode(dagmgr._cache))
	log("----------------------------------------------------support cmd:------------------------------------------------------")
	local reflex_func = require "core.reflex_func"
	reflex_func.help()
	log("----------------------------------------------------------------------------------------------------------------------")
end

function dagmgr.reload(name, path_name_without_ext)
	log("reload", name, path_name_without_ext)
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
	_package[name] = reflex_func.pcall(content)
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
end

function dagmgr.get(id)
	--log("get----------", id, nodes)
	return dagmgr._package.nodecfg.nodes[id]
end

function dagmgr.process(user)
    local node
	for headid in pairs(dagmgr._package.nodecfg.headid_list) do
        node = user:get_cur_node(headid)
		-- log("ppppp", node)
        local ret = node.process(nil, user, headid, node)
		-- log("ppppp node.process result", ret)
    end
    
end

return dagmgr