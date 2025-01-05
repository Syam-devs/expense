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

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "insatlling nginx"

systemctl enable nginx &>>$LOGFILE
systemctl start nginx
VALIDATE $? "enabling and starting nginx"

rm -rf /usr/share/nginx/html/\* &>>$LOGFILE
VALIDATE $? "Removing default html file"

curl -o /tmp/frontend.zip https://expense-artifacts.s3.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Download the content"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Extract the code"

cp /home/ec2-user/expense/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "add the content in expenses.conf "

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting the nginx"