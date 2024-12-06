#!/bin/bash
cd `dirname $0`
export RUNPATH=$(cd `dirname $0`; pwd)
LUA=lua
echo $RUNPATH

export LUA_CPATH="$RUNPATH/luarocks/lib/lua/5.4/?.so"
export LUA_PATH="./?.lua;$RUNPATH/luarocks/share/lua/5.4/?.lua;$RUNPATH/luarocks/share/lua/5.4/?/init.lua;$RUNPATH/core/?.lua"
$LUA main.lua

