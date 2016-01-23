#!/bin/sh -ex

# synces from pi to zen
fdupes -dfr -N /zen/tez/cts /mnt/pi/cts
cd /mnt/pi/cts
find . -type f | sed -e 's/^..//' | rsync -av --remove-source-files --files-from=- ./ /zen/tez/cts/
