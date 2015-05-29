# Webmail

## Summary

Dockerized Webmail ( [Roundcube](https://roundcube.net/) ).  
Run roundcube under the control of supervisor daemon in a docker container.  

Ubuntu Trusty images with the following services :

+ Roundcube 1.1.1 on apache2
+ supervisord
+ sshd

built on the top of the formal Ubuntu images.

## Maintainer

[ClassCat Co.,Ltd.](http://www.classcat.com/) (This website is written in Japanese.)

## TAGS

+ latest
+ master

## Pull Image

```
$ sudo docker pull classcat/webmail2
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
classcat/webmail2
```

## Example usage

```
docker run -d --name mywebmail2 -p 2022:22 -p 80:80 \
  -e ROOT_PASSWORD=mypassword \  
  -e SSH_PUBLIC_KEY="ssh-rsa xxx" \  
  --link mysql:mysql \
  -e MYSQL_ROOT_PASSWORD=mypassword \  
  -e DEFAULT_HOST=mailsvr.classcat.com \  
  -e SMTP_SERVER=mailsvr.classcat.com \  
  -e SMTP_USER=foo \  
  -e SMTP_PASS=foo_password \  
  -e LANGUAGE=en_US \
  classcat/webmail2
```

## Example compose

```
main:
  image: classcat/webmail2
  links:
    - postfix
    - mysql
  ports:
    - "80:80"
  environment:
    - MYSQL_ROOT_PASSWORD=
    - SMTP_SERVER=postfix
    - SMTP_USER=
    - SMTP_PASS=
    - LANGUAGE=ja_JP
    - SUPPORT_URL=http://www.classcat.com

postfix:
  image: classcat/postfix
  environment:
    - HOSTNAME=
    - DOMAINNAME=classcat.com
    - USERS=classcat:1001:password

mysql:
  image: mysql
  volumes:
    - ./mysql:/var/lib/mysql
  environment:
    - MYSQL_ROOT_PASSWORD=
```
