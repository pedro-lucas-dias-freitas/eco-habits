CREATE DATABASE IF NOT EXISTS eco_habits_dev
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

CREATE USER 'eco_user'@'localhost' IDENTIFIED BY 'senha123banco';

GRANT ALL PRIVILEGES ON eco_habits_dev.* TO 'eco_user'@'localhost';

FLUSH PRIVILEGES;