-- 创建 users 表
CREATE TABLE users (
  "account_name" VARCHAR(45) NOT NULL,
  "email" VARCHAR(45) NULL DEFAULT NULL,
  "address" VARCHAR(45) NULL DEFAULT NULL,
  "type" VARCHAR(45) NOT NULL CHECK("type" = 'individualuser' OR "type" = 'organization'),
  "password" VARCHAR(145) NOT NULL CHECK(CHAR_LENGTH("password") >= 5),
  PRIMARY KEY ("account_name")
);

-- 创建 individualuser 表
CREATE TABLE individualuser (
  "account_name" VARCHAR(45) NOT NULL,
  "name" VARCHAR(45) NULL DEFAULT NULL,
  "public_email" VARCHAR(45) NULL DEFAULT NULL,
  "bio" VARCHAR(145) NULL DEFAULT NULL,
  "url" VARCHAR(145) NULL DEFAULT NULL,
  "x_username" VARCHAR(45) NULL DEFAULT NULL,
  "company" VARCHAR(145) NULL DEFAULT NULL,
  "location" VARCHAR(145) NULL DEFAULT NULL,
  "password" VARCHAR(145) NOT NULL CHECK(CHAR_LENGTH("password") >= 5),
  PRIMARY KEY ("account_name")
);

-- 创建 organization 表
CREATE TABLE organization (
  "org_act_name" VARCHAR(45) NOT NULL,
  "contact_email" VARCHAR(45) NULL DEFAULT NULL,
  "profile" VARCHAR(45) NULL DEFAULT NULL,
  "websit" VARCHAR(45) NULL DEFAULT NULL CHECK("websit" LIKE 'http%'),
  "address" VARCHAR(45) NULL DEFAULT NULL,
  "isverified" SMALLINT,
  "password" VARCHAR(145) NOT NULL CHECK(CHAR_LENGTH("password") >= 5),
  PRIMARY KEY ("org_act_name")
);

-- 创建 indvuser_belong_org 表
CREATE TABLE indvuser_belong_org (
  "account_name" VARCHAR(45) NOT NULL,
  "org_account_name" VARCHAR(45) NOT NULL,
  "role" VARCHAR(45) NOT NULL CHECK("role" = 'owner' OR "role" = 'member'),
  PRIMARY KEY ("account_name", "org_account_name")
);

-- 创建 team 表
CREATE TABLE team (
  "organization_name" VARCHAR(45) NOT NULL,
  "team_name" VARCHAR(45) NOT NULL,
  "visibility" VARCHAR(45) NOT NULL CHECK("visibility" = 'visible' OR "visibility" = 'secret'),
  "description" VARCHAR(45) NULL,
  PRIMARY KEY ("organization_name", "team_name")
);

-- 创建 indvuser_belong_team 表
CREATE TABLE indvuser_belong_team (
  "account_name" VARCHAR(45) NOT NULL,
  "org_name" VARCHAR(45) NOT NULL,
  "team_name" VARCHAR(45) NOT NULL,
  "role" VARCHAR(45) NULL CHECK("role" = 'maintainer' OR "role" = 'member'),
  PRIMARY KEY ("account_name", "org_name", "team_name")
);

-- 创建 events 表
CREATE TABLE events (
  "name" VARCHAR(45) NOT NULL,
  "date_beginning" DATE NOT NULL,
  "date_ending" DATE NOT NULL,
  "description" VARCHAR(45) NULL,
  PRIMARY KEY ("name", "date_beginning")
);

-- 创建 user_join_events 表
CREATE TABLE user_join_events (
  "account_name" VARCHAR(45) NOT NULL,
  "event_name" VARCHAR(45) NOT NULL,
  "date_beginning" DATE NOT NULL,
  PRIMARY KEY ("account_name", "event_name", "date_beginning")
);

-- 创建 app 表
CREATE TABLE app (
  "name" VARCHAR(45) NOT NULL,
  "introduction" VARCHAR(45) NULL,
  "languages" VARCHAR(45) NULL,
  "price" INT NOT NULL,
  "install_num" INT NOT NULL,
  PRIMARY KEY ("name")
);

-- 创建 action 表
CREATE TABLE action (
  "name" INT NOT NULL,
  "stars_number" INT NULL,
  "version" VARCHAR(45) NULL,
  "money" INT NOT NULL,
  PRIMARY KEY ("name")
);

-- 创建 users_install_app 表
CREATE TABLE users_install_app (
  "account_name" VARCHAR(45) NOT NULL,
  "app_name" VARCHAR(45) NOT NULL,
  "date" DATE NOT NULL,
  PRIMARY KEY ("account_name", "app_name", "date")
);

-- 创建 users_install_action 表
CREATE TABLE users_install_action (
  "account_name" VARCHAR(45) NOT NULL,
  "action_name" VARCHAR(45) NOT NULL,
  "date" DATE NOT NULL,
  PRIMARY KEY ("account_name", "action_name", "date")
);

-- 创建 org_develop_app 表
CREATE TABLE org_develop_app (
  "account_name" VARCHAR(45) NOT NULL,
  "app_name" VARCHAR(45) NOT NULL,
  PRIMARY KEY ("account_name", "app_name")
);

-- 创建 user_contribute_action 表
CREATE TABLE user_contribute_action (
  "account_name" VARCHAR(45) NOT NULL,
  "action_name" VARCHAR(45) NOT NULL,
  PRIMARY KEY ("account_name", "action_name")
);

-- 创建 user1_follow_user2 表
CREATE TABLE user1_follow_user2 (
  "user1" VARCHAR(45) NOT NULL,
  "user2" VARCHAR(45) NOT NULL,
  "date" DATE NULL,
  PRIMARY KEY ("user1", "user2")
);

-- 创建 user1_star_user2 表
CREATE TABLE user1_star_user2 (
  "user1" VARCHAR(45) NOT NULL,
  "user2" VARCHAR(45) NOT NULL,
  "date" DATE NULL,
  PRIMARY KEY ("user1", "user2")
);

-- 创建 repositories 表
CREATE TABLE repositories (
  "repository_name" VARCHAR(45) NOT NULL,
  "owner" VARCHAR(45) NOT NULL,
  "description" VARCHAR(45) NULL,
  "public_or_private" SMALLINT,
  "updated_on" DATE NULL,
  "star_number" INT NOT NULL,
  "watch_number" INT NOT NULL,
  "fork_number" INT NOT NULL,
  PRIMARY KEY ("repository_name", "owner")
);

-- 创建 topic 表
CREATE TABLE topic (
  "topic_name" VARCHAR(45) NOT NULL,
  "description" VARCHAR(145) NOT NULL,
  "repositories_num" INT NULL,
  PRIMARY KEY ("topic_name")
);

-- 创建 repositories_match_topic 表
CREATE TABLE repositories_match_topic (
  "repository_name" VARCHAR(45) NOT NULL,
  "owner" VARCHAR(45) NOT NULL,
  "topic_name" VARCHAR(45) NOT NULL,
  PRIMARY KEY ("repository_name", "owner", "topic_name")
);

-- 创建 collections 表
CREATE TABLE collections (
  "collection_name" VARCHAR(45) NOT NULL,
  "description" VARCHAR(145) NOT NULL,
  "repositories_num" INT NULL,
  PRIMARY KEY ("collection_name")
);

-- 创建 repositories_match_collections 表
CREATE TABLE repositories_match_collections (
  "repository_name" VARCHAR(45) NOT NULL,
  "owner" VARCHAR(45) NOT NULL,
  "collection_name" VARCHAR(45) NOT NULL,
  PRIMARY KEY ("repository_name", "owner", "collection_name")
);

-- 创建 releases 表
CREATE TABLE releases (
  "repository_name" VARCHAR(45) NOT NULL,
  "owner" VARCHAR(45) NOT NULL,
  "tag" VARCHAR(45) NOT NULL,
  "release_date" DATE NOT NULL,
  "publisher" VARCHAR(45) NULL,
  "download_url" VARCHAR(145) NULL CHECK("download_url" LIKE 'http://%' OR "download_url" LIKE 'https://%'),
  PRIMARY KEY ("repository_name", "owner", "tag")
);

-- 创建 packages 表
CREATE TABLE packages (
  "repository_name" VARCHAR(45) NOT NULL,
  "owner" VARCHAR(45) NOT NULL,
  "packages_name" VARCHAR(45) NOT NULL,
  "type" VARCHAR(45) NOT NULL CHECK("type" IN ('docker', 'apache maven', 'nuget', 'rubygems', 'npm', 'containers')),
  "release_date" DATE NULL,
  PRIMARY KEY ("repository_name", "owner", "packages_name", "type")
);

-- 创建 code 表
CREATE TABLE code (
  "repository_name" VARCHAR(45) NOT NULL,
  "owner" VARCHAR(45) NOT NULL,
  "commit_num" INT NULL DEFAULT 0,
  "branch_num" INT NULL DEFAULT 0,
  "tags_num" INT NULL DEFAULT 0,
  "last_update" DATE NULL,
  PRIMARY KEY ("repository_name", "owner")
);

-- 创建 issues 表
CREATE TABLE issues (
  "repository_name" VARCHAR(45) NOT NULL,
  "owner" VARCHAR(45) NOT NULL,
  "number" INT NOT NULL,
  "account_name" VARCHAR(45) NOT NULL,
  "comment" VARCHAR(45) NULL,
  "date" DATE NULL,
  "open_or_close" SMALLINT NULL,
  PRIMARY KEY ("repository_name", "owner", "number")
);

-- 创建 pull_requests 表
CREATE TABLE pull_requests (
  "repository_name" VARCHAR(45) NOT NULL,
  "owner" VARCHAR(45) NOT NULL,
  "number" INT NOT NULL,
  "comment" VARCHAR(45) NULL,
  "date" DATE NOT NULL,
  "open_or_close" SMALLINT NOT NULL,
  PRIMARY KEY ("repository_name", "owner", "number")
);

-- 创建 user_view_repositories 表
CREATE TABLE user_view_repositories (
  "owner" VARCHAR(45) NOT NULL,
  "repository_name" VARCHAR(45) NOT NULL,
  "account_name" VARCHAR(45) NOT NULL,
  "date" DATE NOT NULL,
  PRIMARY KEY ("account_name", "repository_name", "owner")
);

-- 创建 user_fork_repositories 表
CREATE TABLE user_fork_repositories (
  "owner" VARCHAR(45) NOT NULL,
  "repository_name" VARCHAR(45) NOT NULL,
  "account_name" VARCHAR(45) NOT NULL,
  "date" DATE NOT NULL,
  PRIMARY KEY ("account_name", "repository_name", "owner")
);

-- 创建 user_star_repositories 表
CREATE TABLE user_star_repositories (
  "owner" VARCHAR(45) NOT NULL,
  "repository_name" VARCHAR(45) NOT NULL,
  "account_name" VARCHAR(45) NOT NULL,
  "date" DATE NOT NULL,
  PRIMARY KEY ("account_name", "repository_name", "owner")
);

-- 创建 user_watch_repositories 表
CREATE TABLE user_watch_repositories (
  "owner" VARCHAR(45) NOT NULL,
  "repository_name" VARCHAR(45) NOT NULL,
  "account_name" VARCHAR(45) NOT NULL,
  "date" DATE NOT NULL,
  PRIMARY KEY ("account_name", "repository_name", "owner")
);

-- 创建 user_develop_repositories 表
CREATE TABLE user_develop_repositories (
  "owner" VARCHAR(45) NOT NULL,
  "repository_name" VARCHAR(45) NOT NULL,
  "account_name" VARCHAR(45) NOT NULL,
  "role" VARCHAR(45) NOT NULL CHECK("role" = 'owner' OR "role" = 'member'),
  PRIMARY KEY ("account_name", "repository_name", "owner")
);

-- 创建 user_respond_issue_repositories 表
CREATE TABLE user_respond_issue_repositories (
  "owner" VARCHAR(45) NOT NULL,
  "repository_name" VARCHAR(45) NOT NULL,
  "account_name" VARCHAR(45) NOT NULL,
  "number" INT,
  "date" DATE NOT NULL,
  "response" VARCHAR(45),
  PRIMARY KEY ("account_name", "repository_name", "owner", "number")
);

-- 创建 user_fileschangedin_repositories 表
CREATE TABLE user_fileschangedin_repositories (
  "owner" VARCHAR(45) NOT NULL,
  "repository_name" VARCHAR(45) NOT NULL,
  "account_name" VARCHAR(45) NOT NULL,
  "number" INT NOT NULL,
  "files" VARCHAR(45) NOT NULL,
  "changed_line_content" VARCHAR(145),
  "changed_line_num" VARCHAR(45),
  PRIMARY KEY ("account_name", "repository_name", "owner", "number")
);

-- 创建 users_star_topic 表
CREATE TABLE users_star_topic (
  "account_name" VARCHAR(45) NOT NULL,
  "topic_name" VARCHAR(45) NOT NULL,
  "date" DATE NOT NULL,
  PRIMARY KEY ("account_name", "topic_name")
);

-- 创建 users_star_collections 表
CREATE TABLE users_star_collections (
  "account_name" VARCHAR(45) NOT NULL,
  "collections_name" VARCHAR(45) NOT NULL,
  "date" DATE NOT NULL,
  PRIMARY KEY ("account_name", "collections_name")
);

-- 创建 users_star_action 表
CREATE TABLE users_star_action (
  "account_name" VARCHAR(45) NOT NULL,
  "action_name" VARCHAR(45) NOT NULL,
  "date" DATE NOT NULL,
  PRIMARY KEY ("account_name", "action_name")
);

-- 创建 popular_repositories 表
CREATE TABLE popular_repositories (
  "owner" VARCHAR(45) NOT NULL,
  "repository_name" VARCHAR(45) NOT NULL,
  "language" VARCHAR(45) NOT NULL,
  "date_range" VARCHAR(45) NOT NULL,
  PRIMARY KEY ("owner", "repository_name", "date_range")
);

-- 创建 popular_users 表
CREATE TABLE popular_users (
  "account_name" VARCHAR(45) NOT NULL,
  "date_range" VARCHAR(45) NOT NULL,
  PRIMARY KEY ("account_name", "date_range")
);