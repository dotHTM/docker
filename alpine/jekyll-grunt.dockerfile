FROM alpine:latest

RUN apk update

RUN apk add make gcc libc-dev g++
RUN apk add ruby ruby-dev ruby-rdoc
RUN apk add nodejs npm

RUN gem update
RUN gem install bigdecimal webrick etc
RUN gem install jekyll
RUN gem install compass

RUN npm install -g sass
RUN npm install -g grunt grunt-cli

ADD jekyll_entry.sh /
ADD grunt_entry.sh /
