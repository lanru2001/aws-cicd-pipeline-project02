FROM node:14-alpine 

WORKDIR /usr/src/app
COPY my-app/   .
COPY my-app/src  .
COPY my-app/public  .
COPY api/   .
COPY api/server.js  .

COPY api/package*.json  .
RUN  npm install && npm run build

EXPOSE 80

CMD ["node", "./api/server.js"]
