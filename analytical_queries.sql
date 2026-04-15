-- ==========================================================
-- PORTIMONENSE SC - HISTORICAL STATISTICAL ANALYSIS
-- Description: Queries for team performance analysis, 
--            managerial records, and historical streaks.
-- ==========================================================

-- 1. SCORING TRENDS BY SEASON (PRIMEIRA LIGA)
-- Analyzes total and average goals scored specifically in the top flight (comp_id = 1).
SELECT 
    sea.season_name, 
    com.name AS competition,
    SUM(mat.goals_for) AS goals_scored,
    AVG(mat.goals_for) AS mean_goals
FROM matches AS mat
JOIN seasons AS sea ON mat.season_id = sea.season_id
JOIN competitions AS com ON mat.comp_id = com.comp_id
WHERE mat.comp_id = 1
GROUP BY sea.season_name, com.name
ORDER BY sea.season_name;


-- 2. MANAGER RANKING (PROFESSIONAL LEAGUES)
-- Calculates Wins, Draws, Losses, and Points Per Game (PPG).
-- Limited to League competitions (IDs 1 and 2).
SELECT 
    m.name AS manager_name,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN result = 'W' THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN result = 'D' THEN 1 ELSE 0 END) AS draws,
    SUM(CASE WHEN result = 'L' THEN 1 ELSE 0 END) AS losses,
    ROUND(SUM(CASE WHEN result = 'W' THEN 3 WHEN result = 'D' THEN 1 ELSE 0 END) / COUNT(*), 2) AS points_per_game
FROM matches mat
JOIN managers m ON mat.manager_id = m.manager_id
WHERE comp_id IN (1, 2)
GROUP BY m.name
ORDER BY points_per_game DESC;


-- 3. BIGGEST VICTORIES (GOAL DIFFERENCE)
-- Lists the most expressive wins in professional league history.
SELECT 
    match_date, 
    opponent, 
    goals_for, 
    goals_against, 
    (goals_for - goals_against) AS goal_difference
FROM matches
WHERE result = 'W'
  AND comp_id IN (1, 2)
ORDER BY goal_difference DESC;

-- 4. BIGGEST LOSSES (GOAL DIFFERENCE)
-- Ranks matches where Portimonense conceded the most goals relative to scored.
SELECT 
    match_date, 
    opponent, 
    goals_for, 
    goals_against, 
    (goals_against - goals_for) AS defeat_margin,
    com.name AS competition
FROM matches mat
JOIN competitions com ON mat.comp_id = com.comp_id
WHERE result = 'L'
ORDER BY defeat_margin DESC, goals_against DESC
LIMIT 10;


-- 5. UNDEFEATED STREAK ANALYSIS (GAPS AND ISLANDS)
-- Advanced query using Window Functions to identify the longest 
-- consecutive streak of games without a loss (Wins or Draws).
WITH MatchGrades AS (
    SELECT 
        match_date,
        result,
        CASE WHEN result != 'L' THEN 1 ELSE 0 END AS is_undefeated,
        ROW_NUMBER() OVER (ORDER BY match_date) - 
        ROW_NUMBER() OVER (PARTITION BY (CASE WHEN result != 'L' THEN 1 ELSE 0 END) ORDER BY match_date) as island_group
    FROM matches
)
SELECT 
    COUNT(*) AS run_length,
    MIN(match_date) AS start_date,
    MAX(match_date) AS end_date
FROM MatchGrades
WHERE is_undefeated = 1
GROUP BY island_group
ORDER BY run_length DESC
LIMIT 1;

-- 5. LONGEST LOSING STREAK (GAPS AND ISLANDS)
-- Identifies the longest consecutive run of matches resulting in a loss.
WITH MatchLosses AS (
    SELECT 
        match_date,
        result,
        CASE WHEN result = 'L' THEN 1 ELSE 0 END AS is_loss,
        ROW_NUMBER() OVER (ORDER BY match_date) - 
        ROW_NUMBER() OVER (PARTITION BY (CASE WHEN result = 'L' THEN 1 ELSE 0 END) ORDER BY match_date) as island_group
    FROM matches
)
SELECT 
    COUNT(*) AS run_length,
    MIN(match_date) AS start_date,
    MAX(match_date) AS end_date
FROM MatchLosses
WHERE is_loss = 1
GROUP BY island_group
ORDER BY run_length DESC
LIMIT 1;

-- 6. LONGEST WINLESS STREAK (GAPS AND ISLANDS)
-- Tracks the longest consecutive run of matches without a victory (Draws or Losses).
WITH WinlessGroups AS (
    SELECT 
        match_date,
        result,
        CASE WHEN result != 'W' THEN 1 ELSE 0 END AS is_winless,
        ROW_NUMBER() OVER (ORDER BY match_date) - 
        ROW_NUMBER() OVER (PARTITION BY (CASE WHEN result != 'W' THEN 1 ELSE 0 END) ORDER BY match_date) as island_group
    FROM matches
)
SELECT 
    COUNT(*) AS run_length,
    MIN(match_date) AS start_date,
    MAX(match_date) AS end_date,
    SUM(CASE WHEN result = 'D' THEN 1 ELSE 0 END) AS total_draws,
    SUM(CASE WHEN result = 'L' THEN 1 ELSE 0 END) AS total_losses
FROM WinlessGroups
WHERE is_winless = 1
GROUP BY island_group
ORDER BY run_length DESC
LIMIT 1;

-- 7. HOME VS AWAY PERFORMANCE (VENUE ANALYSIS)
-- Calculates the total matches, wins, and win percentage based on the match venue.
-- Helps identify the strength of the "Home Field Advantage" at the Estádio Municipal de Portimão.
SELECT 
    venue,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN result = 'W' THEN 1 ELSE 0 END) AS wins,
    ROUND(SUM(CASE WHEN result = 'W' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS win_rate
FROM matches
GROUP BY venue
ORDER BY win_rate DESC;

-- 8. OPPONENT ANALYSIS: THE "BOGEY TEAM" RANKING
-- Identifies opponents that Portimonense struggles against the most.
-- Uses a threshold of > 5 games played to ensure statistical significance,
-- ranking them by the highest loss percentage.
SELECT 
    opponent, 
    COUNT(*) AS games_played,
    SUM(CASE WHEN result = 'W' THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN result = 'D' THEN 1 ELSE 0 END) AS draws,
    SUM(CASE WHEN result = 'L' THEN 1 ELSE 0 END) AS losses,
    ROUND(SUM(CASE WHEN result = 'L' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS loss_percentage
FROM matches
GROUP BY opponent
HAVING games_played > 5
ORDER BY loss_percentage DESC
LIMIT 5;