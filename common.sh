#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
M="\e[35m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)       #It will split the scriptName and gives only 10-logs which is field 1
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo -e "$M Script executing at : $N $(date)"  | tee -a $LOG_FILE

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabled existing nodejs version"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabled required nodejs version"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installed nodejs"

    npm install &>>$LOG_FILE
    VALIDATE $? "Installed npm pkgm"
}

app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        VALIDATE $? "Created roboshop user"
    else
        echo -e "Roboshop User already exists... $Y SKIPPING $N"
    fi

    mkdir -p /app &>>$LOG_FILE
    VALIDATE $? "Created app dir"


    curl -o /tmp/$APP_NAME.zip https://roboshop-artifacts.s3.amazonaws.com/$APP_NAME-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloaded the $APP_NAME service"

    rm -rf /app/*
    cd /app 
    unzip /tmp/$APP_NAME.zip &>>$LOG_FILE
    VALIDATE $? "Unzipped the $APP_NAME service"

}

systemd_setup(){
    cp $SCRIPT_DIR/$APP_NAME.service /etc/systemd/system/$APP_NAME.service &>>$LOG_FILE
    VALIDATE $? "$APP_NAME service pasted in systemd"

    systemctl daemon-reload &>>$LOG_FILE
    VALIDATE $? "Loaded the service"

    systemctl enable $APP_NAME &>>$LOG_FILE
    systemctl start $APP_NAME &>>$LOG_FILE
    VALIDATE $? "$APP_NAME service started"
}

check_root(){
    if [ $USERID -eq 0 ]   
    then
        echo -e "$M Running with sudo user... $N" | tee -a $LOG_FILE
    else
        echo -e "$R Error:: Run with sudo user to install packages $N" | tee -a $LOG_FILE
        exit 1
    fi
}


#function to validate package installed succesfully or not
VALIDATE(){

    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

printTime(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))
    echo -e "Script executed succesfully. $M Total Time Taken: $TOTAL_TIME seconds $N"
}