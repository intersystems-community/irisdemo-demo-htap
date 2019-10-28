FROM node:alpine AS builder

ADD . /app

ENV MASTER_HOSTNAME="htapmaster"
ENV MASTER_PORT=80

WORKDIR /app

RUN npm install 
RUN npm install -g @angular/cli@8.3.6

CMD cd /app && npm run proxy