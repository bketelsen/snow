# Default recipe
default: build

build: snowctl
  mkosi build

build-compress: snowctl
  mkosi build --compress-output=yes

build-ext extension:
  mkosi build --profile=sysext-only --dependency={{extension}}

build-main: snowctl
  mkosi build --dependency=base

bump:
  mkosi bump

clean:
  mkosi clean -ff
  rm -rf ./mkosi.output/*.SHA256SUMS

deploy: clean snowctl
  mkosi -ff
  ./scripts/sums.sh
  ./scripts/deploy.sh

deep-clean:
  mkosi clean -ff
  rm -rf ./mkosi.cache
  rm -rf .mkosi-private
  rm -rf ./mkosi.tools
  rm -rf ./mkosi.tools.manifest

launch:
  ./scripts/launch.sh

kill:
  ./scripts/kill.sh

snowctl:
  cd snowctl && go build -o snowctl .
  cp snowctl/snowctl mkosi.images/base/mkosi.extra/usr/local/bin/
