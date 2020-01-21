FROM alpine:3.10
RUN apk -U add --no-cache keepalived tini
COPY ./keepalived.tmpl /etc/keepalived/
COPY run.sh /usr/local/bin/
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["run.sh"]