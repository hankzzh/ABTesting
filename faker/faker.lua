local user_meta = require "faker.user"
local faker = {}

local bundleIdList = {
    "com.block.juggle",
    "com.wedd.juggle",
}

function faker.uid()
    return "uid-"..os.time().."-"..math.random(0xffffffff)
end


function faker.installTime()
    return tonumber(os.time()) - math.random(0xffff)
end

function faker.bundleId()
    return bundleIdList[math.random(#bundleIdList)]
end

function faker.resVersion()
    return "3.2.2"
end

function faker.sdkVersion()
    return "999.999.999"
end

function faker.gameWayNum()
    return ""
end

function faker.make(num)
    num = num or 1
    local lst = {}
    for i = 1, num do
        local req = {
            uid = i,
            installTime = faker.installTime(),
            bundleId = faker.bundleId(),
            resVersion = faker.resVersion(),
            sdkVersion = faker.sdkVersion(),
            gameWayNum = faker.gameWayNum(),
        }
        table.insert(lst, user_meta.new(req))
    end
    return lst
end

return faker