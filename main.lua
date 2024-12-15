local cjson = require "cjson"
local faker = require "faker.faker"
local log = require "util.log"
local dagmgr = require "core.dagmgr"
local stat = require "util.stat"

local USER_NUM = 5
local RUN_TIMES = 1

dagmgr.reload_all()
log(">>>>>>>>tester begin!!!!")
log("begin make faker", {USER_NUM = USER_NUM})
local userlist = faker.make(USER_NUM)
log("faker make sucess", {USER_NUM = USER_NUM, RUN_TIMES = RUN_TIMES})
while true do
    local input = io.read()
    print("intput:"..input)
end
for r = 1, RUN_TIMES do
    stat.new()
    for _, user in pairs(userlist) do
        dagmgr.process(user)
        user:count()
    end
    log("--------run finish times", r)
end
log("<<<<<<<<<tester end!!!!")
dagmgr.print()
stat.print()
