#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"
echo -e "\n~~~~~ WELCOME TO MY SALON ~~~~~\n"
echo -e "Hello, how can I help you?\n"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi 
  echo -e "1) hair-cutting\n2) massage\n3) waxing\n4) nail-treatments\n"
  echo -e "Enter a number to choice: "
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
  [1-4]) CHECK_INFO_CUSTOMER ;;
  *) MAIN_MENU "Please enter a valid option." ;;
  esac
}

CHECK_INFO_CUSTOMER() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # get name of customer
  CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
  # if not found
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # insert new customer
    INSERT_CUSTOMER=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")

    # get ID of customer
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")

    # get name of sevice
    TYPE_SERVICE=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    
    # get time of appointment
    echo -e "\nWhat's time would you like your $TYPE_SERVICE, $CUSTOMER_NAME."
    read SERVICE_TIME
    # update appointment information
    UPDATE_TIME=$($PSQL "insert into appointments(time, customer_id, service_id) values('$SERVICE_TIME',$CUSTOMER_ID,$SERVICE_ID_SELECTED)")
    echo -e "\nI have put you down for a $TYPE_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    # get new service_id
    
    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    CHECK_ID=$($PSQL "select time from appointments where customer_id=$CUSTOMER_ID and service_id=$SERVICE_ID_SELECTED")
    # if not exist
    if [[ -z $CHECK_ID ]]
    then
    # ask time service 
        TYPE_SERVICE=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
        echo -e "\nWhat time would you like your $TYPE_SERVICE, $CUSTOMER_NAME?"
        read SERVICE_TIME
        # add new service
        UPDATE_TIME=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')") 
    
      echo -e "\nI have put you down for a $TYPE_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
      
    fi
  fi
}

MAIN_MENU