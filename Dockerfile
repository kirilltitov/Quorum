FROM kirilltitov/elegion:latest
COPY ./ /opt/service
WORKDIR /opt/service
RUN export QEMU_CPU=max && swift build -c release -Xswiftc -cross-module-optimization
# RUN swift package resolve --verbose
# RUN swift build -c release

FROM kirilltitov/elegion:latest
WORKDIR /root/
COPY --from=0 /opt/service/.build/release/Quorum .
CMD ["./Quorum"]

# FROM kirilltitov/elegion:latest-async-build
# WORKDIR /root/
# COPY ./Quorum .
# CMD ["./Quorum"]
