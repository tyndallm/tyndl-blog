FROM node:7.3.0-slim

MAINTAINER Matt Tyndall <matt@tyndl.me>

ENV HEXO_SERVER_PORT=4000

## update the repositories
RUN apt-get update
## install git for deployment
RUN apt-get install git -y

## install hexo-cli globally
RUN npm install -g hexo-cli

## set the workdir
WORKDIR /app

## expose the HEXO_SERVER_PORT
EXPOSE ${HEXO_SERVER_PORT}

## npm install the latest packages from package.json and run the hexo server
CMD npm install; hexo clean; hexo server -d -p ${HEXO_SERVER_PORT}