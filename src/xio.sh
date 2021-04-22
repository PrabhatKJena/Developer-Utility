#!/bin/bash

help_function() {
    echo -e "\tUsage: $0 <option> <param>"
    echo -e "\t------------------------------------------------- IO Utils -----------------------------------------------------------------"
    echo -e "\t -e  | --encrypt                 : To encrypt ID(s).                         e.g.  -e 115805873229299249[,115805873229299250]"
    echo -e "\t -d  | --decrypt                 : To descrypt ID(s).                        e.g.  -d 5FSW9VDEHJ64L[,WXVEFZPYHPU2G]"
    echo -e "\t -ru | --read-user               : To read user details by account ID.       e.g.  -ru 115805873229299249"
    echo -e "\t -cu | --create-user             : To create user account by account type personal or business. 
              [-acc personal | business]                                                    e.g.  -cu -acc personal -ccy USD -c US 
              [-ccy <current-code>] 
              [-c <country-code>]"
    echo -e "\t------------------------------------------------- GIT Functions ------------------------------------------------------------"
    echo -e "\t -ga | --git-add                 : To add files for git commit.              e.g.  -ga -t \"java\|xml\"
              [-t <file-type-regex>]"
    echo -e "\t -gp | --git-push                : To commit and push files to git repo.     e.g.  -gp -t \"java\" -m \"commit message\" -r origin -b dev
              [-t <file-type-regex>]
              [-m <commit-message>]
              [-r <git-remote-name>]
              [-b <git-branch-name>]"
    echo -e "\t------------------------------------------------- Miscellaneous ------------------------------------------------------------"
    echo -e "\t -o | --open-url                 : To open URL using short url mapping.      e.g.  --o te"
    echo -e "\t -te ttl                         : To update TTL of test environment(s).     e.g.  -te ttl
                                          [${bold}NOTE${reset} : Make sure to update ${bold}testenv_list${reset} with your TE list]"
    echo -e "${yellow}\t --install                       : To install this tool to your PATH.        e.g.  --install. Then use command as ${bold}xio -h${reset}"
    exit 1 #Exit script after printing he$lp
}

encrypt() {
    _space=$1 # space
    curl -s -X POST -H 'Content-Type: application/x-www-form-urlencoded' -d "id_list=${enc_acc_list}&action=enc13&type=6" 'http://sretools02.qa.paypal.com/cgi-bin/decrypt_adv2.py' |
        grep "<td>.*</td>" | sed -e "s/<tr> <td>Input<\/td> <td>Output<\/td> <\/tr> <tr> <td>//g" -e "s/<\/td> <td>/$_space=$_space/g" -e "s/<\/td> <\/tr> <tr> <td>/     /g" -e "s/<\/td> <\/tr>//g"
}

decrypt() { # this is parameterised function ( $1 is the argument )
    _user_acc_id=$1 # 1st parameter
    _space=$2 # space
    curl -s -X POST -H 'Content-Type: application/x-www-form-urlencoded' -d "id_list=$_user_acc_id&action=dec&type=6" 'http://sretools02.qa.paypal.com/cgi-bin/decrypt_adv2.py' |
        grep "<td>.*</td>" | sed -e "s/<tr> <td>Input<\/td> <td>Output<\/td> <\/tr> <tr> <td>//g" -e "s/<\/td> <td>/$_space=$_space/g" -e "s/<\/td> <\/tr> <tr> <td>/     /g" -e "s/<\/td> <\/tr>//g"
}

read_user_by_id() {
    # If account id is encryoted then decrypt
    numeric_regex='^[0-9]+$'
    if ! [[ $user_acc_id =~ $numeric_regex ]]; then # regex matching
        echo -e "\tReceived encrypted user account Id. So, decrypting...."
        decrypted_respnse=$(decrypt $user_acc_id)
        # splitting by delimeter
        tokens=(${decrypted_respnse//=/ })
        user_acc_id=${tokens[1]}
    fi

    _resp=$(curl -s -X GET "http://jaws.qa.paypal.com/v1/QIJawsServices/restservices/user/${user_acc_id}" -H 'hostname: msmaster.qa.paypal.com')
    if [[ "$_resp" == *"DATA_NOT_EXIST"* ]]; then
        echo "${yellow}User doesn't exist for account Id : ${user_acc_id}!"
    else
        echo -e "\tUser Details\n\t------------"
        echo "$_resp" | python -c 'import json,sys;obj=json.load(sys.stdin);print "\taccountNumber = {}\n\temail = {}\n\taccountType = {}\n\tcountry = {}\n\tcurrency = {}\n\tfirstName = {}\n\tlastName = {}".format(obj["accountNumber"],obj["emailAddress"],obj["accountType"],obj["country"],obj["currency"],obj["firstName"],obj["lastName"])'
    fi
}

create_user() {
    _resp=$(curl -s -X POST 'http://jaws.qa.paypal.com/v1/QIJawsServices/restservices/user' -H 'hostName: msmaster.qa.paypal.com' -H 'Content-Type: application/json' \
        -d "{\"accountType\": \"${acc_type}\",\"country\": \"${country_code}\",\"confirmEmail\": \"true\",\"currency\": \"${currency_code}\",\"citizenship\": \"US\",\"bizYear\": \"2020\",\"confirmPhone\": \"false\",\"creditcard\": [{\"currency\": \"USD\",\"cardType\": \"visa\",\"expired\": false,\"country\": \"US\"}]}")
    echo -e "\n\tUser Details\n\t------------"
    echo "$_resp" | python -c 'import json,sys;obj=json.load(sys.stdin);print "\taccountNumber = {}\n\temail = {}\n\taccountType = {}\n\tcountry = {}\n\tcurrency = {}\n\tfirstName = {}\n\tlastName = {}".format(obj["accountNumber"],obj["emailAddress"],obj["accountType"],obj["country"],obj["currency"],obj["firstName"],obj["lastName"])'
}

git_add_files() {
    git ls-files --modified | grep "${file_type_regex}" | xargs git add
    git status
}

git_push_files() {
    git_add_files
    git ls-files --modified | grep "${file_type_regex}" | xargs git add
    git commit -m "${git_commit_msg}"
    git push ${git_remote_name} ${git_branch_name} ${val_force_push}
}

open_url() {

    ### Trying to use map but not helping much
    # full_url="";
    # for entry in "${url_map[@]}" ; do
    #     tokens=(${entry//=/ }) # splitting entry
    #     key=${tokens[0]}
    #     val=${tokens[1]}
    #     if [[ "${short_url}" =~ $key ]]; then
    #         full_url=$val
    #         echo -e "Full URL : ${full_url}"
    #         break
    #     fi
    # done
    # if [[ "${full_url}" != "" ]]; then
    #     open $full_url 
    # else
    #     echo "${yellow}No matching URL for '$short_url'${reset}"
    # fi

    case $short_url in
        te) open https://engineering.paypalcorp.com/altus/env;;
        
        c-oms|ci-oms) open https://ciapi-pilot.us-central1.gcp.dev.paypalinc.com/offermanagementserv-ci-2306/job/offermanagementserv-ci-2306/;;
        c-offer|ci-offer) open https://ciapi-pilot.us-central1.gcp.dev.paypalinc.com/offerserv-ci-3876/job/offerserv-ci-3876/;;
        c-amq|ci-amq) open https://ciapi-pilot.us-central1.gcp.dev.paypalinc.com/amqofferpostprocessd-ci-1726/job/amqofferpostprocessd-ci-1726/;;
        
        g-offer|git-offer) open https://github.paypal.com/${val_user}/offerraptorserv;;
        g-oms|git-oms) open https://github.paypal.com/${val_user}/offermanagementserv;;
        g-amq|git-amq) open https://github.paypal.com/${val_user}/amqofferpostprocessd;;
        g-xio) open https://github.paypal.com/gist/prajena/3a5b8904e4ca7131dcc734ffdf26434d;;

        td|tech-design) open https://engineering.paypalcorp.com/confluence/display/paypalshopping/Technical+Design+Documents;;
        spike) open https://engineering.paypalcorp.com/confluence/display/paypalshopping/Offer+Spikes;;
        *) echo "${yellow}No matching URL for '$short_url'${reset}"
    esac
}

update_testenv(){
    if [[ $testenv_command == ttl ]]; then
        ## now loop through the above array
        for te in "${testenv_list[@]}"
        do
            echo -e "--------------------------------------------"
            echo -e "Updating $te ....."
            echo -e "--------------------------------------------"
            testenv ttl extend $te 30d
        done
    fi
}

install_xio(){
    cp xio.sh xio
    mv xio /usr/local/bin
}

# Default option values
currency_code="USD"
country_code="US"
acc_type="personal"
val_force_push=""
val_user=$USER # getting user name

# Color constants
warn_txt_col_s="\033[33m"
warn_txt_col_e="\033[0m"
red=`tput setaf 1`
yellow=`tput setaf 3`
reset=`tput sgr 0`
bg_white=`tput setab 7`
# Font constants
bold=`tput bold`

### ---------- User's config START ------------------##
## declare an array variable
declare -a testenv_list=(
                         "te-alm-33554832110535211576975"
                         "te-prajena-865"
                         "te-prajena-3386"
                         "te-prajena-753"
                         "te-prajena-1510"
                         "te-prajena-2419"
                         "te-alm-31304572104511259613547"
                         "te-offers-release"
                         "te-offers-dev"
                         "te-offers-pr"
                        )
## Declare a map
# declare -a url_map=(
#                     "te=https://engineering.paypalcorp.com/altus/env"
#                     "c-oms=https://ciapi-pilot.us-central1.gcp.dev.paypalinc.com/offermanagementserv-ci-2306/job/offermanagementserv-ci-2306/"
#                     "c-offer=https://ciapi-pilot.us-central1.gcp.dev.paypalinc.com/offerserv-ci-3876/job/offerserv-ci-3876/"
#                     "c-amq|ci-amq=https://ciapi-pilot.us-central1.gcp.dev.paypalinc.com/amqofferpostprocessd-ci-1726/job/amqofferpostprocessd-ci-1726/"
#                     )
### ---------- User's config END ------------------##

# Parse command line input
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    opt="${1}"
    case "$opt" in

    # git operations
    -ga | --git-add)
        option="git_add_files"
        file_type_regex=${2}
        shift
        shift
        ;;    
    -gp | --git-push)
        option="git_push_files"
        shift
        ;;
    -t | --file-type)
        file_type_regex=${2}
        shift
        shift
        ;;    
    -m | --commit-message)
        git_commit_msg=${2}
        shift
        shift
        ;; 
    -r | --git-remote)
        git_remote_name=${2}
        shift
        shift
        ;;   
    -b | --git-branch)
        git_branch_name=${2}
        shift
        shift
        ;;  
    -f | --force-push)
        val_force_push="-f"
        shift
        ;;    

    ### Util functions
    -e | --encrypt)
        option="encrypt"
        enc_acc_list=${2}
        shift # past argument
        shift # past value
        ;;
    -d | --decrypt)
        option="decrypt"
        dec_acc_list=${2}
        shift
        shift
        ;;
    -ru | --read-user)
        option="read_user_by_id"
        user_acc_id=${2}
        shift
        shift
        ;;
    -cu | --create-user)
        option="create_user"
        shift # just skip this option
        ;;
    -acc | --acc-type) # account type personal or business
        acc_type=${2} # read optional after -a
        shift
        shift
        ;;
    -ccy | -cur | --currency) # currency
        currency_code=${2}
        shift
        shift
        ;;
    -c | --country)
        country_code=${2}
        shift
        shift
        ;;
    -url | -o | --open-url)
        option="open_url"
        short_url=${2}
        shift
        shift
        ;;
    -te | --testenv)
        option="update_testenv"
        testenv_command=${2}
        shift
        shift
        ;;
    --install)
        option="install_xio"
        shift
        ;;
    -help | help)
        help_function
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

## Validation options and parameters
if [[ "$option" == "git_add_files" ]]; then
    if [[ -z "$file_type_regex" ]]; then
        echo -e "${yellow}[WARN] File type(s) regex is missing. All files will be added.${reset}"
        echo ""
    fi
    git_add_files
elif [[ "$option" == "git_push_files" ]]; then
    if [[ -z "$git_commit_msg" ]]; then
        echo -e "${yellow}[WARN] Commit message is missing.${reset}"
        exit;
    fi
    if [[ -z "$file_type_regex" ]]; then
        echo -e "${yellow}[WARN] File type(s) regex is missing. All files will be pushed.${reset}"
        file_type_regex="\.*"
    fi
    if [[ -z "$git_remote_name" ]]; then
        echo -e "${yellow}[WARN] Git remote name is missing. File(s) will be pushed to 'origin'.${reset}"
        git_remote_name="origin"
    fi
    if [[ -z "$git_branch_name" ]]; then
        git_branch_name=$(git name-rev --name-only HEAD) 
        echo -e "${yellow}[WARN] Git branch name is missing. File(s) will be pushed to '${git_branch_name}' branch.${reset}"
    fi
    if [[ ${val_force_push} == "-f" ]]; then
        echo -e "${yellow}[WARN] Force push requested."
    fi
    echo ""
    
    while true; do
        read -p "Do you want to continue ? [y/n] " yn_val
        case $yn_val in
            [Yy]*) git_push_files; break;;
            [Nn]*) exit;;
            *) echo "Please answer y[es] or n[o].";;
        esac
    done
elif [[ "$option" == "create_user" ]]; then
    create_user
elif [[ "$option" == "encrypt" ]]; then
    if [[ -z "$enc_acc_list" ]]; then
        echo "${red}Missing decrypted account Id(s)!${reset}"
    else
        encrypt " "
    fi
elif [[ "$option" == "decrypt" ]]; then
    if [[ -z "$dec_acc_list" ]]; then
        echo "${red}Missing encrypted account Id(s)!${reset}"
    else
        decrypt $dec_acc_list " "
    fi
elif [[ "$option" == "read_user_by_id" ]]; then
    if [[ -z "$user_acc_id" ]]; then
        echo "${red}Missing user account Id!${reset}"
    else
        read_user_by_id
    fi
elif [[ "$option" == "open_url" ]]; then
    if [[ -z "$short_url" ]]; then
        echo "${red}Missing short URL argument!${reset}"
    else
        open_url
    fi
elif [[ "$option" == "update_testenv" ]]; then
    if [[ -z "$testenv_command" ]]; then
        echo "${red}Missing testenv command!${reset}"
    else
        update_testenv
    fi
elif [[ "$option" == "install_xio" ]]; then
    install_xio
    echo "Successfully installed ${bold}xio${reset} tool to location: /usr/locale/bin"
else
    help_function
fi

 ################### Dev Doc #########################################
#     curl -s                       to hide progress status info      #
#     $#                            command line argument count       #
#     shift                         skip option                       #
#     split wirh regex              sed -E 's/(.*)=(.*)/\2/'          #
 #####################################################################
