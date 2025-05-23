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
    TOTAL_TIME=(($END_TIME - $START_TIME))
    echo -e "Script executed succesfully. $M Total Time Taken: $TOTAL_TIME seconds $N"

}