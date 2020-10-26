FROM alpine:3.12
RUN apk -U add --no-cache keepalived tini bash
COPY ./keepalived.tmpl /etc/keepalived/
COPY run.sh /usr/local/bin/
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["run.sh"]