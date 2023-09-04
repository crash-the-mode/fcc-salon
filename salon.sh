#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\nWelcome to William's Salon.\nHere are the services we offer:\n"

# display list of services offered
DISPLAY_SERVICES() {
SERVICES_OFFERED=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
echo "$SERVICES_OFFERED" | while read ID BAR NAME
  do
    echo "$ID) $NAME"
  done
}

DISPLAY_SERVICES

# ask for them to choose input
echo -e "\nPlease select the service for the appointment"
read SERVICE_ID_SELECTED
while [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] || [[ $SERVICE_ID_SELECTED -lt $($PSQL "SELECT min(service_id) FROM services") ]] || [[ $SERVICE_ID_SELECTED -gt $($PSQL "SELECT MAX(service_id) FROM services") ]]
  do
    echo "Invalid choice. Please select a valid service to book an appointment."
    DISPLAY_SERVICES
    read SERVICE_ID_SELECTED
  done

# ask for phone number
echo -e "\nPlease enter your phone number:"
read CUSTOMER_PHONE

# check if phone number already exists
NUMBER_EXISTS=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# if it does not exist, also get the customer name
if [[ -z $NUMBER_EXISTS ]]
then
  echo -e "\nPlease enter your name:"
  read CUSTOMER_NAME
# then insert the phone and customer name into the customers table
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi

# get the customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone ='$CUSTOMER_PHONE'")

# ask for the appointment time
echo -e "\nPlease enter the appointment time:"
read SERVICE_TIME

# insert into appointments table
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME." | sed 's/  / /g'
