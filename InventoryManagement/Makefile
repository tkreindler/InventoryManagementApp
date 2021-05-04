.PHONY: protobuf

arch := $(shell arch)

ifeq ($(arch),arm64)
protobuf:
	PATH=$$PATH:/opt/homebrew/bin && protoc --swift_out=. ProtoModels/*.proto
else
protobuf:
	PATH=$$PATH:/usr/local/bin && protoc --swift_out=. ProtoModels/*.proto
endif