#!/bin/sh

cd tg

if [ ! -f ./telegram ]; then
    echo "Compile telegram first:"
    echo "cd tg && ./configure && make"
    exit
fi

./telegram -s ../bot/bot.lua
