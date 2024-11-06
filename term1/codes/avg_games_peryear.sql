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


