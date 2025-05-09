ARG BASE_OS
ARG BASE_DISTRO
FROM ${BASE_OS}:${BASE_DISTRO}

# Step 1: RISC-V toolchain
RUN    apt-get update        \
    && apt-get upgrade --yes \
    && apt-get install --yes \
       autoconf              \
       automake              \
       autotools-dev         \
       curl                  \
       python3               \
       python-is-python3     \
       libmpc-dev            \
       libmpfr-dev           \
       libgmp-dev            \
       gawk                  \
       build-essential       \
       bison                 \
       flex                  \
       texinfo               \
       gperf                 \
       libtool               \
       patchutils            \
       bc                    \
       zlib1g-dev            \
       libexpat-dev          \
       ninja-build           \
       git

ENV RISCV=/opt/riscv
ENV PATH=$PATH:$RISCV/bin

ARG TOOLCHAIN_VERSION=2023.04.29
RUN    git clone --recursive https://github.com/riscv/riscv-gnu-toolchain -b ${TOOLCHAIN_VERSION} \
    && cd riscv-gnu-toolchain                                                                     \
    && ./configure --enable-multilib --prefix=$RISCV --with-multilib-generator="rv32imc-ilp32--a*zicsr*zifencei"\
    && make                                                                                       \
    && cd ..                                                                                      \
    && rm -rf riscv-gnu-toolchain

# Step 2: Verilator
RUN     apt-get install --yes \
        help2man perl flex bison ccache libunwind-dev \
    &&  apt-get install --yes  \    
        libgoogle-perftools-dev numactl perl-doc \
    &&  apt-get install libfl2  \
    &&  apt-get install libfl-dev \
    &&  apt-get install zlib1g
RUN     git clone https://github.com/verilator/verilator \
    &&  cd verilator \
    &&  git pull \
    &&  git checkout v5.012 \
    &&  autoconf \
    &&  ./configure \
    &&  make -j `nproc` \
    &&  make install \
    &&  cd bin \
    &&  rm -rf *_dbg \
    &&  cd /

# Step 3: C


# Last step: Change users