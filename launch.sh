#!/usr/bin/env bash

THIS_DIR=$(cd $(dirname $0); pwd)
cd $THIS_DIR

update() {
  git pull
  git submodule update --init --recursive
  install_rocks
}

# Will install luarocks on THIS_DIR/.luarocks
install_luarocks() {
  git clone https://github.com/keplerproject/luarocks.git
  cd luarocks
  git checkout tags/v2.2.1 # Current stable
   
  PREFIX="$THIS_DIR/.luarocks"
  
  ./configure --prefix=$PREFIX --sysconfdir=$PREFIX/luarocks --force-config
  
  RET=$?; if [ $RET -ne 0 ];
    then echo "Error. Exiting."; exit $RET; 
  fi

  make build && make install
  RET=$?; if [ $RET -ne 0 ];
    then echo "Error. Exiting.";exit $RET;
  fi
   
  cd ..
  rm -rf luarocks
}

install_rocks() {
  ./.luarocks/bin/luarocks install luasocket
  RET=$?; if [ $RET -ne 0 ];
    then echo "Error. Exiting."; exit $RET;
  fi

  ./.luarocks/bin/luarocks install oauth
  RET=$?; if [ $RET -ne 0 ];
    then echo "Error. Exiting."; exit $RET;
  fi
}

install() {
  git pull
  git submodule update --init --recursive
  cd tg && ./configure && make
  RET=$?; if [ $RET -ne 0 ];
    then echo "Error. Exiting."; exit $RET;
  fi
  cd ..
  install_luarocks
  install_rocks
}

if [ "$1" = "install" ]; then
  install
elif [ "$1" = "update" ]; then
  update
else
  if [ ! -f ./tg/telegram.h ]; then
    echo "tg not found"
    echo "Run $0 install"
    exit 1
  fi

  if [ ! -f ./tg/bin/telegram-cli ]; then
    echo "tg binary not found"
    echo "Run $0 install"
    exit 1
  fi
  
  PREFIX="$THIS_DIR/.luarocks"
  export LUA_CPATH=";;${PREFIX}/lib/lua/5.2/?.so"
  export LUA_PATH=";;${PREFIX}/share/lua/5.2/?.lua;${PREFIX}/share/lua/5.2/?/init.lua"
  ./tg/bin/telegram-cli -k ./tg/tg-server.pub -s ./bot/bot.lua -l 1
fi
