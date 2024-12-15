local cjson = require "cjson"
local faker = require "faker.faker"
local log = require "util.log"
local dagmgr = require "core.dagmgr"
local stat = require "util.stat"

local USER_NUM = 5
local RUN_TIMES = 1
local cmd = {}

dagmgr.reload_all()
log(">>>>>>>>tester begin!!!!")
log("begin make faker", {USER_NUM = USER_NUM})
local userlist = faker.make(USER_NUM)
log("faker make sucess", {USER_NUM = USER_NUM, RUN_TIMES = RUN_TIMES})



local function addcmd(name, f, help)
	help = help or name
	if type(name) == 'table' then
		for _, n in ipairs(name) do
			addcmd(n, f, help)
		end
	else
		local h = { name = name, f = f, help=help }
		cmd[name] = h
	end
end

addcmd({'r', "run"}, function()
	for r = 1, RUN_TIMES do
		stat.new()
		for _, user in pairs(userlist) do
			dagmgr.process(user)
			user:count()
		end
		log("--------run finish times", r)
	end
	log("<<<<<<<<<tester end!!!!")
	stat.print()
end)
addcmd("stat", function()
	stat.print()
end)
addcmd({'h', "help"}, function()
	dagmgr.print()
	for k, v in pairs(cmd) do
		log("cmd:", v.help)
	end
end)
while true do
    local input = io.read()
	input = tostring(input)
	if input == 'q' or input == 'quit' or input == 'exit' then
		break
	end
	local h = cmd[input]
	if h and h.f then
		h.f()
	else
		log("input is no exist, user help")
		cmd.help.f()
	end
	print(
	"----------------------------------------------------------------------------------------------------------------------------------")
end
