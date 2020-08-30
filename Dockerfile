FROM alpine:3.12 as builder

# The alpine-sdk is a metapackage that pulls in the most essential packages used to build new packages.
# Don't use --no-cache because the cache is mandatory for the abuild later
# hadolint ignore=DL3018,DL3019
RUN apk add \
        alpine-sdk \
        sudo

# Used by abuild-keygen to name the keys -- not mandatory, but cleaner
RUN git config --global user.name "John Paul APK builder"
RUN git config --global user.email "apk.builder@johnpaul.com"

# Configure the security keys with the abuild-keygen script for abuild
RUN abuild-keygen -a -i -n

COPY ./aports/main/squid/* /tmp/

WORKDIR /tmp

# buid the package
# -F to force run as root
RUN abuild -F -r


FROM alpine:3.12

COPY --from=builder /root/packages/x86_64/squid-[0-9]*.apk /tmp/

# hadolint ignore=DL3018
RUN apk add --no-cache --allow-untrusted /tmp/squid-[0-9]*.apk

RUN rm /tmp/squid-[0-9]*.apk
