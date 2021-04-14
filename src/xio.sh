#!/bin/bash

helpFunction() {
  echo ""
  echo "  Usage: $0 <option> <param>"
  echo -e "\t -e  | --encrypt                 : To encrypt ID(s).   Example: 115805873229299249,115805873229299250"
  echo -e "\t -d  | --decrypt                 : To descrypt ID(s).  Example: 5FSW9VDEHJ64L,WXVEFZPYHPU2G"
  echo -e "\t -ru | --read-user               : To read user details by account ID.  Example: -acc personal -ccy USD -c US"
  echo -e "\t -cu | --create-user             : To create user account by account type personal or business. 
              [-acc personal | business]    
              [-ccy <current-code>] 
              [-c <country-code>]"     
                                        
  exit 1    #Exit script after printing help
}

encrypt() {
  curl -s -X POST -H 'Content-Type: application/x-www-form-urlencoded' -d "id_list=${enc_acc_list}&action=enc13&type=6" 'http://sretools02.qa.paypal.com/cgi-bin/decrypt_adv2.py' |
    grep "<td>.*</td>" | sed -e "s/<tr> <td>Input<\/td> <td>Output<\/td> <\/tr> <tr> <td>//g" -e "s/<\/td> <td>/ = /g" -e "s/<\/td> <\/tr> <tr> <td>/     /g" -e "s/<\/td> <\/tr>//g"
}

decrypt() {
  curl -s -X POST -H 'Content-Type: application/x-www-form-urlencoded' -d "id_list=${dec_acc_list}&action=dec&type=6" 'http://sretools02.qa.paypal.com/cgi-bin/decrypt_adv2.py' |
    grep "<td>.*</td>" | sed -e "s/<tr> <td>Input<\/td> <td>Output<\/td> <\/tr> <tr> <td>//g" -e "s/<\/td> <td>/ = /g" -e "s/<\/td> <\/tr> <tr> <td>/     /g" -e "s/<\/td> <\/tr>//g"
}

read_user_by_id() {
  _resp=$(curl -s -X GET "http://jaws.qa.paypal.com/v1/QIJawsServices/restservices/user/${user_acc_id}" -H 'hostname: msmaster.qa.paypal.com')
  if [[ "$_resp" == *"DATA_NOT_EXIST"* ]]; then
    echo "User doesn't exist for account Id : ${user_acc_id}!"
  else 
    echo -e "\n\tUser Details\n\t------------"
    echo "$_resp" | python -c 'import json,sys;obj=json.load(sys.stdin);print "\temail = {}\n\taccountType = {}\n\tcountry = {}\n\tcurrency = {}\n\tfirstName = {}\n\tlastName = {}".format(obj["emailAddress"],obj["accountType"],obj["country"],obj["currency"],obj["firstName"],obj["lastName"])'
  fi
}

create_user() {
  _resp=$(curl -s -X POST 'http://jaws.qa.paypal.com/v1/QIJawsServices/restservices/user' -H 'hostName: msmaster.qa.paypal.com' -H 'Content-Type: application/json' \
        -d "{\"accountType\": \"${acc_type}\",\"country\": \"${country_code}\",\"confirmEmail\": \"true\",\"currency\": \"${currency_code}\",\"citizenship\": \"US\",\"bizYear\": \"2020\",\"confirmPhone\": \"false\",\"creditcard\": [{\"currency\": \"USD\",\"cardType\": \"visa\",\"expired\": false,\"country\": \"US\"}]}")
  echo -e "\n\tUser Details\n\t------------"
  echo "$_resp" | python -c 'import json,sys;obj=json.load(sys.stdin);print "\taccountNumber = {}\n\temail = {}\n\taccountType = {}\n\tcountry = {}\n\tcurrency = {}\n\tfirstName = {}\n\tlastName = {}".format(obj["accountNumber"],obj["emailAddress"],obj["accountType"],obj["country"],obj["currency"],obj["firstName"],obj["lastName"])'
}

# Default option values
currency_code="USD"
country_code="US"
acc_type="personal"

# Parse command line input
POSITIONAL=()
while [[ $# -gt 0 ]]
do
  opt="${1}"
  case "$opt" in
  -e|--encrypt)
    option="encrypt"
    enc_acc_list=${2}
    shift # past argument
    shift # past value
    ;;
  -d|--decrypt)
    option="decrypt"
    dec_acc_list=${2}
    shift
    shift
    ;;
  -ru|--read-user)
    option="read_user_by_id"
    user_acc_id=${2}
    shift
    shift
    ;;
  -cu|--create-user)
    option="create_user"
    shift     # just skip this option
    ;;
  -acc|--acc-type) # account type personal or business
    acc_type=${2} # read optional after -a 
    shift
    shift
    ##create_user # do not call create_user function. Instead call et end after parsing all options.
    ;;
  -ccy|-cur|--currency) # currency
    currency_code=${2}
    shift
    shift
    ;;
  -c|--country) # currency
    country_code=${2}
    shift
    shift
    ;;
  -help|help)
    helpFunction
    ;;
  *)
    echo ""
    echo "Unknown option $1. Please run \"$0 help\" to know more."
    shift
    shift
    ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ "$option" == "create_user" ]]; then
  create_user
elif [[ "$option" == "encrypt" ]]; then
  if [[ -z "$enc_acc_list" ]]; then
    echo "Missing argument(s)!"
  else
    encrypt
  fi
elif [[ "$option" == "decrypt" ]]; then
  if [[ -z "$dec_acc_list" ]]; then
    echo "Missing argument(s)!"
  else
    decrypt
  fi
elif [[ "$option" == "read_user_by_id" ]]; then
  if [[ -z "$user_acc_id" ]]; then
    echo "Missing argument(s)!"
  else
    read_user_by_id
  fi
else
  helpFunction
fi

###### Dev Doc ########################################
#     curl -s       to hide progress status info      #
#     $#            command loine argument count      #
#     shift         skip argument                     #
#######################################################
