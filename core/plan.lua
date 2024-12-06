local reflex_define = require "core.reflex_define"
local reflex_func = require "core.reflex_func"
local log = require "util.log"

local plan = {}

function plan.exec(user, planCfg)
    for cmd, pc in pairs(planCfg.action) do
        local f = reflex_func[planCfg]
        if f then
        else
            log("fatal err cmd not fount", {actionConfig = actionConfig})
            os.exit(1)
        end
    end
end

return plan