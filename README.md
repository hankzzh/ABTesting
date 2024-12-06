# ABTesting
AB测试json文件配置
----------------------------------------------------dagmgr.reload:----------------------------------------------------
{"headid_list":{"head":true},"nodes":{"release_2":{"id":"release_2","process":{"$go":"release"},"level":100,"enter":{"$ret":{"$randombyweight":{"i am in release_2":50,"dddddddddddddd":50}}}},"test":{"id":"test","process":{"$go":"test"},"level":100,"enter":{"$ret":"i am in test"}},"head":{"level":0,"process":{"$go":{"$randombyweight":{"release":90,"test":10}}},"id":"head","ishead":true,"enter":{"$go":{"$randombyweight":{"release":90,"test":10}}}},"test111":{"id":"test111","level":100,"aaa":{"$tf":[100,"template.bucket.bucket1","template.bucket.bucket2"]},"process":{"$func":{"body":{"$if":[{"1":{"$args":1},"$<":{"$user":{"uid":1}}},{"$ret":{"$cfg":{"$args":2}}},{"$ret":{"$cfg":{"$args":3}}}]},"name":"tf"}}},"release_1":{"id":"release_1","process":{"$if":[false,{"$go":"release"},"nothing"]},"level":100,"enter":{"$ret":"i am in release_1"}},"release":{"id":"release","level":100,"enter":{"$go":{"$randombyweight":{"release_1":50,"release_2":150}}}}}}
----------------------------------------------------------------------------------------------------------------------
执行结果
times: 1?{{head={release_2=674, release_1=221, test=105}}}
times: 2?{{head={release_2=502, release_1=393, test=105}}}
times: 3?{{head={release_2=381, release_1=514, test=105}}}
times: 4?{{head={release_2=281, release_1=614, test=105}}}
times: 5?{{head={release_2=212, release_1=683, test=105}}}
times: 6?{{head={release_2=164, release_1=731, test=105}}}
times: 7?{{head={release_2=124, release_1=771, test=105}}}
times: 8?{{head={release_2=100, release_1=795, test=105}}}
times: 9?{{head={release_2=79, release_1=816, test=105}}}
times: 10?{{head={release_2=62, release_1=833, test=105}}}
---------------------
release_2|release_1|test
|674|221|105
|502|393|105
|381|514|105
|281|614|105
|212|683|105
|164|731|105
|124|771|105
|100|795|105
|79|816|105
|62|833|105

安装条件：
系统安装lua
执行make
运行:
./run.sh

测试参数：
main.lua文件中有测试角色数量和测试次数
配置文件路径
cfg
