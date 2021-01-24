CREATE DATABASE IF NOT EXISTS tutorial;

DROP TABLE IF EXISTS tutorial.new_users;
CREATE TABLE tutorial.new_users (
  `date` DATETIME NOT NULL,
  num_new_users INT DEFAULT 0
);

INSERT INTO tutorial.new_users (`date`, num_new_users)
VALUES
    (NOW() - INTERVAL 7 DAY, 10),
    (NOW() - INTERVAL 6 DAY, 13),
    (NOW() - INTERVAL 5 DAY, 4),
    (NOW() - INTERVAL 4 DAY, 7),
    (NOW() - INTERVAL 3 DAY, 10),
    (NOW() - INTERVAL 2 DAY, 18),
    (NOW() - INTERVAL 1 DAY, 9),
    (NOW(), 16);
