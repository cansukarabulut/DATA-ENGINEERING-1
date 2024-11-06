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