-- Test: Adding New Game
INSERT INTO games (title, premiere_year, release_date, rating, description, critic_score)
VALUES ('Test Game', 2024, '2024-01-01', 'E', 'A test game for evaluation.', 90);

-- Check: Check Game
SELECT * FROM games WHERE title = 'Test Game';
