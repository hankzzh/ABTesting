local counters = {}
local counter
local stat = {}
local nodes = {}
local heads = {}

function stat.count(headid, nodeid)
    counter[headid] = counter[headid] or {}
    counter[headid][nodeid] = (counter[headid][nodeid] or 0) + 1
    nodes[nodeid] = true
    heads[headid] = true
end

function stat.new()
    counter = {}
    table.insert(counters, counter)
end

function stat.print()
    local log = require "util.log"
    for i, cnt in ipairs(counters) do
        log("times: "..i, cnt)
    end
    local l = {}
    local strid = "|"
    local ln = "|"
    for nodeid in pairs(nodes) do
        table.insert(l, nodeid)
        strid = string.format("%s%20s|", strid, nodeid)
        ln = string.format("%s%20s|", ln, '--------------------')
    end
    print(ln)
    print(strid)
    print(ln)

    for headid in pairs(heads) do
        for i_times = 1, #counters do
            local str = "|"
            for _, nodeid in ipairs(l) do
                str = string.format("%s% 20d|", str, (counters[i_times][headid][nodeid] or 0))
            end
            print(str)
        end
    end
end

return stat