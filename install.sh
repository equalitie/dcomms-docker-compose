#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -e
# Directory to save dcomms config files in
DCOMMS_DIR=$PWD

COMPOSE_FILES="-f ./conf/compose/docker-compose.yml "

export HUB_REACHABLE=false
export TOR_AVAIL=false
i=0

echo "This script requires root access to interact with Docker. Please enter your password if prompted."
sudo echo ""

#This funciton uses which to discover what packages are installed on this system.
#Should investigate which command has the most interoperability
check_requirements () {
    if ! which curl docker >/dev/null; then
        printf "${RED}## This script depends on curl and docker.\n"
        printf "Please install 'curl' and/or install docker.\n"
        printf "https://docs.docker.com/engine/install/${NC}\n"
        exit 1
    fi
    if which torify >/dev/null; then
        TOR_AVAIL=true
    else
        printf "${YELLOW}## This script can take advantage of Tor to route around "
        printf "blockages and allow users to connect anonymously to your server.\n"
        printf "If you would like this functionality enabled please install 'torsocks'"
	    printf " from your package manager and re-run the script.${NC}\n"
    fi
}

detect_connectivity () {
    # This function tests all available means to retrieve the dComms repository.
    if  docker pull hello-world >/dev/null 2>&1; then
        docker rmi hello-world >/dev/null 2>&1
        printf "${GREEN}## Successfully connected to Docker Hub${NC}\n"
        HUB_REACHABLE=true
    else
        printf "${RED}## Unable to connect to Docker Hub${NC}\n"
        ((i=i+=1))
    fi

    # 'i' is the number of failed methods. Change as needed
    if (( i == 2 )); then
        printf "\n\n${RED}## All methods of retrieving dComms docker images have failed\n"
        printf "## Don't despair!\n"
        printf "## If you manage to retrieve tarfiles of the images listed below\n"
      	printf "## place them in the $DCOMMS_DIR folder and re-run this script.\n"
        printf "## Alternately, try configuring a VPN and re-try\n"
        for i in ${D_IMAGES[@]}; do
             printf "$i\n"
        done
	printf "${NC}"
        exit 1
    fi

}

#Spins up a temporary docker container to generate synapse config files and keys
matrix_config () {
    printf "${YELLOW}## Generating synapse config${NC}\n"
    docker run --rm \
        --mount type=bind,src=$(readlink -f $DCOMMS_DIR/conf/synapse),dst=/data \
        -e SYNAPSE_SERVER_NAME=matrix.$DWEB_DOMAIN \
        -e SYNAPSE_REPORT_STATS=no \
        -e SYNAPSE_DATA_DIR=/data \
    matrixdotorg/synapse:v1.121.1 generate 2>/dev/null
    sudo chown -R $USER:$USER $DCOMMS_DIR/conf/synapse/

    sed -i -z "s/database.*homeserver.db//" $DCOMMS_DIR/conf/synapse/homeserver.yaml
    sed -i "s/# vim:ft=yaml//" $DCOMMS_DIR/conf/synapse/homeserver.yaml

    printf "enable_registration: true\n" >> $DCOMMS_DIR/conf/synapse/homeserver.yaml
    printf "registration_requires_token: true\n" >> $DCOMMS_DIR/conf/synapse/homeserver.yaml
    printf "encryption_enabled_by_default_for_room_type: all\n" >> $DCOMMS_DIR/conf/synapse/homeserver.yaml
    printf "rc_registration:\n  per_second: 0.1 \n  burst_count: 2\n" >> $DCOMMS_DIR/conf/synapse/homeserver.yaml
    printf "presence:\n  enabled: false\n" >> $DCOMMS_DIR/conf/synapse/homeserver.yaml
    printf "database:\n  name: psycopg2\n  txn_limit: 10000\n  args:\n" >> $DCOMMS_DIR/conf/synapse/homeserver.yaml
    printf "    user: synapse\n    password: null\n    database: synapse\n    host: localhost\n" >> $DCOMMS_DIR/conf/synapse/homeserver.yaml
    printf "    port: 5432\n    cp_min: 5\n    cp_max: 10\n" >> $DCOMMS_DIR/conf/synapse/homeserver.yaml

    sed -i "s/TEMPLATE/$DWEB_DOMAIN/" $DCOMMS_DIR/conf/element/config.json
}

#Mastodon's config file requires a number of keys to be generated. We spin up a temporary container to do this.
#Volume must be removed before running
mastodon_config () {
    docker volume rm masto_data_tmp 2> /dev/null || true
    printf "${YELLOW}## Generating mastodon config${NC}\n"
    sudo cp -a $DCOMMS_DIR/conf/mastodon/example.env.production $DCOMMS_DIR/conf/mastodon/env.production
    SECRET_KEY_BASE=$(docker run --rm \
        --mount type=volume,src=masto_data_tmp,dst=/opt/mastodon \
            -e RUBYOPT=-W0 tootsuite/mastodon:v4.3.2 \
        bundle exec rails secret) >/dev/null

    OTP_SECRET=$(docker run --rm \
        --mount type=volume,src=masto_data_tmp,dst=/opt/mastodon \
            -e RUBYOPT=-W0 tootsuite/mastodon:v4.3.2 \
        bundle exec rails secret) >/dev/null

    VAPID_KEYS=$(docker run --rm \
        --mount type=volume,src=masto_data_tmp,dst=/opt/mastodon \
            -e RUBYOPT=-W0 tootsuite/mastodon:v4.3.2 \
        bundle exec rails mastodon:webpush:generate_vapid_key)>/dev/null
    VAPID_FRIENDLY_KEYS=${VAPID_KEYS//$'\n'/\\$'\n'}

    ACTIVE_RECORD_ENCRYPTION=$(docker run --rm \
        --mount type=volume,src=masto_data_tmp,dst=/opt/mastodon \
            -e RUBYOPT=-W0 tootsuite/mastodon:v4.3.2 \
        bundle exec rake db:encryption:init | tail -3)>/dev/null
    ACTIVE_RECORD_ENCRYPTION_FRIENDLY_KEYS=${ACTIVE_RECORD_ENCRYPTION//$'\n'/\\$'\n'}

    #REDIS_PW=$(openssl rand -base64 12)

    sed -i "s/REPLACEME/$DWEB_DOMAIN/" $DCOMMS_DIR/conf/mastodon/env.production
    sed -i "s/SECRET_KEY_BASE=/&$SECRET_KEY_BASE/" $DCOMMS_DIR/conf/mastodon/env.production
    sed -i "s/OTP_SECRET=/&$OTP_SECRET/" $DCOMMS_DIR/conf/mastodon/env.production
    sed -i "s/VAPID_KEYS=/$VAPID_FRIENDLY_KEYS/" $DCOMMS_DIR/conf/mastodon/env.production
    sed -i "s/ACTIVE_RECORD=/$ACTIVE_RECORD_ENCRYPTION_FRIENDLY_KEYS/" $DCOMMS_DIR/conf/mastodon/env.production
    sed -i 's/\r$//g' $DCOMMS_DIR/conf/mastodon/env.production
    sed -i "s/ALTERNATE_DOMAINS=social./&$DWEB_ONION/" $DCOMMS_DIR/conf/mastodon/env.production
    sed -i "s/SMTP_SERVER=/&$DWEB_DOMAIN/" $DCOMMS_DIR/conf/mastodon/env.production
    #sed -i "s/REDIS_PASSWORD=/&$REDIS_PW/" $DCOMMS_DIR/conf/mastodon/env.production
    
    printf "${YELLOW}## Initializing mastodon database${NC}\n"
    
    docker compose -f ./conf/compose/mastodon.docker-compose.yml run --entrypoint="bundle exec rails db:create" --rm mastodon-web
    docker compose -f ./conf/compose/mastodon.docker-compose.yml run --entrypoint="bundle exec rake db:prepare" --rm mastodon-web
    docker compose -f ./conf/compose/mastodon.docker-compose.yml run --entrypoint="bundle exec rake db:migrate" --rm mastodon-web

    docker volume rm -f masto_data_tmp
}

peertube_config () {
    printf "${YELLOW}## Generating Peertube config${NC}\n"

    PEERTUBE_SECRET=$(openssl rand -hex 32)

    sed -i "s/REPLACEME/$DWEB_DOMAIN/" $DCOMMS_DIR/conf/peertube/environment
    sed -i "s/PEERTUBE_SECRET=/PEERTUBE_SECRET=$PEERTUBE_SECRET/" $DCOMMS_DIR/conf/peertube/environment

}

mau_config () {
    printf "${YELLOW}## Generating mau bot config${NC}\n"
    docker run --rm --mount type=bind,src=$(readlink -f $DCOMMS_DIR/conf/mau),dst=/data dock.mau.dev/maubot/maubot:v0.3.1 1>&2  >/dev/null
    sudo chown -R $USER:$USER $DCOMMS_DIR/conf/mau 
    MAU_PW=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 18)
    printf "${RED}## Mau credentials = admin:$MAU_PW${NC}\n"
    MAU_CREDS="admin:$MAU_PW"
    sed -i "s/admins:/&\n  admin: $MAU_PW/" $DCOMMS_DIR/conf/mau/config.yaml
}   

#The main function does most of the configuration
main() {
    if [ -z $DCOMMS_DIR ]; then
        printf "${RED}No directory set for dcomms files.\nPlease edit the "
        printf "'DCOMMS_DIR' variable at the top of this script and run again.${NC}\n"
        exit 1
    elif [ -f $DCOMMS_DIR/run.sh ]; then # || [ -d $DCOMMS_DIR/conf/ ]; then
        printf "${RED}A previous installation of dcomms was found on this system.\n"
        printf "To start your services please use 'run.sh' in '$DCOMMS_DIR'.${NC}\n"
        exit 1
    fi

    export NEWT_COLORS='
    root=,black
    checkbox=,black
    entry=,black
    '
    export DELTA=false
    export MATRIX=false
    export CENO=false
    export MAU=false
    export MASTO=false
    check_requirements

    DWEB_DOMAIN=$(whiptail --inputbox "What domain would you like to use?" 8 39 --title "Domain Name" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 1 ]; then
        printf "${RED}Exiting${NC}\n"
        exit 1
    elif [[ -z "${DWEB_DOMAIN}" ]]; then
        printf "${RED}This script requires a domain name to function.\n"
        printf "${RED}Exiting${NC}\n"
        exit 1
    fi

    export DWEB_DOMAIN=$DWEB_DOMAIN
    # Replace dots with dashes
    export DWEB_FRIENDLY_DOMAIN="${DWEB_DOMAIN//./_}"

    CHOICES=$(whiptail --separate-output --checklist "Which services would you like?" 10 35 5 \
      "1" "Delta Chat" ON \
      "2" "Element & Synapse" ON \
      "3" "Ceno Bridge" ON \
      "4" "Maubot" OFF \
      "5" "Mastodon" OFF \
      "6" "Peertube" OFF 3>&1 1>&2 2>&3)

    if [ -z "$CHOICES" ]; then
      echo "No option was selected (user hit Cancel or unselected all options)"
      exit
    else
      for CHOICE in $CHOICES; do
        case "$CHOICE" in
        "1")
            D_IMAGES+=("keith/deltachat-mailadm-postfix:v0.0.3" "keith/deltachat-mailadm-dovecot:v0.0.1" "keith/deltachat-mailadm:v0.0.1")
            COMPOSE_FILES+="-f ./conf/compose/delta.docker-compose.yml "
            DELTA=true
          ;;
        "2")
            D_IMAGES+=("vectorim/element-web:v1.11.88" "matrixdotorg/synapse:v1.121.1")
            COMPOSE_FILES+="-f ./conf/compose/element.docker-compose.yml "
            MATRIX=true
          ;;
        "3")
            D_IMAGES+=("equalitie/ceno-client:v0.21.2")
            COMPOSE_FILES+="-f ./conf/compose/bridge.docker-compose.yml "
            CENO=true
          ;;
        "4")
            D_IMAGES+=("dock.mau.dev/maubot/maubot:v0.3.1")
            COMPOSE_FILES+="-f ./conf/compose/mau.docker-compose.yml "
            MAU=true
          ;;
        "5")
            D_IMAGES+=("tootsuite/mastodon:v4.3.2" "redis:7.0-alpine" "postgres:14-alpine")
            COMPOSE_FILES+="-f ./conf/compose/mastodon.docker-compose.yml "
            MASTO=true
          ;;
	"6")
           COMPOSE_FILES+="-f ./conf/compose/peertube.docker-compose.yml "
           PEERTUBE=true
	  ;;
        *)
          echo "Unsupported item $CHOICE!" >&2
          exit 1
          ;;
        esac
      done
    fi

    TMP_DIR_F=$(mktemp -d)    

    trap 'rm -rf "$TMP_DIR_C"' EXIT 

    if [[ "${MAU}" == true ]] && [[ "${MATRIX}" == false ]]; then
        print "${RED}##Mau is a Matrix bot. You must install Matrix as well.${NC}\n"
        exit
    fi

    if [[ "${TOR_AVAIL}" == true ]]; then
        DWEB_ONION=$(whiptail --inputbox "Add a hidden service address (Optional)" 8 44 --title "HS Address" 3>&1 1>&2 2>&3)
        export DWEB_ONION=$DWEB_ONION
    fi

    detect_connectivity

    if [[ "${HUB_REACHABLE}" == true ]]; then
        di=1
        printf "${GREEN}### Grabbing images from Docker Hub.${NC}\n"
        for img in ${D_IMAGES[@]}; do
            echo "dimg = $img"
            if docker pull $img; then
                unset 'FILES[$di]'
                ((di=di+=1))
            fi
           
        done
    elif [[ "${HUB_REACHABLE}" == false ]] && [[ "${TOR_AVAIL}" == true ]]; then
        di=1
        printf "${GREEN}### Grabbing images from Docker Hub.${NC}\n"
        for img in ${D_IMAGES[@]}; do
            echo "dimg = $img"
            if torify docker pull $img; then
                unset 'FILES[$di]'
                ((di=di+=1))
            fi
           
        done
    fi

    echo "#!/bin/bash" > $DCOMMS_DIR/run.sh
    if [[ "${MATRIX}" == true ]]; then
        matrix_config
    fi
    if [[ "${MAU}" == true ]]; then
        mau_config
 	echo 'echo "Mau credentials = '${MAU_CREDS}'"' >> $DCOMMS_DIR/run.sh
    fi
    if [[ "${MASTO}" == true ]]; then
        mastodon_config
    fi
    if [[ "${PEERTUBE}" == true ]]; then
        peertube_config
    fi
    echo "sudo DWEB_ONION=$DWEB_ONION DWEB_DOMAIN=$DWEB_DOMAIN DWEB_FRIENDLY_DOMAIN=$DWEB_FRIENDLY_DOMAIN docker compose $COMPOSE_FILES up -d" >> $DCOMMS_DIR/run.sh
    chmod +x $DCOMMS_DIR/run.sh
    printf "${GREEN} dComms succesfully installed! Start your services by running 'run.sh' in $DCOMMS_DIR.${NC}\n"
}

main
