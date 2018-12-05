FROM alpine:latest

RUN apk update

RUN apk add nodejs npm
RUN npm install -g grunt grunt-cli
RUN npm install -g sass

ADD grunt_entry.sh /
CMD /grunt_entry.sh
