#!/bin/bash
docker stop cardano-cncli
docker rm cardano-cncli

docker run -d \
	-v $PWD/sqlite:/srv/cardano/cardano-cli/storage \
	--name cardano-cncli \
	-e TARGET_HOST=192.168.1.118 \
	-e TARGET_PORT=3000 \
	-e DB_LOCATION=storage/sqlite.db \
	-e RUST_BACKTRACE=1 \
	cardano-cncli:latest
