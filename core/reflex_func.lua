local reflex_define = require "core.reflex_define"
local util = require "util.util"
local dagmgr = require "core.dagmgr"
local log = require "util.log"

local rfuncs = {}
local cmdlist = {}

--执行指令集和中断
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
    return function (dn, user, headid, args)
        args = rfuncs.parse2val(args, dn, user, headid)
        return h.func(dn, user, headid, args)
    end
end

function rfuncs.parse2val(args, dn, user, headid)
	local f = rfuncs.parse(args)
    return f(dn, user, headid)
end

function rfuncs.parse(valorcfg)
    return function (dn, user, headid)
        if type(valorcfg) ~= "table" then
            return valorcfg
        end
        local replacement = {}
        for name, args in pairs(valorcfg) do
            local f = rfuncs.get(name)
            if f then
                return f(dn, user, headid, args)
                -- args = rfuncs.parse(args)
                -- return f(dn, user, args(dn, user))
            else
                replacement[name] = rfuncs.parse2val(args, dn, user, headid)
            end
        end
        return replacement
    end
end

local REG = rfuncs.register

REG {
	cmd = reflex_define.FUNC,
	func = function(dn, user, headid, args)
		return rfuncs.parse(args)
	end
}

REG {
	cmd = reflex_define.GET,
	func = function(dn, user, headid, args)
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
	func = function(dn, user, headid, args)
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
    func = function(dn, user, headid, args)
        return util.randombyweight(args)
    end
}

REG {
    cmd = reflex_define.ROUNDBYWEIGHT,
    func = function(dn, user, headid, args)
        return util.randombyweight(args)
    end
}

REG {
    cmd = reflex_define.GO,
    func = function(dn, user, headid, args)
		print("gogogogogogogogogogogogogogogogo", args)
        local newnode = dagmgr.get(args)
        user:changenode(headid, dn, newnode)
    end
}

REG {
    cmd = reflex_define.RET,
    func = function(dn, user, headid, args)
        user:log("return at node, content add later", dn.id, args)
    end
}

REG {
    cmd = reflex_define.AND,
    func = function(dn, user, headid, args)
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
    func = function(dn, user, headid, args)
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
    func = function(dn, user, headid, args)
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
    func = function(dn, user, headid, args)
        if not args then
            return true
        end
        return false
    end
}

REG {
    cmd = reflex_define.GT,
    func = function(dn, user, headid, args)
        return args[1] > args[2]
    end
}

REG {
    cmd = reflex_define.GTE,
    func = function(dn, user, headid, args)
        return args[1] >= args[2]
    end
}

REG {
    cmd = reflex_define.LT,
    func = function(dn, user, headid, args)
        return args[1] < args[2]
    end
}

REG {
    cmd = reflex_define.LTE,
    func = function(dn, user, headid, args)
        return args[1] <= args[2]
    end
}

REG {
    cmd = reflex_define.BTW1,
    func = function(dn, user, headid, args)
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
    func = function(dn, user, headid, args)
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
    func = function(dn, user, headid, args)
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
    func = function(dn, user, headid, args)
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
    func = function(dn, user, headid, args)
        return args[1] == args[2]
    end
}


return rfuncs