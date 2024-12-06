CUR_DIR := $(shell pwd)
3RD_NAME := luarocks

#all: build-protobuf
.PHONY: all
all:
	for v in $(3RD_NAME); \
	do \
		cd $(CUR_DIR)/$$v && make; \
	done

.PHONY: clean
clean: clean-protobuf
	for v in $(3RD_NAME); \
	do \
		cd $(CUR_DIR)/$$v && make clean; \
	done

.PHONY: clear
clear: clean

.PHONY: build-protobuf
build-protobuf:
	cd protobuf && ./autogen.sh && ./configure --prefix=$(CUR_DIR)/../bin && make -j8
#cmake cmake/ -Dprotobuf_BUILD_TESTS=OFF -Dprotobuf_BUILD_SHARED_LIBS=ON

.PHONY: clean-protobuf
clean-protobuf:
#	cd protobuf && make clean
