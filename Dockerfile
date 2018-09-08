FROM alpine:edge
MAINTAINER Chance Hudson <chance@commontheory.io>

RUN apk add --no-cache bash ncurses g++ automake make cmake openssl \
libressl-dev autoconf libtool python binaryen git gmp-dev \
 && git config --global advice.detachedHead false

# Install secp256k1 binary
RUN git clone --depth 1 --single-branch https://github.com/bitcoin-core/secp256k1.git \
 && cd /secp256k1 \
 && bash ./autogen.sh \
 && bash ./configure \
 && make \
 && ./tests \
 && make install \
 && rm -rf /secp256k1

# Build llvm 5.0 (5.0 includes a fix for musl based libc)
RUN git clone --depth 1 --single-branch --branch release_50 https://github.com/llvm-mirror/llvm.git /llvm \
 && git clone --depth 1 --single-branch --branch release_50 https://github.com/llvm-mirror/clang.git /llvm/tools/clang \
 && cd /llvm \
 && cmake -H. -Bbuild -DCMAKE_INSTALL_PREFIX=/opt/wasm -DLLVM_TARGETS_TO_BUILD= -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly -DCMAKE_BUILD_TYPE=Release  \
 && cmake --build build --target install \
 && rm -rf /llvm

# Build boost v1.57.0
RUN git clone --depth 1 --single-branch --branch boost-1.57.0 https://github.com/boostorg/boost /boost \
 && cd /boost \
 && git submodule update --init --recursive \
 && bash ./bootstrap.sh \
 && ./b2 --variant=release install \
 && rm -rf /boost

# Build EOS
RUN git clone --depth 1 --single-branch --branch v1.2.4 https://github.com/EOSIO/eos.git \
 && mkdir /eos/build \
 && cd /eos/build \
 && git submodule update --init --recursive
# && cmake -DWASM_ROOT=/opt/wasm -DOPENSSL_ROOT_DIR=/usr/include/openssl -DOPENSSL_LIBRARIES=/usr/local/opt/openssl/lib -DBUILD_MONGO_DB_PLUGIN=true -DCMAKE_BUILD_TYPE=Release ..
