CREATE DATABASE `capitalgains`;
USE `capitalgains`;

CREATE TABLE `trades` (
  `id`              int(11) NOT NULL AUTO_INCREMENT,
  `remote_id`       varchar(64) NOT NULL,
  `marketplace`     varchar(64) NOT NULL,
  `product`         varchar(64) NOT NULL,
   
  `buy`             int(1),
  `volume`          decimal(32, 12),
  `price`           decimal(32, 12),
  `fee`             decimal(32, 12),
  `total`           decimal (32, 12),
  
  `created_at`      timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  `shares_balance` decimal(32, 12),
  `basis` decimal(32, 12),
  `gains` decimal(32, 12),
  `isltg` int(1),
  
  PRIMARY KEY (`id`),
  KEY trade_id (`product`),
  KEY trade_id2 (`created_at`),
  UNIQUE KEY trade_id3 (`remote_id`, `marketplace`, `buy`, `product`, `volume`, `created_at`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8;