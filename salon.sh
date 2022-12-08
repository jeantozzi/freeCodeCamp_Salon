#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

LIST_SERVICES() {
  # list all services
  echo "$($PSQL "SELECT * FROM services")" | while read SERVICE_ID PIPE SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

SERVICE_CHECK() {
  LIST_SERVICES
  read SERVICE_ID_SELECTED
  # check if it's a number
  if ! [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] ; 
  then 
    echo -e "\nPlease, input a number."
    SERVICE_CHECK
  else
    # check if it's a valid service
    SERVICE_ID_RESULT=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed 's/ //')
    if [[ -z $SERVICE_ID_RESULT ]]
    then
      echo -e "\nI could not find that service. What would you like today?"
      SERVICE_CHECK
    fi
  fi
}

PHONE_CHECK() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # query name using phone number
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed 's/ //')
  # check if it's already a customer
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    NAME_CHECK
    # insert name + phone into customers table
    CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
}

NAME_CHECK() {
  read CUSTOMER_NAME
  # check if name is empty
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "Name can't be empty."
    NAME_CHECK
  fi
}

TIME_CHECK() {
  echo -e "\nWhat time would you like your $SERVICE_ID_RESULT, $CUSTOMER_NAME?"
  read SERVICE_TIME
  # check if time is empty
  if [[ -z $SERVICE_TIME ]]
  then
    echo -e "Time can't be empty."
    TIME_CHECK
  fi
}

CREATE_APPOINTMENT() {
  # getting customer_id via phone
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # inserting appointment into appointments table
  INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  if [[ $INSERT_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_ID_RESULT at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU() {
  echo -e "\n~~~~~ MY SALON ~~~~~\n"
  echo -e "Welcome to My Salon, how can I help you?\n"

  SERVICE_CHECK
  PHONE_CHECK
  TIME_CHECK
  CREATE_APPOINTMENT
}

MAIN_MENU