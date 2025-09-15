# Default recipe
default: build

build:
  mkosi build

build-compress:
  mkosi build --compress-output=yes

build-ext extension:
  mkosi build --profile=sysext-only --dependency={{extension}}

build-main:
  mkosi build --dependency=base

bump:
  mkosi bump

clean:
  mkosi clean -ff

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
