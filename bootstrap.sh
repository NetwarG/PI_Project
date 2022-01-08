sudo apt-get update && sudo apt-get -y upgrade


#Установка MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list

sudo apt-get update
sudo apt-get install -y mongodb-org

sudo systemctl start mongod.service
sudo systemctl enable mongod

#Импорт данных из облачной базы в локальную
mongodump --uri mongodb+srv://ProjectUser:geqPPSUzKLWDeTxC@cluster0.noog9.mongodb.net/SimpleProject --out ~/dump
mongorestore -d SimpleProject ~/dump/SimpleProject

#Создание сервиса, выполняющего дамп локальной базы и обновление данных в облачной базе
sudo mv ~/update_db.service /etc/systemd/system
sudo mv ~/myMonitor.timer /etc/systemd/system
sudo mv ~/update_db.sh /usr/local/bin/
sudo sed -i -e 's/\r$//' /usr/local/bin/update_db.sh

sudo chmod 744 /usr/local/bin/update_db.sh
sudo chmod 644 /etc/systemd/system/update_db.service
sudo chmod 644 /etc/systemd/system/myMonitor.timer

sudo systemctl enable myMonitor.timer


#Установка и настройка Postfix (локальный почтовый сервер)
sudo debconf-set-selections <<< "postfix postfix/mailname string bestmail.com"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt-get install -y postfix

#Создание пользователя для почтового сервера, а также дирректории для хранения писем
sudo useradd mailadmin -p password
sudo usermod -a -G sudo mailadmin
mkdir -p ~/Maildir/{cur,new,tmp}

sudo postconf -e 'home_mailbox=Maildir/'
sudo postconf -e 'virtual_alias_maps= hash:/etc/postfix/virtual'
sudo touch /etc/postfix/virtual
sudo echo "admin@bestmail.com mailadmin" | sudo tee /etc/postfix/virtual
sudo postmap /etc/postfix/virtual

#Открытие портов для возможности отправки писем вне сервера + запуск сервиса postfix
sudo systemctl restart postfix
sudo ufw allow Postfix
sudo ufw allow 25
sudo systemctl enable postfix


#Установка node js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 16
nvm use 16


#Распаковка архива с проектом
sudo apt-get install -y unrar
unrar x Simple-project-master.rar

#Загрузка библиотек + сборка проекта
cd ./Simple-project-master
npm run postinstall
npm run build

#Настройка приложения Node.js для работы в среде Ubuntu, при помощи пакета PM2
sudo npm install pm2@latest -g
pm2 start ~/Simple-project-master/backend/bin/www
pm2 startup systemd
sudo env PATH=$PATH:/home/vagrant/.nvm/versions/node/v16.13.1/bin /home/vagrant/.nvm/versions/node/v16.13.1/lib/node_modules/pm2/bin/pm2 startup systemd -u vagrant --hp /home/vagrant
pm2 save

sudo reboot