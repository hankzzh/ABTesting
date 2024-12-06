local unfold = require "util.unfold"
return function(msg, ...)
    local params = {...}
    if #params > 0 then
        print(msg.."?"..unfold({...}))
    else
        print(msg)
    end
end