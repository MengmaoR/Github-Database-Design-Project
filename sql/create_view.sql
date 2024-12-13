-- 创建用户关注者数量视图
CREATE VIEW user_follower_count AS
SELECT u.account_name, COUNT(f.user2) AS follower_count
FROM users u
LEFT JOIN user1_follow_user2 f ON u.account_name = f.user2
GROUP BY u.account_name;

-- 创建用户关注数量视图
CREATE VIEW user_following_count AS
SELECT u.account_name, COUNT(f.user2) AS following_count
FROM users u
LEFT JOIN user1_follow_user2 f ON u.account_name = f.user1
GROUP BY u.account_name;

-- 创建用户收到的 star 数量视图
CREATE VIEW user_star_count AS
SELECT u.account_name, COUNT(s.user1) AS star_count
FROM users u
LEFT JOIN user1_star_user2 s ON u.account_name = s.user2
GROUP BY u.account_name;

-- 创建用户给出的 star 视图
CREATE VIEW user_given_stars AS
SELECT u.account_name, s.user2 AS starred_user
FROM users u
JOIN user1_star_user2 s ON u.account_name = s.user1;

-- 创建用户 star 统计视图
CREATE VIEW user_star_statistics AS
SELECT u.account_name, COUNT(s.user1) AS total_stars
FROM users u
LEFT JOIN user1_star_user2 s ON u.account_name = s.user2
GROUP BY u.account_name
ORDER BY total_stars DESC;

-- 创建用户 follower 统计视图
CREATE VIEW user_follower_statistics AS
SELECT u.account_name, COUNT(f.user2) AS total_followers
FROM users u
LEFT JOIN user1_follow_user2 f ON u.account_name = f.user2
GROUP BY u.account_name
ORDER BY total_followers DESC;

-- 创建仓库 star 统计视图（总共）
CREATE VIEW repository_star_statistics AS
SELECT r.Repository_name, r.Owner, COUNT(s.account_name) AS star_count
FROM repositories r
LEFT JOIN user_star_repositories s ON r.Repository_name = s.repository_name AND r.Owner = s.owner
GROUP BY r.Repository_name, r.Owner
ORDER BY star_count DESC;

-- 创建仓库 star 统计视图（在某段时间内）
CREATE VIEW repository_star_statistics_timeframe AS
SELECT r.Repository_name, r.Owner, COUNT(s.account_name) AS star_count
FROM repositories r
LEFT JOIN user_star_repositories s ON r.Repository_name = s.repository_name AND r.Owner = s.owner
WHERE s.date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY r.Repository_name, r.Owner
ORDER BY star_count DESC;

-- 创建仓库 fork 统计视图（总共）
CREATE VIEW repository_fork_statistics AS
SELECT r.Repository_name, r.Owner, COUNT(f.account_name) AS fork_count
FROM repositories r
LEFT JOIN user_fork_repositories f ON r.Repository_name = f.repository_name AND r.Owner = f.owner
GROUP BY r.Repository_name, r.Owner
ORDER BY fork_count DESC;

-- 创建仓库 fork 统计视图（在某段时间内）
CREATE VIEW repository_fork_statistics_timeframe AS
SELECT r.Repository_name, r.Owner, COUNT(f.account_name) AS fork_count
FROM repositories r
LEFT JOIN user_fork_repositories f ON r.Repository_name = f.repository_name AND r.Owner = f.owner
WHERE f.date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY r.Repository_name, r.Owner
ORDER BY fork_count DESC;

-- 创建仓库 watch 统计视图（总共）
CREATE VIEW repository_watch_statistics AS
SELECT r.Repository_name, r.Owner, COUNT(w.account_name) AS watch_count
FROM repositories r
LEFT JOIN user_watch_repositories w ON r.Repository_name = w.repository_name AND r.Owner = w.owner
GROUP BY r.Repository_name, r.Owner
ORDER BY watch_count DESC;

-- 创建仓库 watch 统计视图（在某段时间内）
CREATE VIEW repository_watch_statistics_timeframe AS
SELECT r.Repository_name, r.Owner, COUNT(w.account_name) AS watch_count
FROM repositories r
LEFT JOIN user_watch_repositories w ON r.Repository_name = w.repository_name AND r.Owner = w.owner
WHERE w.date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY r.Repository_name, r.Owner
ORDER BY watch_count DESC;

-- 创建仓库 view 统计视图（总共）
CREATE VIEW repository_view_statistics AS
SELECT r.Repository_name, r.Owner, COUNT(v.account_name) AS view_count
FROM repositories r
LEFT JOIN user_view_repositories v ON r.Repository_name = v.repository_name AND r.Owner = v.owner
GROUP BY r.Repository_name, r.Owner
ORDER BY view_count DESC;

-- 创建仓库 view 统计视图（在某段时间内）
CREATE VIEW repository_view_statistics_timeframe AS
SELECT r.Repository_name, r.Owner, COUNT(v.account_name) AS view_count
FROM repositories r
LEFT JOIN user_view_repositories v ON r.Repository_name = v.repository_name AND r.Owner = v.owner
WHERE v.date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY r.Repository_name, r.Owner
ORDER BY view_count DESC;