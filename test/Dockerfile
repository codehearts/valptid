FROM node:slim

RUN npm install mocha chai sinon mocha-sinon coffeescript nyc codecov
ENV PATH $PATH:/node_modules/.bin

WORKDIR /app
VOLUME /app
