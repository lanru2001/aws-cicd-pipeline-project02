
FROM node:10-alpine AS ui-build
WORKDIR /usr/src/app
COPY my-app/  /usr/src/app
RUN cd /usr/src/app && npm install && npm run build

FROM node:10-alpine AS server-build
WORKDIR /root/api
COPY --from=ui-build /usr/src/app/build  /root/api
COPY api/package*.json  /root/api
RUN cd  /root/api && npm install
COPY api/server.js /root/api/

EXPOSE 80

CMD ["node", "./api/server.js"]
