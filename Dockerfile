# We are building our own jakarta 9 sever
#
# See: https://github.com/jboss-dockerfiles/wildfly
# Use latest jboss/base-jdk:11 image as the base
FROM jboss/base-jdk:11

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_MAIN_VERSION 24.0.1.Final
ENV WILDFLY_VERSION preview-24.0.1.Final
ENV JBOSS_HOME /opt/jboss/wildfly

USER root

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
RUN cd $HOME \
    && curl -O https://download.jboss.org/wildfly/$WILDFLY_MAIN_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss

# Expose the ports in which we're interested
EXPOSE 8080
EXPOSE 9990



# Copy Postgre JDB Driver
COPY ./docker/configuration/wildfly/modules/org /opt/jboss/wildfly/modules/org
# Copy Eclipselink
COPY ./docker/configuration/wildfly/modules/system /opt/jboss/wildfly/modules/system
# Setup configuration
COPY ./docker/configuration/wildfly/*.properties /opt/jboss/wildfly/standalone/configuration/
COPY ./docker/configuration/wildfly/standalone.xml /opt/jboss/wildfly/standalone/configuration/



# Set the default command to run on boot
# This will boot WildFly in standalone mode and bind to all interfaces
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]


