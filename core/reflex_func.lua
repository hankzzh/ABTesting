local reflex_define = require "core.reflex_define"
local util = require "util.util"
local dagmgr = require "core.dagmgr"
local log = require "util.log"

local rfuncs = {}
local cmdlist = {}

function rfuncs.register(h)
    cmdlist[h.cmd.name] = h
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
        args = rfuncs.parse2val(dn, user, headid, args)
        return h.func(dn, user, headid, args)
    end
end

function rfuncs.parse2val(dn, user, headid, valorcfg)
    local f = rfuncs.parse(valorcfg)
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
                replacement[name] = rfuncs.parse2val(dn, user, headid, args)
            end
        end
        return replacement
    end
end

local REG = rfuncs.register

REG {
    cmd = reflex_define.FUNC,
    func = function(dn, user, headid, args)
        if #args ~= 3 then
            return
        end
        local cond = rfuncs.parse2val(dn, user, headid, args[1])
        -- user:log("cond", cond)
        if cond then
            -- user:log("cond", 2)
            return rfuncs.parse2val(dn, user, headid, args[2])
        else
            -- user:log("cond", 3)
            return rfuncs.parse2val(dn, user, headid, args[3])
        end
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
        local newnode = dagmgr.get(args)
        user:changenode(headid, dn, newnode)
    end
}

REG {
    cmd = reflex_define.CFG,
    func = function(dn, user, headid, args)
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
            value = rfuncs.parse2val(dn, user, value)
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
            value = rfuncs.parse2val(dn, user, value)
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
        local cond = rfuncs.parse2val(dn, user, headid, args[1])
        -- user:log("cond", cond)
        if cond then
            -- user:log("cond", 2)
            return rfuncs.parse2val(dn, user, headid, args[2])
        else
            -- user:log("cond", 3)
            return rfuncs.parse2val(dn, user, headid, args[3])
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
        local val = rfuncs.parse2val(dn, user, headid, args[1])
        local min = rfuncs.parse2val(dn, user, headid, args[2])
        if val <= min then
            return false
        end
        local max = rfuncs.parse2val(dn, user, headid, args[3])
        return val < max
    end
}

REG {
    cmd = reflex_define.BTW2,
    func = function(dn, user, headid, args)
        local val = rfuncs.parse2val(dn, user, headid, args[1])
        local min = rfuncs.parse2val(dn, user, headid, args[2])
        if val < min then
            return false
        end
        local max = rfuncs.parse2val(dn, user, headid, args[3])
        return val < max
    end
}

REG {
    cmd = reflex_define.BTW3,
    func = function(dn, user, headid, args)
        local val = rfuncs.parse2val(dn, user, headid, args[1])
        local min = rfuncs.parse2val(dn, user, headid, args[2])
        if val <= min then
            return false
        end
        local max = rfuncs.parse2val(dn, user, headid, args[3])
        return val <= max
    end
}

REG {
    cmd = reflex_define.BTW4,
    func = function(dn, user, headid, args)
        local val = rfuncs.parse2val(dn, user, headid, args[1])
        local min = rfuncs.parse2val(dn, user, headid, args[2])
        if val < min then
            return false
        end
        local max = rfuncs.parse2val(dn, user, headid, args[3])
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