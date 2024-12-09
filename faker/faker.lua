local user_meta = require "faker.user"
local faker = {}
local ATTR_NUM = 10

function faker.uid()
    return "uid-"..os.time().."-"..math.random(0xffffffff)
end


function faker.make(num)
    num = num or 1
    local lst = {}
    for i = 1, num do
        local req = {
            uid = i,
            attr = {},
        }
        for j = 1, ATTR_NUM do
            req.attr[i] = math.random(0, 1000)
        end
        table.insert(lst, user_meta.new(req))
    end
    return lst
end

return faker