FROM node:10 AS ui-build
WORKDIR /usr/src/app
COPY my-app/src  ./my-app/
COPY my-app/public  ./my-app/
#RUN npm install && npm run build

FROM node:10 AS server-build
WORKDIR /root/
COPY --from=ui-build /usr/src/app/my-app/build ./my-app/build
COPY api/package*.json ./api/
RUN npm install && npm run build
COPY api/server.js ./api/

EXPOSE 80

CMD ["node", "./api/server.js"]
