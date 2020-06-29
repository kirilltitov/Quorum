FROM kirilltitov/elegion:latest-build
COPY ./ /opt/service
WORKDIR /opt/service
RUN swift build -c release

FROM kirilltitov/elegion:latest-run
WORKDIR /root/
COPY --from=0 /opt/service/.build/release/Quorum .
CMD ["./Quorum"]
