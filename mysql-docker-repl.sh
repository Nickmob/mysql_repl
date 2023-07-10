docker-compose up -d

# Oracle MySQL

docker exec -ti mysql8master sh -c 'exec mysql -u root -p'

#####################################################
# На Мастере
#####################################################

# Создаём пользователя для реплики
CREATE USER repl@'%' IDENTIFIED WITH 'caching_sha2_password' BY 'Slave#2023'; 
# Даём ему права на репликацию
GRANT REPLICATION SLAVE ON *.* TO repl@'%';


######################################################
# На Слейве
######################################################

docker exec -ti mysql8slave sh -c 'exec mysql -u root -p'

# необходимо получить публичный ключ
STOP SLAVE;
CHANGE MASTER TO MASTER_HOST='mysql8master', MASTER_USER='repl', MASTER_PASSWORD='Slave#2023', MASTER_AUTO_POSITION = 1, GET_MASTER_PUBLIC_KEY = 1;
START SLAVE;

show warnings;

show slave status\G

show global variables like 'gtid_executed';

#####################################################
# На Мастере
#####################################################

use super_db;
create table test_tbl (id int, name_fld varchar(255), PRIMARY KEY (id));
insert into test_tbl values (2,'super'),(3,'hyper'),(4,'lower');

select * from test_tbl;

##################################################################
# Удаляем всё
docker-compose down --volumes

# По отдельности

docker stop mysql8master; docker rm mysql8master
docker stop mysql8slave; docker rm mysql8slave
docker volume rm mysql-docker-repl_mysqlmaster mysql-docker-repl_mysqlslave
docker rmi mysql:8

docker volume ls
docker network ls
docker images

