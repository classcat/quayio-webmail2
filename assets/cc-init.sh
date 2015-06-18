#!/bin/bash

########################################################################
# ClassCat/Webmail2 Asset files
# Copyright (C) 2015 ClassCat Co.,Ltd. All rights reserved.
########################################################################

#--- HISTORY 2----------------------------------------------------------
# 18-jun-15 : modified for start method.
# 29-may-15 : webmail2.
#
#--- HISTORY -----------------------------------------------------------
# 23-may-15 : changed the delimiter of sed.
# 19-may-15 : fixed.
# 14-may-15 : support_url
# 12-may-15 : smtp server. smtp_user, smtp_pass, default_host, language.
# 09-may-15 : mysql init script.
# 08-may-15 : apache2ctl
# 05-may-15 : change named of variables.
# 05-may-15 : mysql
#-----------------------------------------------------------------------


######################
### INITIALIZATION ###
######################

function init () {
  echo "ClassCat Info >> initialization code for ClassCat/Webmail2"
  echo "Copyright (C) 2015 ClassCat Co.,Ltd. All rights reserved."
  echo ""
}


############
### SSHD ###
############

function change_root_password() {
  if [ -z "${ROOT_PASSWORD}" ]; then
    echo "ClassCat Warning >> No ROOT_PASSWORD specified."
  else
    echo -e "root:${ROOT_PASSWORD}" | chpasswd
    # echo -e "${password}\n${password}" | passwd root
  fi
}


function put_public_key() {
  if [ -z "$SSH_PUBLIC_KEY" ]; then
    echo "ClassCat Warning >> No SSH_PUBLIC_KEY specified."
  else
    mkdir -p /root/.ssh
    chmod 0700 /root/.ssh
    echo "${SSH_PUBLIC_KEY}" > /root/.ssh/authorized_keys
  fi
}


#############
### MYSQL ###
#############

function save_env_for_config_mysql () {

  if [ -e /opt/env.sh ]; then
    echo "ClassCat Warning >> /opt/env.sh found, then skip configuration."
    return
  fi

  echo "export MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}" > /opt/env.sh

  #mysql -u root -p${MYSQL_ROOT_PASSWORD} -h mysql -e "CREATE DATABASE webmail"
  #mysql -u root -p${MYSQL_ROOT_PASSWORD} -h mysql -e "GRANT ALL PRIVILEGES ON webmail.* TO webmail@'%' IDENTIFIED BY 'ClassCatWebmail'";

  #mysql -u root -p${MYSQL_ROOT_PASSWORD} -h mysql webmail < /usr/local/roundcubemail-1.1.1/SQL/mysql.initial.sql
}


##################
### ROUND CUBE ###
##################

function set_config_inc_php () {
  local config_file="/var/www/html/config/config.inc.php"
  local random
  random=`pwgen -s 24 1`
  #random=`pwgen -s -y 24 1`

  # $config['des_key'] = '';
  sed -i.bak -e "s/^\$config\['des_key'\].*/\$config['des_key'] = '${random}';/" $config_file

  # $config['default_host'] = NULL;
  if [ ! -z $DEFAULT_HOST ]; then
    sed -i -e "s/^\$config\['default_host'\].*/\$config['default_host'] = '${DEFAULT_HOST}';/" $config_file
  fi

  # $config['smtp_server'] = '';
  if [ ! -z $SMTP_SERVER ]; then
    sed -i -e "s/^\$config\['smtp_server'\].*/\$config['smtp_server'] = '${SMTP_SERVER}';/" $config_file
  fi

  # $config['smtp_user'] = '';
  if [ ! -z $SMTP_USER ]; then
    sed -i -e "s/^\$config\['smtp_user'\].*/\$config['smtp_user'] = '${SMTP_USER}';/" $config_file
  fi

  #$config['smtp_pass'] = '';
  if [ ! -z $SMTP_PASS ]; then
    sed -i -e "s/^\$config\['smtp_pass'\].*/\$config['smtp_pass'] = '${SMTP_PASS}';/" $config_file
  fi

  # $config['language'] = 'en_US';
  if [ ! -z $LANGUAGE ]; then
    sed -i -e "s/^\$config\['language'\].*/\$config['language'] = '${LANGUAGE}';/" $config_file
  fi

  # $config['support_url'] = '';
  if [ ! -z $SUPPORT_URL ]; then
    sed -i -e "s#^\$config\['support_url'\].*#\$config['support_url'] = '${SUPPORT_URL}';#" $config_file
    #sed -i -e "s/^\$config\['support_url'\].*/\$config['support_url'] = '${SUPPORT_URL}';/" $config_file
  fi
}


##################
### SUPERVISOR ###
##################
# See http://docs.docker.com/articles/using_supervisord/

function proc_supervisor () {
  if [ -e /etc/supervisor/conf.d/supervisord.conf ]; then
    echo "ClassCat Warning >> /etc/supervisor/conf.d/supervisord.conf found, then skip configuration."
    return
  fi

  cat > /etc/supervisor/conf.d/supervisord.conf <<EOF
[program:ssh]
command=/usr/sbin/sshd -D

[program:apache2]
command=/usr/sbin/apache2ctl -D FOREGROUND

[program:rsyslog]
command=/usr/sbin/rsyslogd -n
EOF
}


### ENTRY POINT ###

init 
change_root_password
put_public_key
save_env_for_config_mysql

if [ -e /opt/cc-init_done ]; then
  echo "ClassCat Warning >> /opt/cc-init_done found, then skip wp configuration."
else
  set_config_inc_php
  touch /opt/cc-init_done
fi

proc_supervisor

exit 0


### End of Script ###
