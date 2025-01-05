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



dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Insatlling mySQL"


systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling mySQL"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting mySQL"

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
VALIDATE $? "Changing Root password in mySQL"

