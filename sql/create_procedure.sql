-- 创建获取推荐仓库的存储过程
CREATE OR REPLACE PROCEDURE get_recommendations (
    IN user_id INT,
    OUT out_cursor REFCURSOR
) AS
BEGIN
    OPEN out_cursor FOR
        SELECT r.repository_name
        FROM repositories r
        LEFT JOIN user_view_repositories v 
               ON r.repository_name = v.repository_name 
              AND r.owner = v.owner 
              AND v.account_name = user_id
        LEFT JOIN user_star_repositories s 
               ON r.repository_name = s.repository_name 
              AND r.owner = s.owner 
              AND s.account_name = user_id
        LEFT JOIN user_fork_repositories f 
               ON r.repository_name = f.repository_name 
              AND r.owner = f.owner 
              AND f.account_name = user_id
        GROUP BY r.repository_name, r.owner
        ORDER BY 
            COUNT(v.repository_name) DESC, 
            COUNT(s.repository_name) DESC, 
            COUNT(f.repository_name) DESC
        LIMIT 10;
END;
##

-- 创建获取热门仓库的存储过程
CREATE OR REPLACE PROCEDURE get_trending_repositories(
    IN time_range INT,
    IN language VARCHAR(50),
    OUT out_cursor REFCURSOR
) AS
BEGIN
    OPEN out_cursor FOR
        SELECT r.repository_name
        FROM repositories r
        LEFT JOIN user_star_repositories s 
               ON r.repository_name = s.repository_name 
              AND r.owner = s.owner
        LEFT JOIN user_fork_repositories f 
               ON r.repository_name = f.repository_name 
              AND r.owner = f.owner
        LEFT JOIN code c 
               ON r.repository_name = c.repository_name 
              AND r.owner = c.owner
        LEFT JOIN user_view_repositories v 
               ON r.repository_name = v.repository_name 
              AND r.owner = v.owner
        LEFT JOIN user_view_repositories p 
               ON r.repository_name = p.repository_name 
              AND r.owner = p.owner
        WHERE r.language = language
          AND p.date > CURRENT_DATE - (time_range * INTERVAL '1 day')
        GROUP BY r.repository_name, r.owner
        ORDER BY 
            COUNT(s.repository_name) DESC, 
            COUNT(f.repository_name) DESC, 
            COUNT(c.repository_name) DESC, 
            COUNT(v.repository_name) DESC, 
            COUNT(p.repository_name) DESC
        LIMIT 10;
END;
##