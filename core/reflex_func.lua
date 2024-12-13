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
        args = rfuncs.pcall(args, user, headid, dn)
        return h.func(args, user, headid, dn)
    end
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
            --log("pcall--", name, {tbl, ...})
			return f(args, ...)
		else
			replacement[name] = rfuncs.pcall(args, ...)
		end
	end
	return replacement
end

function rfuncs.func(tbl, user, headid, dn)
	return function (args, ...)
        log("func pcall--", {tbl=tbl, user=user, headid=headid, dn=dn}, {args = args, param = {...}})
		return rfuncs.pcall(args or tbl, ...)
	end
end


local REG = rfuncs.register

REG {
	cmd = reflex_define.FUNC,
	func = function(args, user, headid, dn)
		return rfuncs.func(args, user, headid, dn)
	end
}

REG {
	cmd = reflex_define.SET,
	func = function(args, user, headid, dn)
        log("ssssssssssssssssssssssssssssssss", args, user, headid, dn)
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
    cmd = reflex_define.FOREACH,
    func = function(args, user, headid, dn)
        local param = {['$k'] = 'k', ['$v'] = 'v'}
        if "table" ~= type(args) or #args < 2 then
            log("FOREACH err args", args)
            return
        end
        local tbl, f = table.unpack(args, 1, 2)
        log("FOREACH", {tbl  = tbl, f=f})
        local newargs = {}
        local kv = {}
        for i = 3, #args do
            table.insert(newargs, args[i])
            local key2idx = param[args[i]]
            if key2idx then
                kv[key2idx] = i - 2
            end
        end
        for k, v in pairs(tbl) do
            for name, idx in pairs(kv) do
                if name == 'k' then
                    newargs[idx] = k
                elseif name == 'v' then
                    newargs[idx] = v
                end
            end
            --rfuncs.pcall(f, {k, v}, user, headid, dn)
            f({k, v}, user, headid, dn)
            -- local tf = type(f)
            -- --log("00-----0000", {[tf] = newargs})
            -- if "functions" == tf then
            --     f(newargs, user, headid, dn)
            -- elseif "string" == tf then
            --     rfuncs.pcall({[f] = newargs}, user, headid, dn)
            -- else
            --     log("FOREACH err", args)
            -- end
        end
    end
}

REG {
    cmd = reflex_define.AND,
    func = function(args, user, headid, dn)
        for _, value in ipairs(args) do
			value = rfuncs.pcall(value, user, headid, dn)
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
			value = rfuncs.pcall(value, user, headid, dn)
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
        local cond = rfuncs.pcall(args[1], user, headid, dn)
        -- user:log("cond", cond)
        if cond then
            -- user:log("cond", 2)
            return rfuncs.pcall(args[2], user, headid, dn)
        else
            -- user:log("cond", 3)
			return rfuncs.pcall(args[3], user, headid, dn)
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
		local result = dn or dagmgr._package
		for i, key in ipairs(args) do
            result = result[key]
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
        -- log("node.......", {args=args, user=user, headid=headid, dn=dn})
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
        -- log("randombyweight", args)
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
        local val = rfuncs.pcall(args[1], user, headid, dn)
        local min = rfuncs.pcall(args[2], user, headid, dn)
        if val <= min then
            return false
        end
        local max = rfuncs.pcall(args[3], user, headid, dn)
        return val < max
    end
}

REG {
    cmd = reflex_define.BTW2,
    func = function(args, user, headid, dn)
        local val = rfuncs.pcall(args[1], user, headid, dn)
        local min = rfuncs.pcall(args[2], user, headid, dn)
        if val < min then
            return false
        end
        local max = rfuncs.pcall(args[3], user, headid, dn)
        return val < max
    end
}

REG {
    cmd = reflex_define.BTW3,
    func = function(args, user, headid, dn)
        local val = rfuncs.pcall(args[1], user, headid, dn)
        local min = rfuncs.pcall(args[2], user, headid, dn)
        if val <= min then
            return false
        end
        local max = rfuncs.pcall(args[3], user, headid, dn)
        return val <= max
    end
}

REG {
    cmd = reflex_define.BTW4,
    func = function(args, user, headid, dn)
        local val = rfuncs.pcall(args[1], user, headid, dn)
        local min = rfuncs.pcall(args[2], user, headid, dn)
        if val < min then
            return false
        end
        local max = rfuncs.pcall(args[3], user, headid, dn)
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