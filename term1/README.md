## Project Structure

The project is organized into the following files:

- 

YEAR_GIHG_SCORE.SQL


- 

TRIGGERS.SQL


- 

TEST_GAME.SQL


- 

TERM1_SQL.PY


- 

AVG_GAMES_PERYEAR.SQL


- 

AVARAGE_CRICT_SCORE.SQL


- 

1.SQL



## File Descriptions

### 

YEAR_GIHG_SCORE.SQL



This file contains SQL code to create a view that shows the highest critic scores per year for games.

```sql
DROP VIEW IF EXISTS highest_critic_scores_per_year;

CREATE VIEW highest_critic_scores_per_year AS
SELECT 
    g.premiere_year,
    MAX(g.critic_score) AS highest_score,
    g.title
FROM 
    games g
JOIN (
    SELECT 
        premiere_year,
        MAX(critic_score) AS max_score
    FROM 
        games
    GROUP BY 
        premiere_year
) AS max_scores ON g.premiere_year = max_scores.premiere_year AND g.critic_score = max_scores.max_score
GROUP BY 
    g.premiere_year, g.title;
```

### 

TRIGGERS.SQL



This file contains SQL code to create various triggers for the 

games

 and `game_reviews` tables.

```sql
DELIMITER //

CREATE TRIGGER before_game_delete
BEFORE DELETE ON games
FOR EACH ROW
BEGIN
    DELETE FROM game_reviews WHERE game_id = OLD.id;
END; //

DELIMITER ;

DELIMITER //

CREATE TRIGGER check_critic_score_before_insert
BEFORE INSERT ON games
FOR EACH ROW
BEGIN
    IF NEW.critic_score < 0 OR NEW.critic_score > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Critic score must be between 0 and 100';
    END IF;
END; //

DELIMITER ;

DELIMITER //

CREATE TRIGGER update_review_scores_after_game_update
AFTER UPDATE ON games
FOR EACH ROW
BEGIN
    UPDATE game_reviews
    SET review_score = NEW.critic_score
    WHERE game_id = NEW.id;
END; //

DELIMITER ;

DELIMITER //

CREATE TRIGGER update_game_score_after_review_insert
AFTER INSERT ON game_reviews
FOR EACH ROW
BEGIN
    DECLARE avg_score FLOAT;

    SELECT AVG(review_score) INTO avg_score
    FROM game_reviews
    WHERE game_id = NEW.game_id;

    UPDATE games
    SET critic_score = avg_score
    WHERE id = NEW.game_id;
END; //

DELIMITER ;
```

### 

TEST_GAME.SQL



This file contains SQL code to test the insertion of a new game into the 

games

 table.

```sql
-- Test: Adding New Game
INSERT INTO games (title, premiere_year, release_date, rating, description, critic_score)
VALUES ('Test Game', 2024, '2024-01-01', 'E', 'A test game for evaluation.', 90);

-- Check: Check Game
SELECT * FROM games WHERE title = 'Test Game';
```

### 

TERM1_SQL.PY



This Python script fetches game data from an API, processes it, and saves it to a CSV file.

```python
import json
import pandas as pd


with open('games.json', 'r', encoding='utf-8') as f:
    data = json.load(f)


games = data['data']


rows = []

for game in games:
    
    game_id = game['id']
    title = game['title']
    premiere_year = game['premiereYear']
    release_date = game['releaseDate']
    rating = game['rating']
    description = game['description']
    critic_score = game['criticScoreSummary']['score'] if 'criticScoreSummary' in game else None
    
    
    genres = ", ".join(genre['name'] for genre in game.get('genres', []))

    
    rows.append({
        'id': game_id,
        'title': title,
        'premiere_year': premiere_year,
        'release_date': release_date,
        'rating': rating,
        'description': description,
        'genres': genres,
        'critic_score': critic_score
    })


df = pd.DataFrame(rows)


df.to_csv('games.csv', index=False, encoding='utf-8')

print("games.csv .")
```

### 

AVG_GAMES_PERYEAR.SQL



This file contains SQL code to create a view that shows the average number of games released per year.

```sql
CREATE VIEW average_games_per_year AS
SELECT 
    premiere_year,
    COUNT(*) AS total_games,
    COUNT(*) / (SELECT COUNT(DISTINCT premiere_year) FROM games) AS average_games
FROM 
    games
GROUP BY 
    premiere_year;

SELECT * FROM average_games_per_year;
```

### 

AVARAGE_CRICT_SCORE.SQL



This file contains SQL code to create a view that shows the average critic scores per year.

```sql
DROP VIEW IF EXISTS average_critic_scores;

CREATE VIEW average_critic_scores AS
SELECT 
    g.premiere_year,
    AVG(g.critic_score) AS average_score
FROM 
    games g
JOIN 
    highest_critic_scores_per_year h ON g.premiere_year = h.premiere_year
GROUP BY 
    g.premiere_year;
```

### 

1.SQL



This file contains SQL code to create the database schema and load initial data.

```sql
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
```

## Reproducibility

To reproduce the project, follow these steps:

1. Clone the repository from GitHub.
2. Ensure you have MySQL and Python installed on your machine.
3. Run the SQL scripts in the following order:
   - 

1.SQL


   - 

YEAR_GIHG_SCORE.SQL


   - 

AVG_GAMES_PERYEAR.SQL


   - 

AVARAGE_CRICT_SCORE.SQL


   - 

TRIGGERS.SQL


4. Execute the Python script 

TERM1_SQL.PY

 to fetch and process game data.
5. Run the 

TEST_GAME.SQL

 script to test the insertion of a new game.

By following these steps, you should be able to set up the database, load data, and create the necessary views and triggers.