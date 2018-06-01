#!/bin/bash
output "Make sure you double check before hitting enter! Only one shot at these!"
read -e -p "Enter Website title (e.g. Iquidus) : " WEBSITE_TITLE
read -e -p "Enter Website port (e.g. 3001) : " WEBSITE_PORT
read -e -p "Enter Coin Name (e.g. Aither) : " COIN_NAME
read -e -p "Enter Coin Symbol (e.g. AIT) : " COIN_SYMBOL
read -e -p "Enter Mongo DB Name (e.g. explorerdb) : " MONGO_DB_NAME
read -e -p "Enter Mongo DB User (e.g. iquidus) : " MONGO_DB_USER
read -e -p "Enter Mongo DB Pass (e.g. 3xp!0reR) : " MONGO_DB_PASS
read -e -p "Enter Wallet RPC Port (e.g. 40999) : " WALLET_PORT
read -e -p "Enter Wallet RPC User (e.g. aithercoin) : " WALLET_USER
read -e -p "Enter Wallet RPC Pass (e.g. 123gfjk3R3pCCVjHtbRde2s5kzdf233sa) : " WALLET_PASS
echo ####################################################
echo ####### Install nodejs #############################
echo ####################################################
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install pm2 -g
echo ####################################################
echo ####### Install mongo ##############################
echo ####################################################
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
sudo apt-get update -y
sudo apt-get install -y mongodb-org
echo "use $MONGO_DB_NAME" > install-mongo.js
echo 'db.createUser( { user: "$MONGO_DB_USER", pwd: "$MONGO_DB_PASS", roles: [ "readWrite" ] } )' >> install-mongo.js
echo 'exit' >> install-mongo.js
mongo < install-mongo.js
rm -f install-mongo.js
echo ####################################################
echo ####### Install service ############################
echo ####################################################
rm -f package-lock.json
npm install --production
cp settings.json.template settings.json
sed -i -- 's/"title": "IQUIDUS"/"title": "$WEBSITE_TITLE"/g' settings.json
sed -i -- 's/3001/$WEBSITE_PORT/g' settings.json
sed -i -- 's/Darkcoin/$COIN_NAME/g' settings.json
sed -i -- 's/DRK/$COIN_SYMBOL/g' settings.json
sed -i -- 's/"user": "iquidus"/"user": "$MONGO_DB_USER"/g' settings.json
sed -i -- 's/"password": "3xp!0reR"/"password": "$MONGO_DB_PASS"/g' settings.json
sed -i -- 's/"database": "explorerdb"/"database": "$MONGO_DB_NAME"/g' settings.json
sed -i -- 's/9332/$WALLET_PORT/g' settings.json
sed -i -- 's/darkcoinrpc/$WALLET_USER/g' settings.json
sed -i -- 's/123gfjk3R3pCCVjHtbRde2s5kzdf233sa/$WALLET_PASS/g' settings.json
echo ####################################################
echo ####### Everything's ok ############################
echo ####################################################
echo "Please run `pm2 start bin/cluster` to run instance"
echo "Please run `pm2 monit` to see the monitor"
