#!/bin/bash
read -e -p "Enter Website port (default. 3001) : " WEBSITE_PORT
if [[ $WEBSITE_PORT == "" ]]; then
	WEBSITE_PORT=3001
fi
read -e -p "Enter Coin Name (default. Aither) : " COIN_NAME
if [[ $COIN_NAME == "" ]]; then
	COIN_NAME="Aither"
fi
read -e -p "Enter Coin Symbol (default. AIT) : " COIN_SYMBOL
if [[ $COIN_SYMBOL == "" ]]; then
	COIN_SYMBOL="AIT"
fi
read -e -p "Enter Mongo DB Name (default. explorerdb) : " MONGO_DB_NAME
if [[ $MONGO_DB_NAME == "" ]]; then
	MONGO_DB_NAME="explorerdb"
fi
read -e -p "Enter Mongo DB User (default. aithercoin) : " MONGO_DB_USER
if [[ $MONGO_DB_USER == "" ]]; then
	MONGO_DB_USER="aithercoin"
fi
read -e -p "Enter Mongo DB Pass (default. 3xp!0reR) : " MONGO_DB_PASS
if [[ $MONGO_DB_PASS == "" ]]; then
	MONGO_DB_PASS="3xp!0reR"
fi
read -e -p "Enter Wallet RPC Port (default. 40999) : " WALLET_PORT
if [[ $WALLET_PORT == "" ]]; then
	WALLET_PORT="40999"
fi
read -e -p "Enter Wallet RPC User (default. aithercoin) : " WALLET_USER
if [[ $WALLET_USER == "" ]]; then
	WALLET_USER="aithercoin"
fi
read -e -p "Enter Wallet RPC Pass (default. 123gfjk3R3pCCVjHtbRde2s5kzdf233sa) : " WALLET_PASS
if [[ $WALLET_PASS == "" ]]; then
	WALLET_PASS="123gfjk3R3pCCVjHtbRde2s5kzdf233sa"
fi
echo ####################################################
echo ####### Install nodejs #############################
echo ####################################################
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install pm2 -g
echo ####################################################
echo ####### Install mongo ##############################
echo ####################################################
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
sudo apt-get update -y
sudo apt-get install -y mongodb-org
service mongod start
echo "use $MONGO_DB_NAME" > install-mongo.js
echo 'db.createUser( { user: "'$MONGO_DB_USER'", pwd: "'$MONGO_DB_PASS'", roles: [ "readWrite" ] } )' >> install-mongo.js
echo 'exit' >> install-mongo.js
mongo < install-mongo.js
rm -f install-mongo.js
echo ####################################################
echo ####### Install service ############################
echo ####################################################
rm -f package-lock.json
npm install --production
cp settings.json.template settings.json
sed -i -- 's/3001/'$WEBSITE_PORT'/g' settings.json
sed -i -- 's/Darkcoin/'$COIN_NAME'/g' settings.json
sed -i -- 's/DRK/'$COIN_SYMBOL'/g' settings.json
sed -i -- 's/"user": "iquidus"/"user": "'$MONGO_DB_USER'"/g' settings.json
sed -i -- 's/"password": "3xp!0reR"/"password": "'$MONGO_DB_PASS'"/g' settings.json
sed -i -- 's/"database": "explorerdb"/"database": "'$MONGO_DB_NAME'"/g' settings.json
sed -i -- 's/9332/'$WALLET_PORT'/g' settings.json
sed -i -- 's/darkcoinrpc/'$WALLET_USER'/g' settings.json
sed -i -- 's/123gfjk3R3pCCVjHtbRde2s5kzdf233sa/'$WALLET_PASS'/g' settings.json
echo ####################################################
echo ####### Everything's ok ############################
echo ####################################################
echo 'Please run `pm2 start bin/cluster` to run instance'
echo 'Please run `pm2 monit` to see the monitor'
