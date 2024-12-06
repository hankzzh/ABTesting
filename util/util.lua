local tableutil = require "util.table"
local util = {}

---�������
-- 1. ����: {{data, weight}, {data, weight}, {data, weight}}
-- 2. �ֵ䣺{"data1": weight, "data2": weight}
-- 3. �ṩwget
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
    -- ����Ȩ���ܺ�
    for k, v in pairs(data) do
            totalw = totalw + get_w(v)
    end
    if totalw == 0 then
            return tableutil.first(data)
    end
    local randw = math.random(totalw)
    local curw = 0
    -- �������ǰֵ
    for k, v in pairs(data) do
            local w = get_w(v)
            curw = curw + w
            if randw <= curw then
                    return k, v
            end
    end
end
return util