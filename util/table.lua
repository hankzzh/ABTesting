
local function copy_lookup(t1, lookup)
	if nil == t1 then return end
	if type(t1) ~= "table" then
		return t1
	end
	local l = lookup[t1]
	if l then
		return l
	end
	local t2 = {}
	lookup[t1] = t2
	for k, v in pairs(t1) do
		t2[k] = copy_lookup(v, lookup)
	end
	return t2
end

local function deepcopy(t1)
	local lookup = {}
	return copy_lookup(t1, lookup)
end

local function contains(t1, t2)
	if t1 == t2 then
		return true
	end
	--consider true if both are nan
	if t1 ~= t1 and t2 ~= t2 then
		return true
	end
	if type(t1) ~= "table" or type(t2) ~= "table" then
		return false
	end
	for k, v in pairs(t2) do
		local v1 = t1[k]
		if v1 == nil then
			return false
		end
		if not contains(v1, v) then
			return false
		end
	end
	return true
end

local function equals(t1,t2)
	return contains(t1, t2) and contains(t2, t1)
end

local function append(t1, t2)
	if not t1 then
		if not t2 then
			return
		end
		t1 = {}
	end
	for _, v in ipairs(t2 or {}) do
		table.insert(t1, v)
	end
	return t1
end

local function isempty(t)
	if t == nil then
		return true
	end
	if type(t) ~= "table" then
		return true
	end
	for k, v in pairs(t) do -- respect metatable
		return false
	end
	return true
end

local function first(t)
	if t == nil then
		return nil
	end
	for k, v in pairs(t) do -- respect metatable
		return k, v
	end
	return nil
end

local function update_table(first_table, second_table)
	if type(first_table) ~= "table" then
		first_table = {}
	end
	if "table" == type(second_table) then
		for k, v in pairs(second_table) do
			first_table[k] = v
		end
	end
	return first_table
end

local function diff(t1, t2)
	if not t1 then
		return t2
	end
	if not t2 then
		return
	end
	local ret
	for k,v in pairs(t2) do
		if type(v) == "table" then
			if true ~= equals(t1[k], v) then
				ret = ret or {}
				ret[k] = v
			end
		else
			if t1[k] ~= v then
				ret = ret or {}
				ret[k] = v
			end
		end
	end
	return ret
end


return {
	deepcopy = deepcopy,
	equals = equals,
	append = append,
	isempty = isempty,
	first = first,
	update_table = update_table,
	diff = diff,
}
