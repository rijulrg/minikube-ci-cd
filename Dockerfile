FROM node:10

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY test-app/package*.json ./
RUN npm install

# Copy app files
COPY test-app/test ./test
COPY test-app/server.js ./

# Exposing ports
EXPOSE 3000

# CMD
CMD [ "npm", "start" ]