FROM node:10 AS ui-build
WORKDIR /usr/src/app
COPY my-app/ .
RUN npm install && npm run build

FROM node:10 AS server-build
WORKDIR /root/
COPY --from=ui-build /usr/src/app/my-app/build ./my-app/build
COPY api/package*.json .
RUN  npm install
COPY api/server.js ./api/

EXPOSE 80

CMD ["node", "./api/server.js"]
