#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0 -$TIMESTAMP.log}"

echo "executing the script at $TIMESTAMP..." &>>$LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2... is $R FAILED $N"
        exit 1
    else
        echo -e "$2... is $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "Error give acces to root user ...$R failed $N"
    exit 1
else
    echo -e "you are in the root ...$G Success $N"
fi 

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "disable nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "enable nodejs:20"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

id expense
if [ $? -ne 0 ]
then
    useradd expense
    VALIDATE $? "expense user creation"
else
    echo -e " expense user already exist .. $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? " creating app directory"

curl -o /tmp/backend.zip https://expense-artifacts.s3.amazonaws.com/expense-backend-v2.zip

cd /app

unzip -o /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "download zip file and extracting to app directory"

cd /app
npm install &>>$LOGFILE
VALIDATE $? "dependencies install"

cp home/../backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "add backend.service file"

systemctl daemon-reload
systemctl enable backend
systemctl start backend &>>$LOGFILE
VALIDATE $? "daemon,enable,start the nodejs:20"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing mysql"

mysql -h 172.31.23.109 -uroot -pExpenseApp@1 < /app/schema/backend.sql
