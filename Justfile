# Justfile
# Converted from Makefile

# Default recipe
default: images

images:
  mkosi build

bump:
  mkosi bump

clean:
  mkosi clean -ff

launch:
  ./scripts/launch.sh

kill:
  ./scripts/kill.sh
