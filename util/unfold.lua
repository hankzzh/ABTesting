--[[
	日志格式输出，可以输出的key内容
	key值为
	* 			输出本层表中所有key
	type(key)	输出指定类型的key，例如 number表示数字类型的key
]]
local cjson = require "cjson"
--local cjson = require "cjson.safe"

local struct = {
	--friendList = {op=1, friend={number={favor=1, follow=1}}, recent = {number=1}, black = {number=1}, userdata={number={brief={uid=1, state=1}}}}
	friendList = {['*']={['*']={brief={uid=1, state=1}, favor=1, follow=1}}}
}

local function subcmd(s, k)
	local st = type(s)
	if st == "table" then
		return s[k] or s[type(k)] or s['*']
	elseif st == "number" then
		return s > 1 and s - 1
	else
		return s
	end
end

local function unfolder(t, s, m, r)
	local l = ""
	local vt = type(t)
	if vt == "table" then
		if not m then
			m = { t = 1 }
		elseif m[t] then
			return "<repeat val>"
		else
			m[t] = 1
		end
		l=l.."{"
		local m = getmetatable(t)
		if m and m.__pairs then
			if not s then
				l = l .. "+"
			else
				for k,v in pairs(t) do
					local ss = subcmd(s, k)
					local subl = unfolder(v, ss, m)
					if not begin then
						l=l..", "
					end
					begin = false
					l=l..k.."="
					l=l..subl
				end
			end
		else
			local len = #t
			local k, v = next(t, len > 0 and len or nil)
			if not s then
				l = l .. "#" .. len
				if k then
					l = l .. "+"
				end
			else
				local begin = true
				local ns = subcmd(s, 1)
				for i = 1, len do
					local subl = unfolder(t[i], ns, m)
					if begin then
						begin = false
					else
						l=l..", "
					end
					l=l..subl
				end
				while k ~= nil do
					local ss = subcmd(s, k)
					local subl = unfolder(v, ss, m)
					if not begin then
						l=l..", "
					end
					begin = false
					l=l..tostring(k).."="
					l=l..subl
					k, v = next(t, k)
				end
			end
		end
		l=l.."}"
	elseif vt == "string" then
		if #t > 1024 then --#t > 40 and not s
			l = l .. "'#".. #t .. "'"
		else
			l = l .. '"' .. t .. '"'
		end
	else
		if vt == "userdata" or vt == "thread" or vt == "nil" then
			if t == cjson.null then
				l=l.."<"..vt..":nil"..">"
			else
				l=l..tostring(t)
			end
		else
			l=l..tostring(t)
		end
	end
	return l
end

local function unfold(t, cmd)
	local s
	if cmd then
		s = struct[cmd] or cmd
	end
	if not s then
		s = true
	end
	return unfolder(t, s)
end

return unfold
