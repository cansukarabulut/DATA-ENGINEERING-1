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
