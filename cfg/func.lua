--[[
功能相同类型节点跳转函数定义，可以在节点中直接引用函数名称
]]
return {
	headaction = {
		["$func"] = {
			["$go"] = {
				["$randombyweight"] = {release = 90, test = 0}
			}
		}
	},
	enter = {
		["$func"] = {
			["$go"] = {
				["$randombyweight"] = {
					['$node'] = { "buckets" },
				}
			}
		}
	},
	test = {
		["$func"] = {
			["$go"] = {
				"asdkjfkalsdfj",
			}
		}
	},
}
