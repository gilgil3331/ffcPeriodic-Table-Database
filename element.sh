#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

isNumber() {
  # Check if the input is numeric using a regular expression
  if [[ "$1" =~ ^[0-9]+$ ]]; then
    return 0  # Return 0 (true) if the input is a number
  else
    return 1  # Return 1 (false) if the input is not a number
  fi
}

isShorterThan3() {
  local input="$1"

  if [ ${#input} -lt 3 ]; then
    return 0  # Return 0 (true) if the string is shorter than 3 characters
  else
    return 1  # Return 1 (false) if the string is 3 characters or longer
  fi
}

isEqualOrBiggerThan3() {
  local input="$1"

  if [ ${#input} -ge 3 ]; then
    return 0  # Return 0 (true) if the string is equal to or bigger than 3 characters
  else
    return 1  # Return 1 (false) if the string is smaller than 3 characters
  fi
}

checkIfValueExists() {
  local input="$1"
  if isNumber "$1"; then
    amINull=$($PSQL "SELECT * FROM elements WHERE atomic_number=$1;")
    if [ -z $amINull ]; then
      return 1
    else
      return 0
    fi
  elif isShorterThan3 "$1"; then
    amINull=$($PSQL "SELECT * FROM elements WHERE symbol='$1';")
    if [ -z $amINull ]; then
      return 1
    else
      return 0
    fi
  elif isEqualOrBiggerThan3 "$1"; then
    amINull=$($PSQL "SELECT * FROM elements WHERE name='$1';")
    if [ -z $amINull ]; then
      return 1
    else
      return 0
    fi
  fi

}

if [ -z "$1" ]; then
  echo "Please provide an element as an argument."
elif ! checkIfValueExists "$1"; then
  echo "I could not find that element in the database."
else
  if isNumber "$1"; then # if arg1 is a number
    elements=$($PSQL "SELECT * FROM elements WHERE atomic_number='$1'")
    echo "$elements" | while IFS='|' read -r atomic_number symbol name
    do
      properties=$($PSQL "SELECT * FROM properties WHERE atomic_number='$atomic_number'")
      echo "$properties" | while IFS='|' read -r atomic_number_ignore atomic_mass melting_point_celsius boiling_point_celsius type_id
      do
        types=$($PSQL "SELECT * FROM types WHERE type_id=$type_id")
        echo $types | while IFS='|' read -r type_id_ignore type
        do 
          echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point_celsius celsius and a boiling point of $boiling_point_celsius celsius."
        done
      done
    done # end of if arg1 is a number
  elif isShorterThan3 "$1"; then # if arg1 is a symbol
    elements=$($PSQL "SELECT * FROM elements WHERE symbol='$1'")
    echo "$elements" | while IFS='|' read -r atomic_number symbol name
    do
      properties=$($PSQL "SELECT * FROM properties WHERE atomic_number='$atomic_number'")
      echo "$properties" | while IFS='|' read -r atomic_number_ignore atomic_mass melting_point_celsius boiling_point_celsius type_id
      do
        types=$($PSQL "SELECT * FROM types WHERE type_id=$type_id")
        echo $types | while IFS='|' read -r type_id_ignore type
        do
          echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point_celsius celsius and a boiling point of $boiling_point_celsius celsius."
        done
      done
    done # end of if arg1 is a symbol
  else # if arg1 is a name
     elements=$($PSQL "SELECT * FROM elements WHERE name='$1'")
    echo "$elements" | while IFS='|' read -r atomic_number symbol name
    do
      properties=$($PSQL "SELECT * FROM properties WHERE atomic_number='$atomic_number'")
      echo "$properties" | while IFS='|' read -r atomic_number_ignore atomic_mass melting_point_celsius boiling_point_celsius type_id
      do
        types=$($PSQL "SELECT * FROM types WHERE type_id=$type_id")
        echo $types | while IFS='|' read -r type_id_ignore type
        do
          echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point_celsius celsius and a boiling point of $boiling_point_celsius celsius."
        done
      done
    done # end of if arg1 is a name
  fi
fi

