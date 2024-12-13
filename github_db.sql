-- 删除表
-- drop table users;
-- drop table individualuser;
-- drop table organization;
-- drop table indvuser_belong_org;
-- drop table team;
-- drop table indvuser_belong_team;
-- drop table team_belong_org;
-- drop table events;
-- drop table user_join_events;
-- drop table app;
-- drop table action;
-- drop table users_install_app;
-- drop table users_install_action;
-- drop table org_develop_app;
-- drop table user_contribute_action;
-- drop table users_star_action;
-- drop table repositories;
-- drop table topic;
-- drop table repositories_match_topic;
-- drop table collections;
-- drop table repositories_match_collections;
-- drop table releases;
-- drop table packages;
-- drop table code;
-- drop table issues;
-- drop table pull_requests;
-- drop table popular_repositories;
-- drop table popular_users;
-- drop table user_fork_repositories;
-- drop table user_develop_repositories;
-- drop table user_respond_issue_repositories;
-- drop table user_fileschangedin_repositories;
-- drop table users_star_topic;
-- drop table users_star_collections;
-- drop table user_view_repositories;
-- drop table user_watch_repositories;
-- drop table user_star_repositories;
-- drop table user1_follow_user2;
-- drop table user1_star_user2;
-- drop table trending;

-- 创建 users 表
CREATE TABLE `github_info`.`users` (
  `account_name` VARCHAR(45) NOT NULL,
  `email` VARCHAR(45) NULL DEFAULT NULL,
  `address` VARCHAR(45) NULL DEFAULT NULL,
  `type` VARCHAR(45) NOT NULL CHECK(`type` = "individualuser" OR `type` = "organization"),
  `password` VARCHAR(145) NOT NULL CHECK(CHAR_LENGTH(`password`) >= 5) COMMENT '密码位数不少于 5 位',
  PRIMARY KEY (`account_name`)
);

-- 创建 individualuser 表
CREATE TABLE `github_info`.`individualuser` (
  `account_name` VARCHAR(45) NOT NULL,
  `name` VARCHAR(45) NULL DEFAULT NULL,
  `public_email` VARCHAR(45) NULL DEFAULT NULL,
  `bio` VARCHAR(145) NULL DEFAULT NULL,
  `URL` VARCHAR(145) NULL DEFAULT NULL,
  `Twitter_username` VARCHAR(45) NULL DEFAULT NULL,
  `Company` VARCHAR(145) NULL DEFAULT NULL,
  `Location` VARCHAR(145) NULL DEFAULT NULL,
  `password` VARCHAR(145) NOT NULL CHECK(CHAR_LENGTH(`password`) >= 5) COMMENT '密码位数不少于 5 位',
  PRIMARY KEY (`account_name`)
);

-- 创建 organization 表
CREATE TABLE `github_info`.`organization` (
  `Org_act_name` VARCHAR(45) NOT NULL,
  `Contact_email` VARCHAR(45) NULL DEFAULT NULL,
  `Profile` VARCHAR(45) NULL DEFAULT NULL,
  `Websit` VARCHAR(45) NULL DEFAULT NULL CHECK(`Websit` LIKE "http%"),
  `Address` VARCHAR(45) NULL DEFAULT NULL,
  `Isverified` TINYINT COMMENT '1 为已验证，0 为未验证',
  `password` VARCHAR(145) NOT NULL CHECK(CHAR_LENGTH(`password`) >= 5) COMMENT '密码位数不少于 5 位',
  PRIMARY KEY (`Org_act_name`)
);

-- 插入示例数据
INSERT INTO `github_info`.`organization` (`Org_act_name`, `Contact_email`, `Profile`, `Websit`) VALUES ('appsmith', '14333', 'Build', 'http://www');

-- 创建 indvuser_belong_org 表
CREATE TABLE `github_info`.`indvuser_belong_org` (
  `account_name` VARCHAR(45) NOT NULL,
  `Org_account_name` VARCHAR(45) NOT NULL,
  `role` VARCHAR(45) NOT NULL CHECK(`role` = "owner" OR `role` = "Member") COMMENT '表示每个成员在组织中的角色，分为 owner 和 Member',
  PRIMARY KEY (`account_name`, `Org_account_name`)
);

-- 创建 team 表
CREATE TABLE `github_info`.`team` (
  `organization_name` VARCHAR(45) NOT NULL,
  `team_name` VARCHAR(45) NOT NULL,
  `visibility` VARCHAR(45) NOT NULL CHECK(`visibility` = "visible" OR `visibility` = "secret") COMMENT '可视性，visible 表示组织内所有人可见，secret 表示仅团队成员可见',
  `description` VARCHAR(45) NULL,
  PRIMARY KEY (`organization_name`, `team_name`)
);

-- 创建 indvuser_belong_team 表
CREATE TABLE `github_info`.`indvuser_belong_team` (
  `account_name` VARCHAR(45) NOT NULL,
  `Org_name` VARCHAR(45) NOT NULL,
  `team_name` VARCHAR(45) NOT NULL,
  `role` VARCHAR(45) NULL CHECK(`role` = "Maintainer" OR `role` = "Member") COMMENT '表示每个成员在团队中的角色，分为 Maintainer 和 Member',
  PRIMARY KEY (`account_name`, `Org_name`, `team_name`)
);

-- 创建 events 表
CREATE TABLE `github_info`.`events` (
  `name` VARCHAR(45) NOT NULL,
  `date_beginning` DATE NOT NULL,
  `date_ending` DATE NOT NULL,
  `description` VARCHAR(45) NULL,
  PRIMARY KEY (`name`, `date_beginning`)
) COMMENT='与 GitHub 社区的会议、聚会和黑客马拉松相关的活动';

-- 创建 user_join_events 表
CREATE TABLE `github_info`.`user_join_events` (
  `account_name` VARCHAR(45) NOT NULL,
  `event_name` VARCHAR(45) NOT NULL,
  `date_beginning` DATE NOT NULL,
  PRIMARY KEY (`account_name`, `event_name`, `date_beginning`)
) COMMENT='个人用户参与的活动';

-- 创建 app 表
CREATE TABLE `github_info`.`app` (
  `name` VARCHAR(45) NOT NULL,
  `Introduction` VARCHAR(45) NULL,
  `languages` VARCHAR(45) NULL,
  `price` INT NOT NULL,
  `install_num` INT NOT NULL,
  PRIMARY KEY (`name`)
) COMMENT='扩展 GitHub 功能的应用';

-- 创建 action 表
CREATE TABLE `github_info`.`action` (
  `name` INT NOT NULL,
  `Stars_number` INT NULL,
  `version` VARCHAR(45) NULL,
  `money` INT NOT NULL,
  PRIMARY KEY (`name`)
);

-- 创建 users_install_app 表
CREATE TABLE `github_info`.`users_install_app` (
  `account_name` VARCHAR(45) NOT NULL,
  `app_name` VARCHAR(45) NOT NULL,
  `date` DATE NOT NULL,
  PRIMARY KEY (`account_name`, `app_name`, `date`)
);

-- 创建 users_install_action 表
CREATE TABLE `github_info`.`users_install_action` (
  `account_name` VARCHAR(45) NOT NULL,
  `action_name` VARCHAR(45) NOT NULL,
  `date` DATE NOT NULL,
  PRIMARY KEY (`account_name`, `action_name`, `date`)
);

-- 创建 org_develop_app 表
CREATE TABLE `github_info`.`org_develop_app` (
  `account_name` VARCHAR(45) NOT NULL,
  `app_name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`account_name`, `app_name`)
);

-- 创建 user_contribute_action 表
CREATE TABLE `github_info`.`user_contribute_action` (
  `account_name` VARCHAR(45) NOT NULL,
  `action_name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`account_name`, `action_name`)
);

-- 创建 user1_follow_user2 表
CREATE TABLE `github_info`.`user1_follow_user2` (
  `user1` VARCHAR(45) NOT NULL,
  `user2` VARCHAR(45) NOT NULL,
  `date` DATE NULL,
  PRIMARY KEY (`user1`, `user2`)
);

-- 创建 user1_star_user2 表
CREATE TABLE `github_info`.`user1_star_user2` (
  `user1` VARCHAR(45) NOT NULL,
  `user2` VARCHAR(45) NOT NULL,
  `date` DATE NULL,
  PRIMARY KEY (`user1`, `user2`)
);

-- 创建 repositories 表（已删除与赞助相关的列）
CREATE TABLE `github_info`.`repositories` (
  `Repository_name` VARCHAR(45) NOT NULL,
  `Owner` VARCHAR(45) NOT NULL,
  `Description` VARCHAR(45) NULL,
  `Public_or_private` TINYINT COMMENT '1 为 Public，0 为 Private',
  `Updated_on` DATE NULL,
  `star_number` INT NOT NULL,
  `watch_number` INT NOT NULL,
  `fork_number` INT NOT NULL,
  PRIMARY KEY (`Repository_name`, `Owner`)
);

-- 创建 topic 表
CREATE TABLE `github_info`.`topic` (
  `topic_name` VARCHAR(45) NOT NULL,
  `description` VARCHAR(145) NOT NULL,
  `repositories_num` INT NULL,
  PRIMARY KEY (`topic_name`)
) COMMENT='每个 topic 包含一些仓库';

-- 创建 repositories_match_topic 表
CREATE TABLE `github_info`.`repositories_match_topic` (
  `Repository_name` VARCHAR(45) NOT NULL,
  `Owner` VARCHAR(45) NOT NULL,
  `topic_name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Repository_name`, `Owner`, `topic_name`)
);

-- 创建 collections 表
CREATE TABLE `github_info`.`collections` (
  `collection_name` VARCHAR(45) NOT NULL,
  `description` VARCHAR(145) NOT NULL,
  `repositories_num` INT NULL,
  PRIMARY KEY (`collection_name`)
) COMMENT='每个 collection 包含一些仓库';

-- 创建 repositories_match_collections 表
CREATE TABLE `github_info`.`repositories_match_collections` (
  `Repository_name` VARCHAR(45) NOT NULL,
  `Owner` VARCHAR(45) NOT NULL,
  `collection_name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Repository_name`, `Owner`, `collection_name`)
);

-- 创建 releases 表
CREATE TABLE `github_info`.`releases` (
  `Repository_name` VARCHAR(45) NOT NULL,
  `Owner` VARCHAR(45) NOT NULL,
  `Tag` VARCHAR(45) NOT NULL,
  `release_date` DATE NOT NULL,
  `Publisher` VARCHAR(45) NULL,
  `download_URL` VARCHAR(145) NULL CHECK(`download_URL` LIKE "http://%" OR `download_URL` LIKE "https://%"),
  PRIMARY KEY (`Repository_name`, `Owner`, `Tag`)
);

-- 创建 packages 表
CREATE TABLE `github_info`.`packages` (
  `Repository_name` VARCHAR(45) NOT NULL,
  `Owner` VARCHAR(45) NOT NULL,
  `Packages_name` VARCHAR(45) NOT NULL,
  `type` VARCHAR(45) NOT NULL CHECK(`type` IN ("Docker", "Apache Maven", "NuGet", "RubyGems", "npm", "Containers")),
  `release_date` DATE NULL,
  PRIMARY KEY (`Repository_name`, `Owner`, `Packages_name`, `type`)
);

-- 创建 code 表
CREATE TABLE `github_info`.`code` (
  `Repository_name` VARCHAR(45) NOT NULL,
  `Owner` VARCHAR(45) NOT NULL,
  `commit_num` INT NULL DEFAULT 0,
  `branch_num` INT NULL DEFAULT 0,
  `tags_num` INT NULL DEFAULT 0,
  `last_update` DATE NULL,
  PRIMARY KEY (`Repository_name`, `Owner`)
);

-- 创建 issues 表
CREATE TABLE `github_info`.`issues` (
  `Repository_name` VARCHAR(45) NOT NULL,
  `Owner` VARCHAR(45) NOT NULL,
  `number` INT NOT NULL,
  `account_name` VARCHAR(45) NOT NULL COMMENT '提出 issue 的用户',
  `comment` VARCHAR(45) NULL,
  `date` DATE NULL,
  `open_or_close` TINYINT NULL COMMENT 'open 为 1，closed 为 0',
  PRIMARY KEY (`Repository_name`, `Owner`, `number`)
);

-- 创建 pull_requests 表
CREATE TABLE `github_info`.`pull_requests` (
  `Repository_name` VARCHAR(45) NOT NULL,
  `Owner` VARCHAR(45) NOT NULL,
  `number` INT NOT NULL,
  `comment` VARCHAR(45) NULL,
  `date` DATE NOT NULL,
  `open_or_close` TINYINT NOT NULL,
  PRIMARY KEY (`Repository_name`, `Owner`, `number`)
);

-- 创建 user_view_repositories 表
CREATE TABLE `github_info`.`user_view_repositories` (
  `owner` VARCHAR(45) NOT NULL,
  `repository_name` VARCHAR(45) NOT NULL,
  `account_name` VARCHAR(45) NOT NULL,
  `date` DATE NOT NULL,
  PRIMARY KEY (`account_name`, `repository_name`, `owner`)
);

-- 创建 user_fork_repositories 表
CREATE TABLE `github_info`.`user_fork_repositories` (
  `owner` VARCHAR(45) NOT NULL,
  `repository_name` VARCHAR(45) NOT NULL,
  `account_name` VARCHAR(45) NOT NULL,
  `date` DATE NOT NULL,
  PRIMARY KEY (`account_name`, `repository_name`, `owner`)
);

-- 创建 user_star_repositories 表
CREATE TABLE `github_info`.`user_star_repositories` (
  `owner` VARCHAR(45) NOT NULL,
  `repository_name` VARCHAR(45) NOT NULL,
  `account_name` VARCHAR(45) NOT NULL,
  `date` DATE NOT NULL,
  PRIMARY KEY (`account_name`, `repository_name`, `owner`)
);

-- 创建 user_watch_repositories 表
CREATE TABLE `github_info`.`user_watch_repositories` (
  `owner` VARCHAR(45) NOT NULL,
  `repository_name` VARCHAR(45) NOT NULL,
  `account_name` VARCHAR(45) NOT NULL,
  `date` DATE NOT NULL,
  PRIMARY KEY (`account_name`, `repository_name`, `owner`)
);

-- 创建 user_develop_repositories 表
CREATE TABLE `github_info`.`user_develop_repositories` (
  `owner` VARCHAR(45) NOT NULL,
  `repository_name` VARCHAR(45) NOT NULL,
  `account_name` VARCHAR(45) NOT NULL,
  `role` VARCHAR(45) NOT NULL CHECK(`role` = "owner" OR `role` = "member") COMMENT '包括 owner 和 member',
  PRIMARY KEY (`account_name`, `repository_name`, `owner`)
);

-- 创建 user_respond_issue_repositories 表
CREATE TABLE `github_info`.`user_respond_issue_repositories` (
  `owner` VARCHAR(45) NOT NULL,
  `repository_name` VARCHAR(45) NOT NULL,
  `account_name` VARCHAR(45) NOT NULL,
  `number` INT COMMENT 'issue 的编号',
  `date` DATE NOT NULL,
  `response` VARCHAR(45),
  PRIMARY KEY (`account_name`, `repository_name`, `owner`, `number`)
);

-- 创建 user_fileschangedin_repositories 表
CREATE TABLE `github_info`.`user_fileschangedin_repositories` (
  `owner` VARCHAR(45) NOT NULL,
  `repository_name` VARCHAR(45) NOT NULL,
  `account_name` VARCHAR(45) NOT NULL,
  `number` INT NOT NULL,
  `files` VARCHAR(45) NOT NULL,
  `changed_line_content` VARCHAR(145),
  `changed_line_num` VARCHAR(45),
  PRIMARY KEY (`account_name`, `repository_name`, `owner`, `number`)
);

-- 创建 users_star_topic 表
CREATE TABLE `github_info`.`users_star_topic` (
  `account_name` VARCHAR(45) NOT NULL,
  `topic_name` VARCHAR(45) NOT NULL,
  `date` DATE NOT NULL,
  PRIMARY KEY (`account_name`, `topic_name`)
);

-- 创建 users_star_collections 表
CREATE TABLE `github_info`.`users_star_collections` (
  `account_name` VARCHAR(45) NOT NULL,
  `collections_name` VARCHAR(45) NOT NULL,
  `date` DATE NOT NULL,
  PRIMARY KEY (`account_name`, `collections_name`)
);

-- 创建 users_star_action 表
CREATE TABLE `github_info`.`users_star_action` (
  `account_name` VARCHAR(45) NOT NULL,
  `action_name` VARCHAR(45) NOT NULL,
  `date` DATE NOT NULL,
  PRIMARY KEY (`account_name`, `action_name`)
);

-- 创建 popular_repositories 表
CREATE TABLE `github_info`.`popular_repositories` (
  `owner` VARCHAR(45) NOT NULL,
  `repository_name` VARCHAR(45) NOT NULL,
  `language` VARCHAR(45) NOT NULL,
  `date_range` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`owner`, `repository_name`, `date_range`)
);

-- 创建 popular_users 表
CREATE TABLE `github_info`.`popular_users` (
  `account_name` VARCHAR(45) NOT NULL,
  `date_range` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`account_name`, `date_range`)
);