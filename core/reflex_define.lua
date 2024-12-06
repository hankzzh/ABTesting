---@diagnostic disable: assign-type-mismatch
local reflex_define = {
    FUNC = {name = 'func', comment = '����ע��', selfparse = true},
    RANDOMBYWEIGHT = {name = 'randombyweight', comment = '���Ȩ���㷨'},
    ROUNDBYWEIGHT = {name = 'roundbyweight', comment = '��ѭȨ���㷨'},
    NODEFILTER = {name = 'nodefilter', comment = ''},
    RET = {name = 'ret', comment = '���ؽ����ʧ��ת���ò���'},
    GO = {name = 'go', comment = '��ת���ڵ㣬ʧ��׬�����ýڵ㣬�ٴ�ʧ��ת���ϲ�ڵ�/head'},
    CFG = {name = 'cfg', comment = 'ȡconfig�ֶ�'},
    IF = {name = 'if', comment = '�߼�--������ѡһ', selfparse = true},

    --return bool
    AND = {name = 'and', comment = '�߼�--��', selfparse = true},
    OR = {name = 'or', comment = '�߼�--��', selfparse = true},
    NOT = {name = 'not', comment = '�߼�--��'},
    GT = {name = '>', comment = '����'},
    GTE = {name = '>=', comment = '���ڵ���'},
    LT = {name = '<', comment = 'С��'},
    LTE = {name = '<=', comment = 'С�ڵ���'},
    BTW1 = {name = '><', comment = '������', selfparse = true},
    BTW2 = {name = '=><', comment = '����ҿ�����', selfparse = true},
    BTW3 = {name = '><=', comment = '���ұ�����', selfparse = true},
    BTW4 = {name = '=><=', comment = '������', selfparse = true},
    EQ = {name = '==', comment = '����'},
}

for k, v in pairs(reflex_define) do
    if "table" == type(v) then
        v.name = "$"..v.name
    else
        reflex_define[k] = {name = "$"..v}
    end
end

return reflex_define