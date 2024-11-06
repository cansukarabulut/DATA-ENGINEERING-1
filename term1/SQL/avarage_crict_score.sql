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
