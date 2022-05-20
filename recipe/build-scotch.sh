#!/bin/bash

set -ex

if [[ $(uname) == "Darwin" ]]; then
  shared_flags="-Wl,-undefined -Wl,dynamic_lookup"
else
  shared_flags="-Wl,-shared"
fi

cmake \
  -D CMAKE_SHARED_LINKER_FLAGS="$shared_flags" \
  -D CMAKE_INSTALL_PREFIX=$PREFIX \
  -D MPI_THREAD_MULTIPLE=OFF \
  -D BUILD_SHARED_LIBS=ON \
  -B build \
  .

cmake --build ./build --parallel ${CPU_COUNT}
cmake --install ./build --component=scotch
cmake --install ./build --component=esmumps
