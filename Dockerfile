# Client library of the FoundationDB API (7.4) and the client library of the production cluster (6.3),
# loaded by the multi-version client as an external one
ARG FDB_VERSION=7.4.8
ARG FDB_CLUSTER_VERSION=6.3.23
ARG SWIFT_IMAGE=swift:6.4-noble
ARG SWIFT_RUNTIME_IMAGE=swift:6.4-noble-slim

FROM ${SWIFT_IMAGE} AS fdb
ARG FDB_VERSION
ARG FDB_CLUSTER_VERSION
RUN apt-get update -qq && apt-get install -y -qq curl \
    && curl -sSfLO https://github.com/apple/foundationdb/releases/download/${FDB_VERSION}/foundationdb-clients_${FDB_VERSION}-1_amd64.deb \
    && curl -sSfLO https://github.com/apple/foundationdb/releases/download/${FDB_CLUSTER_VERSION}/foundationdb-clients_${FDB_CLUSTER_VERSION}-1_amd64.deb \
    && mkdir -p /fdb/external \
    && dpkg-deb -x foundationdb-clients_${FDB_CLUSTER_VERSION}-1_amd64.deb /tmp/fdb-cluster \
    && cp /tmp/fdb-cluster/usr/lib/libfdb_c.so /fdb/external/libfdb_c_${FDB_CLUSTER_VERSION}.so \
    && dpkg-deb -x foundationdb-clients_${FDB_VERSION}-1_amd64.deb /fdb/client \
    && printf 'prefix=/usr\nincludedir=${prefix}/include\nlibdir=${prefix}/lib\n\nName: fdb\nDescription: FoundationDB\nVersion: %s\nCflags: -I${includedir}\nLibs: -L${libdir} -lfdb_c\n' "${FDB_VERSION}" > /fdb/libfdb.pc

FROM ${SWIFT_IMAGE} AS build
COPY --from=fdb /fdb/client/usr/include/foundationdb /usr/include/foundationdb
COPY --from=fdb /fdb/client/usr/lib/libfdb_c.so /usr/lib/libfdb_c.so
COPY --from=fdb /fdb/libfdb.pc /usr/lib/pkgconfig/libfdb.pc
WORKDIR /opt/service
COPY Package.swift Package.resolved* ./
RUN swift package resolve
COPY Sources ./Sources
COPY Tests ./Tests
RUN swift build -c release --product Quorum

FROM ${SWIFT_RUNTIME_IMAGE}
COPY --from=fdb /fdb/client/usr/lib/libfdb_c.so /usr/lib/libfdb_c.so
COPY --from=fdb /fdb/external /usr/lib/fdb-external
ENV FDB_NETWORK_OPTION_EXTERNAL_CLIENT_DIRECTORY=/usr/lib/fdb-external \
    FDB_API_VERSION=630
WORKDIR /root/
COPY --from=build /opt/service/.build/release/Quorum .
CMD ["./Quorum"]
