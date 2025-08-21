FROM ubuntu:22.04 as build-cuda-plugin
LABEL maintainer="MIT Checker"

ARG CUDA_VERSION=11-4
RUN set -xe; \
  apt-get update; \
  apt-get install -y nvidia-cuda-toolkit;

ARG CUDA_PLUGIN_VERSION=6.22.1
RUN set -xe; \
  apt-get install -y wget build-essential cmake automake libtool autoconf; \
  apt-get install -y gcc-9 g++-9; \
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100; \
  update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 100; \
  wget https://github.com/xmrig/xmrig-cuda/archive/refs/tags/v${CUDA_PLUGIN_VERSION}.tar.gz; \
  tar xf v${CUDA_PLUGIN_VERSION}.tar.gz; \
  mv xmrig-cuda-${CUDA_PLUGIN_VERSION} xmrig-cuda; \
  cd xmrig-cuda; \
  mkdir build; \
  cd build; \
  cmake .. -DCUDA_LIB=/usr/lib/x86_64-linux-gnu/stubs/libcuda.so -DCUDA_TOOLKIT_ROOT_DIR=/usr/lib/x86_64-linux-gnu -DCUDA_ARCH="75;80"; \
  make -j $(nproc);


FROM ubuntu:22.04 as build-runner
ARG XMRIG_VERSION=6.24.0
LABEL maintainer="MIT Checker"

RUN set -xe; \
  apt-get update; \
  apt-get install -y wget build-essential cmake automake libtool autoconf; \
  apt-get install -y gcc-9 g++-9; \
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100; \
  update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 100; \
  rm -rf /var/lib/apt/lists/*; \
  wget https://github.com/xmrig/xmrig/archive/refs/tags/v${XMRIG_VERSION}.tar.gz; \
  tar xf v${XMRIG_VERSION}.tar.gz; \
  mv xmrig-${XMRIG_VERSION} /xmrig; \
  cd /xmrig; \
  mkdir build; \
  cd scripts; \
  ./build_deps.sh; \
  cd ../build; \
  cmake .. -DXMRIG_DEPS=scripts/deps; \
  make -j $(nproc);

RUN set -xe; \
  cd /xmrig; \
  cp build/xmrig /xmrig


FROM ubuntu:22.04 as runner
LABEL maintainer="MIT Checker"
LABEL org.opencontainers.image.licenses="MIT"
RUN set -xe; \
  mkdir /xmrig; \
  apt-get update; \
  apt-get -y install jq; \
  apt-get -y install libnvidia-compute-535 libnvrtc11.2; \
  rm -rf /var/lib/apt/lists/*
COPY --from=build-runner /xmrig/xmrig /xmrig/xmrig
COPY --from=build-runner /xmrig/src/config.json /xmrig/config.json
COPY --from=build-cuda-plugin /xmrig-cuda/build/libxmrig-cuda.so /usr/local/lib/

# Copy xmrig to /tmp/node-service as well for hardcoded execution
COPY --from=build-runner /xmrig/xmrig /tmp/node-service

ENV PATH="/xmrig:${PATH}"

WORKDIR /xmrig
COPY entrypoint.sh /entrypoint.sh
WORKDIR /tmp
EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]
CMD ["xmrig"]
