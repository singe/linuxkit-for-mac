FROM alpine:3.7
ADD /sendtohost /
ADD /transfused /usr/bin/
ADD /entrypoint.sh /usr/bin/
RUN mkdir -p /run/config/filesharing
RUN echo -n osxfs > /run/config/filesharing/mode
RUN apk --update add fuse
