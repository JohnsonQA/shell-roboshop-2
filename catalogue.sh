#!/bin/bash

source ./common.sh
APP_NAME="catalogue"

check_root
app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "Added mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installed Mongodb"

#To check wethere DB already exists or not 1 means exists lesser than 1 means not exists
STATUS=$(mongosh --host mongodb.roboshop.space --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.roboshop.space </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loaded data"
else
    echo -e "Catalogue DB already exists... $M SKIPPING $N"
fi

printTime