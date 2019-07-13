FROM kirilltitov/elegion:latest
COPY ./ /opt/service
WORKDIR /opt/service
RUN swift build -c release

FROM kirilltitov/elegion:latest
WORKDIR /root/
COPY --from=0 /opt/service/.build/release/Quorum .
CMD ["./Quorum"]
