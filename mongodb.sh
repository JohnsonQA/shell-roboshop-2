#!/bin/bash

source ./common.sh
APP_NAME="mongodb"

check_root

cp mongo.repo /etc/yum.repos.d/mongodb.repo
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing mongodb"

systemctl enable mongod &>>$LOG_FILE
systemctl start mongod  &>>$LOG_FILE
VALIDATE $? "Starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOG_FILE
VALIDATE $? "Editing mongodb conf to update remote connections"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "restarting mongodb"

printTime




