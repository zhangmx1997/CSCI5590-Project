#!/bin/sh
truffle compile
truffle migrate --reset 
npm run dev
