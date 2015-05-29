# Webmail

## Summary

Dockerized Webmail ( [Roundcube](https://roundcube.net/) ).  
Run roundcube under the control of supervisor daemon in a docker container.  

Ubuntu Vivid/Trusty images with the following services :

+ Roundcube 1.1.1 on apache2
+ supervisord
+ sshd

built on the top of the formal Ubuntu images.

## Maintainer

[ClassCat Co.,Ltd.](http://www.classcat.com/) (This website is written in Japanese.)

## TAGS

+ latest - vivid
+ vivid
+ trusty

## Pull Image

```
$ sudo docker pull classcat/webmail
```

## Requirement

mysql container to link with mysql root password.

## Usage

```
$ sudo docker run -d --name (container-name) \  
-p 2022:22 -p 80:80 \
--link (mysql-container-name):mysql \  
-e ROOT_PASSWORD=(root-password) \  
-e SSH_PUBLIC_KEY="ssh-rsa xxx" \  
-e MYSQL_ROOT_PASSWORD=(mysql-root-password) \
-e DEFAULT_HOST=(default-host) \  
-e SMTP_SERVER=(default-smtp-server) \__
-e SMTP_USER=(smtp-user) \  
-e SMTP_PASS=(smtp-user-password) \  
-e LANGUAGE=(language) \  
-e SUPPORT_URL=(support-url) \  
classcat/webmail
```

## Example usage

```
docker run -d --name mywebmail -p 2022:22 -p 80:80 \
  -e ROOT_PASSWORD=mypassword \  
  -e SSH_PUBLIC_KEY="ssh-rsa xxx" \  
  --link mysql:mysql \
  -e MYSQL_ROOT_PASSWORD=mypassword \  
  -e DEFAULT_HOST=mailsvr.classcat.com \  
  -e SMTP_SERVER=mailsvr.classcat.com \  
  -e SMTP_USER=foo \  
  -e SMTP_PASS=foo_password \  
  -e LANGUAGE=en_US \
  classcat/webmail
```
