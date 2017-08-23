# LICENSE CDDL 1.0 + GPL 2.0
#
# Copyright (c) 1982-2016 Oracle and/or its affiliates. All rights reserved.
#
# IMPORTANT
# ---------
# Oracle XE requires Docker 1.10.0 and above:
# Oracle XE uses shared memory for MEMORY_TARGET and needs at least 1 GB.
# Docker only supports --shm-size since Docker 1.10.0

FROM oraclelinux:7-slim

MAINTAINER Alexey Karak <alexey.karak@gmail.com>

ENV ORACLE_BASE=/u01/app/oracle \
    ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe \
    ORACLE_SID=XE \
    INSTALL_FILE_1="oracle-xe-11.2.0-1.0.x86_64.rpm.zip" \
    INSTALL_FILE_1_PARTS="oracle-xe-11.2.0-1.0.x86_64.rpm.zip.*" \
    INSTALL_DIR="$HOME/install" \
    CONFIG_RSP="xe.rsp" \
    RUN_FILE="runOracle.sh" \
    PWD_FILE="setPassword.sh"

ENV PATH=$ORACLE_HOME/bin:$PATH

COPY assets/$INSTALL_FILE_1_PARTS assets/$CONFIG_RSP assets/$RUN_FILE assets/$PWD_FILE $INSTALL_DIR/

RUN yum -y install unzip libaio bc initscripts net-tools openssl && \
    yum clean all && \
    cd $INSTALL_DIR && \
    cat $INSTALL_FILE_1_PARTS > $INSTALL_FILE_1 \
    unzip $INSTALL_FILE_1 && \
    rm $INSTALL_FILE_1 &&    \
    rpm -i Disk1/*.rpm &&    \
    mkdir -p $ORACLE_BASE/scripts/setup && \
    mkdir $ORACLE_BASE/scripts/startup && \
    ln -s $ORACLE_BASE/scripts /docker-entrypoint-initdb.d && \
    mkdir $ORACLE_BASE/oradata && \
    chown -R oracle:dba $ORACLE_BASE && \
    mv $INSTALL_DIR/$CONFIG_RSP $ORACLE_BASE/ && \
    mv $INSTALL_DIR/$RUN_FILE $ORACLE_BASE/ && \
    mv $INSTALL_DIR/$PWD_FILE $ORACLE_BASE/ && \
    ln -s $ORACLE_BASE/$PWD_FILE / && \
    cd $HOME && \
    rm -rf $INSTALL_DIR && \
    chmod ug+x $ORACLE_BASE/*.sh

VOLUME ["$ORACLE_BASE/oradata"]
EXPOSE 1521 8080

CMD exec $ORACLE_BASE/$RUN_FILE
