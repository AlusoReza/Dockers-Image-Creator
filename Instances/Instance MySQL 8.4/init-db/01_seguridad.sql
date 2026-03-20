ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'root'; 
ALTER USER 'root'@'%' IDENTIFIED WITH caching_sha2_password BY 'root'; 
FLUSH PRIVILEGES; 
