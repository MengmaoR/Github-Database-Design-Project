-- 创建获取推荐仓库的存储过程
CREATE OR REPLACE PROCEDURE get_recommendations (
    IN user_name VARCHAR(45),
    OUT out_cursor REFCURSOR
) AS
BEGIN
    OPEN out_cursor FOR
        SELECT r.repository_name
        FROM repositories r
        LEFT JOIN user_view_repositories v 
               ON r.repository_name = v.repository_name 
              AND r.owner = v.owner 
              AND v.account_name = user_name
        LEFT JOIN user_star_repositories s 
               ON r.repository_name = s.repository_name 
              AND r.owner = s.owner 
              AND s.account_name = user_name
        LEFT JOIN user_fork_repositories f 
               ON r.repository_name = f.repository_name 
              AND r.owner = f.owner 
              AND f.account_name = user_name
        GROUP BY r.repository_name, r.owner
        ORDER BY 
            r.star_number DESC, 
            r.watch_number DESC, 
            r.fork_number DESC
        LIMIT 10;
END;
##

-- 创建获取热门仓库的存储过程
CREATE OR REPLACE PROCEDURE get_trending_repositories(
    OUT out_cursor REFCURSOR
) AS
BEGIN
    OPEN out_cursor FOR
        SELECT r.repository_name
        FROM repositories r
        GROUP BY r.repository_name, r.owner
        ORDER BY 
            r.star_number DESC, 
            r.watch_number DESC, 
            r.fork_number DESC
        LIMIT 10;
END;
##