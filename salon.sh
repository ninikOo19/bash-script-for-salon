#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\n1) cut\n2) color\n3) perm\n4) style\n5) trim"
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1|2|3|4|5) CHOSEN_MENU;;
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac
}

CHOSEN_MENU(){
  echo "What's your phone number?"
  read CUSTOMER_PHONE
  PHONE=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE';")

  if [[ -z "$PHONE" ]]; then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUS_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
  fi

  echo -e "\nWhat time would you like your $(echo "$($PSQL "SELECT service_id, name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | awk '{print $2}')"), $CUSTOMER_NAME?"
  read SERVICE_TIME

  # Get customer ID
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

  # Get service ID (assuming "cut" has ID 1)
  SERVICE_ID=$SERVICE_ID_SELECTED

  # Insert appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME');")

   
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  
}
MAIN_MENU