FROM alpine:latest

RUN apk update
RUN apk add make gcc libc-dev

RUN apk add nodejs npm
RUN npm install -g sass

ADD jekyll_entry.sh /
CMD /jekyll_entry.sh
