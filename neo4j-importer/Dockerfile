FROM mhart/alpine-node-auto

# Create app directory
RUN mkdir -p /usr/src/app
RUN mkdir -p /usr/src/app/cache
WORKDIR /usr/src/app

VOLUME /usr/src/app/cache

# Install app dependencies
ADD ./ /usr/src/app/
RUN npm install

CMD node CollectionChecker.js
