FROM debian:buster-slim

RUN apt-get update
RUN apt-get -y install curl gnupg git rsync build-essential python
RUN curl -sL https://deb.nodesource.com/setup_14.x  | bash -
RUN apt-get -y install nodejs

WORKDIR /usr/src/app

COPY . ./
COPY docker-compose/prebuilt/* ./node_modules/grpc-tools/bin/
RUN npm install
RUN npm run compile

EXPOSE 9008
CMD [ "npm", "run", "start" ]