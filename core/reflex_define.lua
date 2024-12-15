---@diagnostic disable: assign-type-mismatch
local reflex_define = {
    FUNC = {name = 'func', comment = '函数注册', selfparse = true},
	FOREACH = { name = 'foreach', comment = '循环编译一个table'},
	IF = { name = 'if', comment = '逻辑--条件二选一', selfparse = true },
    --SELFPARSE = {},
	--PCALL = { name = 'pcall', comment = '逻辑--条件二选一', selfparse = true },
	--return bool
    AND = {name = 'and', comment = '逻辑--且', selfparse = true},
    OR = {name = 'or', comment = '逻辑--或', selfparse = true},
    NOT = {name = 'not', comment = '逻辑--非'},

    RET = {name = 'ret', comment = '返回结果，失败转备用操作'},
    GO = {name = 'go', comment = '跳转到节点，失败赚到备用节点，再次失败转到上层节点/head'},

	GET = { name = 'get', comment = '取任意配置数据' },
	SET = { name = 'set', comment = '修改数据' },
	NODE = { name = 'node', comment = '取任意本节点配置数据活着玩家数据' },
	
    RANDOMBYWEIGHT = {name = 'randombyweight', comment = '随机权重算法'},
    ROUNDBYWEIGHT = {name = 'roundbyweight', comment = '轮循权重算法'},
    NODEFILTER = {name = 'nodefilter', comment = ''},

    --return bool
    GT = {name = '>', comment = '大于'},
    GTE = {name = '>=', comment = '大于等于'},
    LT = {name = '<', comment = '小于'},
    LTE = {name = '<=', comment = '小于等于'},
    BTW1 = {name = '()', comment = '开区间', selfparse = true},
    BTW2 = {name = '[)', comment = '左闭右开区间', selfparse = true},
    BTW3 = {name = '(]', comment = '左开右闭区间', selfparse = true},
    BTW4 = {name = '[]', comment = '闭区间', selfparse = true},
    EQ = {name = '==', comment = '等于'},
}

for k, v in pairs(reflex_define) do
    if "table" == type(v) then
        v.name = "$"..v.name
    else
        reflex_define[k] = {name = "$"..v}
    end
end

return reflex_define