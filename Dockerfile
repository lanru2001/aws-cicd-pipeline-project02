FROM node:10 AS ui-build
WORKDIR /usr/src/app
COPY my-app/  /usr/src/app

FROM node:10 AS server-build
WORKDIR /root/
COPY api/package*.json  .
RUN  npm install
COPY api/server.js ./api/

EXPOSE 80

CMD ["node", "./api/server.js"]
