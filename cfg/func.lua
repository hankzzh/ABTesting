--[[
功能相同类型节点跳转函数定义，可以在节点中直接引用函数名�?
]]
return {
	headaction = {
		["$func"] = {
			["$go"] = {
				["$randombyweight"] = {release = 90, test = 90}
			}
		}
	},
	enterction = {
		["$func"] = {
			["$go"] = {
				["$randombyweight"] = {
					['$node'] = { "buckets" },
				}
			}
		}
	},
	testction = {
		["$func"] = {
			["$go"] = {
				"asdkjfkalsdfj",
			}
		}
	},
}
