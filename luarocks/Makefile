THIS_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
LUA_DIR := $(abspath $(THIS_DIR)../bin/lua-5.4.7/src)
ROCKS_PATH := lib/luarocks/rocks
ROCKS_NAME := luaposix
ROCKS := $(foreach v, $(ROCKS_NAME), $(ROCKS_PATH)/$(v))
LUAROCKS_VER := luarocks-3.3.1
DOWNLOAD := http://luarocks.github.io/luarocks/releases/$(LUAROCKS_VER).tar.gz

.PHONY : all clean

#all: bin/luarocks $(ROCKS)
all: bin/luarocks
	
$(LUAROCKS_VER): src/$(LUAROCKS_VER).tar.gz
	tar zxpf $^

bin/luarocks: $(LUAROCKS_VER)
	cd $(LUAROCKS_VER) && ./configure --prefix=$(THIS_DIR) --lua-version=5.4 --with-lua=$(LUA_DIR) --with-lua-bin=$(LUA_DIR) --with-lua-include=$(LUA_DIR) --with-lua-lib=$(LUA_DIR) && make bootstrap
	./bin/luarocks install lua-cjson 2.1.0-1
	./bin/luarocks install luaposix

clean:
	(GLOBIGNORE='src:Makefile' ; rm -rf *)
