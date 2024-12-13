local tableutil = require "util.table"
local util = {}

---传入参数
-- 1. 数组: {{data, weight}, {data, weight}, {data, weight}}
-- 2. 字典：{"data1": weight, "data2": weight}
-- 3. 提供wget
function util.randombyweight(data, wget)
    assert(type(data) == "table")
    local function get_w(v)
            if wget then
                    return wget(v)
            elseif type(v) == "table" then
                    return math.floor(tonumber(v[2]))
            elseif type(v) == "number" then
                    return v
            else
                    assert(false)
            end
    end
    local totalw = 0
    -- 计算权重总和
    for k, v in pairs(data) do
            totalw = totalw + get_w(v)
    end
    if totalw == 0 then
            return tableutil.first(data)
    end
    local randw = math.random(totalw)
    local curw = 0
    -- 计算出当前值
    for k, v in pairs(data) do
            local w = get_w(v)
            curw = curw + w
            if randw <= curw then
                    return k, v
            end
    end
end
return util