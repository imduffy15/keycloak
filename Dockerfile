from jboss/keycloak:3.3.0.Final

ADD configure.sh /opt/jboss/keycloak/bin/configure.sh

ADD entrypoint.sh /opt/jboss/custom-docker-entrypoint.sh

ENTRYPOINT [ "/opt/jboss/custom-docker-entrypoint.sh" ]
