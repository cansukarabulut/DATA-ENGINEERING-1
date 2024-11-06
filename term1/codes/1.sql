CREATE DATABASE IF NOT EXISTS games_db;
USE games_db;

CREATE TABLE IF NOT EXISTS games (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    premiere_year INT,
    release_date DATE,
    rating VARCHAR(10),
    description TEXT,
    critic_score INT CHECK(critic_score BETWEEN 0 AND 100)
);

CREATE TABLE IF NOT EXISTS genres (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    genre_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS games_genres (
    game_id INT,
    genre_id INT,
    PRIMARY KEY (game_id, genre_id),
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS platforms (
    platform_id INT PRIMARY KEY AUTO_INCREMENT,
    platform_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS games_platforms (
    game_id INT,
    platform_id INT,
    PRIMARY KEY (game_id, platform_id),
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    FOREIGN KEY (platform_id) REFERENCES platforms(platform_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS critics (
    critic_id INT PRIMARY KEY AUTO_INCREMENT,
    critic_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS game_reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    game_id INT,
    critic_id INT,
    review_score INT CHECK(review_score BETWEEN 0 AND 100),
    review_text TEXT,
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    FOREIGN KEY (critic_id) REFERENCES critics(critic_id) ON DELETE CASCADE
);

LOAD DATA LOCAL INFILE '/games.csv' 
INTO TABLE games 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

INSERT INTO genres (genre_name)
VALUES ('Action'), ('Adventure'), ('RPG'), ('Shooter'), ('Strategy')
ON DUPLICATE KEY UPDATE genre_id = genre_id;

INSERT INTO platforms (platform_name)
VALUES ('PC'), ('PlayStation'), ('Xbox'), ('Nintendo Switch')
ON DUPLICATE KEY UPDATE platform_id = platform_id;


CREATE VIEW games_data_mart AS
SELECT 
    g.id AS game_id,
    g.title,
    g.premiere_year,
    g.release_date,
    g.rating,
    g.description,
    g.critic_score,
    GROUP_CONCAT(DISTINCT gen.genre_name) AS genres,
    GROUP_CONCAT(DISTINCT plat.platform_name) AS platforms
FROM 
    games g
LEFT JOIN 
    games_genres gg ON g.id = gg.game_id
LEFT JOIN 
    genres gen ON gg.genre_id = gen.genre_id
LEFT JOIN 
    games_platforms gp ON g.id = gp.game_id
LEFT JOIN 
    platforms plat ON gp.platform_id = plat.platform_id
GROUP BY 
    g.id;
