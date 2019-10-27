FROM node:alpine AS builder

ADD . /app

WORKDIR /app

RUN npm install 
RUN npm install -g @angular/cli@8.3.6

CMD cd /app && ng serve --host 0.0.0.0