FROM alpine:edge
MAINTAINER Chance Hudson <chance@commontheory.io>

# Install some packages and don't warn about detached head state
RUN apk add --no-cache bash ncurses g++ automake make cmake autoconf libtool git linux-headers libexecinfo-dev python clang-dev \
 && git config --global advice.detachedHead false

# Build llvm 4.0 (building from forked repo with fix for DynamicLibrary)
RUN git clone --depth 1 --single-branch --branch release_40 https://github.com/common-theory/llvm.git /llvm \
 && git clone --depth 1 --single-branch --branch release_40 https://github.com/llvm-mirror/clang.git /llvm/tools/clang \
 && cd /llvm \
 && mkdir /llvm_build \
 && cmake -H. -Bbuild -DLLVM_ENABLE_RTTI=ON -DCMAKE_INSTALL_PREFIX=/llvm_build -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly -DCMAKE_BUILD_TYPE=Release  \
 && cmake --build build --target install

FROM alpine:edge
MAINTAINER Chance Hudson <chance@commontheory.io>

COPY --from=0 /llvm_build/bin/* /usr/bin/
COPY --from=0 /llvm_build/share/* /usr/share/
COPY --from=0 /llvm_build/libexec/* /usr/libexec/
COPY --from=0 /llvm_build/lib/* /usr/lib/
COPY --from=0 /llvm_build/include/* /usr/include/
