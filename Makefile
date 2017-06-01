all:; dapp build
test:; dapp test
deploy:; seth send --create 0x"`cat out/DSToken.bin`" -G 3000000
