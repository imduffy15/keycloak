#!/bin/bash

PATH=/opt/jboss/keycloak/bin:$PATH

function is_keycloak_running {
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/auth/admin/realms)
    if [[ $http_code -eq 401 ]]; then
        return 0
    else
        return 1
    fi
}

function configure_keycloak {
    until is_keycloak_running; do
        echo Keycloak still not running, waiting 5 seconds
        sleep 5
    done

    echo "Configuring keycloak..."

    kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user ${KEYCLOAK_USER:-admin} --password ${KEYCLOAK_PASSWORD:-admin}

    if [ "$KEYCLOAK_REALM" ]; then
        echo Creating realm $KEYCLOAK_REALM
        kcadm.sh create realms -s realm=$KEYCLOAK_REALM -s enabled=true
    fi

    if [ "$KEYCLOAK_CLIENT_IDS" ]; then
        for client in ${KEYCLOAK_CLIENT_IDS//,/ }; do 
            echo Creating client $client
            echo '{"clientId": "'${client}'", "webOrigins": ["'${KEYCLOAK_CLIENT_WEB_ORIGINS}'"], "redirectUris": ["'${KEYCLOAK_CLIENT_REDIRECT_URIS}'"]}' | kcadm.sh create clients -r ${KEYCLOAK_REALM:-master} -f -
        done
    fi

    if [ "$KEYCLOAK_REALM_ROLES" ]; then
        for role in ${KEYCLOAK_REALM_ROLES//,/ }; do
            echo Creating role $role
            kcadm.sh create roles -r ${KEYCLOAK_REALM:-master} -s name=${role}
        done
    fi

    if [ "$KEYCLOAK_REALM_SETTINGS" ]; then
        echo Applying extra Realm settings
        echo $KEYCLOAK_REALM_SETTINGS | kcadm.sh update realms/${KEYCLOAK_REALM:-master} -f -
    fi

    echo "Finished configuring keycloak"
}

if [ ! -f /opt/jboss/.docker-container-configuration-done ]; then
    touch /opt/jboss/.docker-container-configuration-done
    configure_keycloak
fi
