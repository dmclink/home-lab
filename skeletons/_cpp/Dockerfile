FROM debian:trixie-slim AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    gcc-14 \
    g++-14 \
    && rm -rf /var/lib/apt/lists/*

ENV CC=gcc-14
ENV CXX=g++-14

WORKDIR /src
COPY . .

RUN cmake -B build -S . -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build


FROM debian:trixie-slim

RUN apt-get update && apt-get install -y \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /src/build/* /usr/local/bin/

# start the binary (matches the directory name)
ENTRYPOINT ["sh", "-c", "exec $(ls /usr/local/bin/* | head -n 1)"]
