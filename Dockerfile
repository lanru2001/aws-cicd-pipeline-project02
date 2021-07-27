FROM node:14-alpine 

WORKDIR /usr/src/app
COPY my-app/   /usr/src/app/
COPY my-app/src  /usr/src/app/
COPY my-app/public  /usr/src/app/
COPY api/  /usr/src/app/
COPY api/server.js /usr/src/app/

COPY api/package*.json  /usr/src/app/
RUN cd /usr/src/app/ && npm install && npm run build

EXPOSE 80

CMD ["node", "./api/server.js"]
