#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

docker build -f $DIR/Dockerfile -t elegionswift:quorum_latest . \
    && docker tag elegionswift:quorum_latest kirilltitov/elegion:quorum_latest \
    && docker push kirilltitov/elegion:quorum_latest
