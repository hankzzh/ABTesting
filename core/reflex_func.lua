local reflex_define = require "core.reflex_define"
local util = require "util.util"
local dagmgr = require "core.dagmgr"
local log = require "util.log"

local rfuncs = {}
local cmdlist = {}

--
function rfuncs.register(h)
	if not h.cmd or not h.cmd.name then
		log("eeeeeee", h)
	end
    cmdlist[h.cmd.name] = h
end

function rfuncs.help()
	for key, h in pairs(reflex_define) do
		log(string.format("%-20s:%s", h.name, h.comment))
	end
end

function rfuncs.get(name)
    local h = cmdlist[name]
    if not h then
        return
    end
    if h.cmd.selfparse then
        return h.func
    end
    return function (args, user, headid, dn)
		--log("ddd", args, dagmgr._package.func)
        args = rfuncs.parse2val(args, dn, user, headid)
        return h.func(args, user, headid, dn)
    end
end

function rfuncs.parse2val(args, dn, user, headid)
	local f = rfuncs.parse(args)
    return f(dn, user, headid)
end

function rfuncs.pcall(tbl, ...)
	if type(tbl) ~= "table" then
		return tbl
	end
	local replacement = {}
	for name, args in pairs(tbl) do
		name = rfuncs.pcall(name)
		local f = rfuncs.get(name)
		if f then
			return f(tbl, ...)
		else
			replacement[name] = rfuncs.pcall(args, ...)
		end
	end
	return replacement
end

function rfuncs.func(tbl)
	return function (...)
		return rfuncs.pcall(tbl, ...)
	end
end

function rfuncs.parse(valorcfg)
    return function (dn, user, headid)
        if type(valorcfg) ~= "table" then
            return valorcfg
        end
        local replacement = {}
        for name, args in pairs(valorcfg) do
			name = rfuncs.parse2val(name, dn, user, headid)
            local f = rfuncs.get(name)
            if f then
                return f(args, user, headid, dn)
                -- args = rfuncs.parse(args)
                -- return f(dn, user, args(dn, user))
            else
                replacement[name] = rfuncs.parse2val(args, dn, user, headid)
            end
        end
        return replacement
    end
end
rfuncs.parse2val = rfuncs.pcall
rfuncs.parse = rfuncs.func

local REG = rfuncs.register

REG {
	cmd = reflex_define.FUNC,
	func = function(args, user, headid, dn)
		return rfuncs.parse(args)
	end
}

REG {
    cmd = reflex_define.FOREACH,
    func = function(args, user, headid, dn)
        local param = {['$k'] = 'k', ['$v'] = 'v'}
        if "table" ~= type(args) or #args < 2 then
            log("FOREACH err args", args)
            return
        end
        --log("00--argsargsargs---0000", args)
        local tbl, f = table.unpack(args, 1, 2)
        local newargs = {}
        local kv = {}
        for i = 3, #args do
            table.insert(newargs, args[i])
            local key2idx = param[args[i]]
            if key2idx then
                kv[key2idx] = i - 2
            end
        end
        --log("00--tbltbltbl---0000", tbl)
        for k, v in pairs(tbl) do
            for name, idx in pairs(kv) do
                if name == 'k' then
                    newargs[idx] = k
                elseif name == 'v' then
                    newargs[idx] = v
                end
            end
            local tf = type(f)
            --log("00-----0000", {[tf] = newargs})
            if "functions" == tf then
                f(dn, user, headid, newargs)
            elseif "string" == tf then
                rfuncs.parse2val({[f] = newargs}, dn, user, headid)
            else
                log("FOREACH err", args)
            end
        end
    end
}

REG {
    cmd = reflex_define.AND,
    func = function(args, user, headid, dn)
        for _, value in ipairs(args) do
			value = rfuncs.parse2val(value, dn, user, headid)
            if not value then
                return
            end
        end
        return true
    end
}

REG {
    cmd = reflex_define.OR,
    func = function(args, user, headid, dn)
        for _, value in ipairs(args) do
			value = rfuncs.parse2val(value, dn, user, headid)
            if not value then
                return true
            end
        end
    end
}

REG {
    cmd = reflex_define.IF,
    func = function(args, user, headid, dn)
        if #args ~= 3 then
            return
        end
        local cond = rfuncs.parse2val(args[1], dn, user, headid)
        -- user:log("cond", cond)
        if cond then
            -- user:log("cond", 2)
            return rfuncs.parse2val(args[2], dn, user, headid)
        else
            -- user:log("cond", 3)
			return rfuncs.parse2val(args[3], dn, user, headid)
		end
    end
}

REG {
    cmd = reflex_define.NOT,
    func = function(args, user, headid, dn)
        if not args then
            return true
        end
        return false
    end
}

REG {
	cmd = reflex_define.GET,
	func = function(args, user, headid, dn)
		if not args or not next(args) then
			return
		end
		local result
		for i, key in ipairs(args) do
			if 1 == i then
				result = dagmgr._package[key]
			else
				result = result[key]
			end
			if not result then
				return result
			end
		end
		return result
	end
}

REG {
	cmd = reflex_define.SET,
	func = function(args, user, headid, dn)
		if not args or not next(args) then
			return
		end
		local result
		for i, key in ipairs(args) do
			if 1 == i then
				result = dagmgr._package[key]
			else
				result = result[key]
			end
			if not result then
				return result
			end
		end
		return result
	end
}

REG {
	cmd = reflex_define.NODE,
	func = function(args, user, headid, dn)
        --log("node.......", dn, args)
		if not args or not next(args) then
			return dn
		end
		local result = dn
		for _, key in ipairs(args) do
			result = result[key]
			if not result then
				return result
			end
		end
		return result
	end
}

REG {
    cmd = reflex_define.RANDOMBYWEIGHT,
    func = function(args, user, headid, dn)
        return util.randombyweight(args)
    end
}

REG {
    cmd = reflex_define.ROUNDBYWEIGHT,
    func = function(args, user, headid, dn)
        return util.randombyweight(args)
    end
}

REG {
    cmd = reflex_define.GO,
    func = function(args, user, headid, dn)
		log("gogogogogogogogogogogogogogogogo", args)
        local newnode = dagmgr.get(args)
        user:changenode(headid, dn, newnode)
    end
}

REG {
    cmd = reflex_define.RET,
    func = function(args, user, headid, dn)
        log("return at node, content add later", dn and dn.id, args)
    end
}

REG {
    cmd = reflex_define.GT,
    func = function(args, user, headid, dn)
        return args[1] > args[2]
    end
}

REG {
    cmd = reflex_define.GTE,
    func = function(args, user, headid, dn)
        return args[1] >= args[2]
    end
}

REG {
    cmd = reflex_define.LT,
    func = function(args, user, headid, dn)
        return args[1] < args[2]
    end
}

REG {
    cmd = reflex_define.LTE,
    func = function(args, user, headid, dn)
        return args[1] <= args[2]
    end
}

REG {
    cmd = reflex_define.BTW1,
    func = function(args, user, headid, dn)
        local val = rfuncs.parse2val(args[1], dn, user, headid)
        local min = rfuncs.parse2val(args[2], dn, user, headid)
        if val <= min then
            return false
        end
        local max = rfuncs.parse2val(args[3], dn, user, headid)
        return val < max
    end
}

REG {
    cmd = reflex_define.BTW2,
    func = function(args, user, headid, dn)
        local val = rfuncs.parse2val(args[1], dn, user, headid)
        local min = rfuncs.parse2val(args[2], dn, user, headid)
        if val < min then
            return false
        end
        local max = rfuncs.parse2val(args[3], dn, user, headid)
        return val < max
    end
}

REG {
    cmd = reflex_define.BTW3,
    func = function(args, user, headid, dn)
        local val = rfuncs.parse2val(args[1], dn, user, headid)
        local min = rfuncs.parse2val(args[2], dn, user, headid)
        if val <= min then
            return false
        end
        local max = rfuncs.parse2val(args[3], dn, user, headid)
        return val <= max
    end
}

REG {
    cmd = reflex_define.BTW4,
    func = function(args, user, headid, dn)
        local val = rfuncs.parse2val(args[1], dn, user, headid)
        local min = rfuncs.parse2val(args[2], dn, user, headid)
        if val < min then
            return false
        end
        local max = rfuncs.parse2val(args[3], dn, user, headid)
        return val <= max
    end
}

REG {
    cmd = reflex_define.EQ,
    func = function(args, user, headid, dn)
        return args[1] == args[2]
    end
}


return rfuncs