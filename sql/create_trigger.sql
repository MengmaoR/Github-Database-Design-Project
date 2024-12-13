-- 创建触发器函数：检查团队成员是否存在于组织成员中
CREATE OR REPLACE FUNCTION check_team_member_exists_func()
RETURNS TRIGGER AS $$
DECLARE
    org_count INT;
BEGIN
    SELECT COUNT(*) INTO org_count
    FROM indvuser_belong_org
    WHERE account_name = NEW.account_name AND Org_account_name = NEW.Org_name;
    
    IF org_count = 0 THEN
        RAISE EXCEPTION 'User must be part of the organization to be added to the team';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器：检查团队成员是否存在于组织成员中
CREATE TRIGGER check_team_member_exists
BEFORE INSERT ON indvuser_belong_team
FOR EACH ROW
EXECUTE PROCEDURE check_team_member_exists_func();
##

-- 创建触发器函数：检查成员角色是否匹配
CREATE OR REPLACE FUNCTION check_member_role_match_func()
RETURNS TRIGGER AS $$
DECLARE
    org_role VARCHAR(45);
BEGIN
    SELECT role INTO org_role
    FROM indvuser_belong_org
    WHERE account_name = NEW.account_name AND Org_account_name = NEW.Org_name;
    
    IF org_role = 'owner' AND NEW.role != 'Maintainer' THEN
        RAISE EXCEPTION 'Owner must have Maintainer role in the team';
    ELSIF org_role = 'Member' AND NEW.role != 'Member' THEN
        RAISE EXCEPTION 'Member must have Member role in the team';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器：检查成员角色是否匹配
CREATE TRIGGER check_member_role_match
BEFORE INSERT ON indvuser_belong_team
FOR EACH ROW
EXECUTE PROCEDURE check_member_role_match_func();
##

-- 创建触发器函数：检查用户是否存在于个人用户表中
CREATE OR REPLACE FUNCTION check_user_in_individual_users_func()
RETURNS TRIGGER AS $$
DECLARE
    user_count INT;
BEGIN
    SELECT COUNT(*) INTO user_count
    FROM individualuser
    WHERE account_name = NEW.account_name;
    
    IF user_count = 0 THEN
        RAISE EXCEPTION 'User must exist in Individual user table';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器：检查用户是否存在于个人用户表中
CREATE TRIGGER check_user_in_individual_users
BEFORE INSERT ON indvuser_belong_org
FOR EACH ROW
EXECUTE PROCEDURE check_user_in_individual_users_func();
##

-- 创建触发器函数：插入新用户到相应的表中
CREATE OR REPLACE FUNCTION insert_new_user_func()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.type = 'individualuser' THEN
        INSERT INTO individualuser(account_name, name, public_email, bio, URL, x_username, Company, Location, password)
        VALUES(NEW.account_name, NEW.account_name, NEW.email, NULL, NULL, NULL, NULL, NULL, NEW.password);
    ELSIF NEW.type = 'organization' THEN
        INSERT INTO organization(Org_act_name, Contact_email, Profile, Websit, Address, Isverified, password)
        VALUES(NEW.account_name, NEW.email, NULL, NULL, NULL, NULL, NEW.password);
    ELSE
        RAISE EXCEPTION 'Invalid user type';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器：插入新用户到相应的表中
CREATE TRIGGER insert_new_user
AFTER INSERT ON users
FOR EACH ROW
EXECUTE PROCEDURE insert_new_user_func();
##

-- 创建触发器函数：更新用户属性
CREATE OR REPLACE FUNCTION update_user_attributes_func()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.type = 'individualuser' THEN
        UPDATE individualuser SET name = NEW.account_name, public_email = NEW.email, password = NEW.password WHERE account_name = NEW.account_name;
    ELSIF NEW.type = 'organization' THEN
        UPDATE organization SET Contact_email = NEW.email, password = NEW.password WHERE Org_act_name = NEW.account_name;
    ELSE
        RAISE EXCEPTION 'Invalid user type';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器：更新用户属性
CREATE TRIGGER update_user_attributes
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE PROCEDURE update_user_attributes_func();
##

-- 创建触发器函数：更新用户密码前检查旧密码
CREATE OR REPLACE FUNCTION check_password_before_update_func()
RETURNS TRIGGER AS $$
DECLARE
    current_password VARCHAR(145);
BEGIN
    SELECT password INTO current_password
    FROM users
    WHERE account_name = NEW.account_name;
    
    IF current_password != NEW.password THEN
        RAISE EXCEPTION 'Original password does not match';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器：更新用户密码前检查旧密码
CREATE TRIGGER check_password_before_update
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE PROCEDURE check_password_before_update_func();
##

-- 创建触发器函数：删除用户数据
CREATE OR REPLACE FUNCTION delete_user_data_func()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.type = 'individualuser' THEN
        DELETE FROM individualuser WHERE account_name = OLD.account_name;
    ELSIF OLD.type = 'organization' THEN
        DELETE FROM organization WHERE Org_act_name = OLD.account_name;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器：删除用户数据
CREATE TRIGGER delete_user_data
AFTER DELETE ON users
FOR EACH ROW
EXECUTE PROCEDURE delete_user_data_func();
##

-- 创建触发器函数：更新安装记录和账单
CREATE OR REPLACE FUNCTION update_installation_and_bill_func()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE app SET install_num = install_num + 1 WHERE name = NEW.app_name;
    INSERT INTO bill(user_id, app_id, install_time) VALUES(NEW.account_name, NEW.app_name, NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器：更新安装记录和账单
CREATE TRIGGER update_installation_and_bill
AFTER INSERT ON users_install_app
FOR EACH ROW
EXECUTE PROCEDURE update_installation_and_bill_func();
##

-- 创建触发器函数：更新操作星标数量
CREATE OR REPLACE FUNCTION update_action_stars_func()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE action SET Stars_number = Stars_number + 1 WHERE name = NEW.action_name;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器：更新操作星标数量
CREATE TRIGGER update_action_stars
AFTER INSERT ON users_star_action
FOR EACH ROW
EXECUTE PROCEDURE update_action_stars_func();
##

-- 创建触发器函数：更新操作取消星标数量
CREATE OR REPLACE FUNCTION update_action_unstars_func()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE action SET Stars_number = Stars_number - 1 WHERE name = OLD.action_name;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器：更新操作取消星标数量
CREATE TRIGGER update_action_unstars
AFTER DELETE ON users_star_action
FOR EACH ROW
EXECUTE PROCEDURE update_action_unstars_func();
##

-- 创建触发器函数：检查团队中角色唯一性
CREATE OR REPLACE FUNCTION check_unique_role_in_team_func()
RETURNS TRIGGER AS $$
DECLARE
    role_count INT;
BEGIN
    SELECT COUNT(*) INTO role_count
    FROM indvuser_belong_team
    WHERE account_name = NEW.account_name AND team_name = NEW.team_name AND Org_name = NEW.Org_name;
    
    IF role_count > 0 THEN
        RAISE EXCEPTION 'User can only have one role in a team';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器：检查团队中角色唯一性
CREATE TRIGGER check_unique_role_in_team
BEFORE INSERT ON indvuser_belong_team
FOR EACH ROW
EXECUTE PROCEDURE check_unique_role_in_team_func();
##

-- 创建触发器函数：检查团队成员数量限制
CREATE OR REPLACE FUNCTION check_team_member_limit_func()
RETURNS TRIGGER AS $$
DECLARE
    max_members INT;
    current_members INT;
BEGIN
    -- 获取团队的最大成员数
    SELECT max_members INTO max_members
    FROM team
    WHERE team_name = NEW.team_name AND organization_name = NEW.Org_name;
    
    -- 获取团队当前的成员数量
    SELECT COUNT(*) INTO current_members
    FROM indvuser_belong_team
    WHERE team_name = NEW.team_name AND Org_name = NEW.Org_name;
    
    -- 如果当前成员数已达最大成员数，则阻止插入
    IF current_members >= max_members THEN
        RAISE EXCEPTION 'Cannot add more members to this team, the limit has been reached';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器：检查团队成员数量限制
CREATE TRIGGER check_team_member_limit
BEFORE INSERT ON indvuser_belong_team
FOR EACH ROW
EXECUTE PROCEDURE check_team_member_limit_func();
##

-- 创建触发器函数：删除相关用户数据
CREATE OR REPLACE FUNCTION delete_related_user_data_func()
RETURNS TRIGGER AS $$
BEGIN
    -- 删除用户在 indvuser_belong_team 表中的记录
    DELETE FROM indvuser_belong_team WHERE account_name = OLD.account_name;
    
    -- 删除用户在 indvuser_belong_org 表中的记录
    DELETE FROM indvuser_belong_org WHERE account_name = OLD.account_name;
    
    -- 删除用户在 users_star_action 表中的记录
    DELETE FROM users_star_action WHERE account_name = OLD.account_name;
    
    -- 删除用户在 users_install_app 表中的记录
    DELETE FROM users_install_app WHERE account_name = OLD.account_name;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
##

-- 创建触发器：删除相关用户数据
CREATE TRIGGER delete_related_user_data
AFTER DELETE ON users
FOR EACH ROW
EXECUTE PROCEDURE delete_related_user_data_func();
##

-- 创建触发器函数：检查组织中唯一管理员
CREATE OR REPLACE FUNCTION check_unique_admin_in_organization_func()
RETURNS TRIGGER AS $$
DECLARE
    admin_count INT;
BEGIN
    -- 统计该组织中是否已经有团队成员是管理员
    SELECT COUNT(*) INTO admin_count
    FROM indvuser_belong_team tm
    JOIN team t ON tm.team_name = t.team_name AND tm.Org_name = t.organization_name
    WHERE tm.role = 'owner' AND t.organization_name = NEW.Org_name;
    
    IF admin_count > 0 AND NEW.role = 'owner' THEN
        RAISE EXCEPTION 'Each organization can only have one team with an Owner role';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器：检查组织中唯一管理员
CREATE TRIGGER check_unique_admin_in_organization
BEFORE INSERT ON indvuser_belong_team
FOR EACH ROW
EXECUTE PROCEDURE check_unique_admin_in_organization_func();
##

-- 创建触发器函数：递增应用版本号
CREATE OR REPLACE FUNCTION increment_app_version_func()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.version <= OLD.version THEN
        RAISE EXCEPTION 'Version number must be incremented when updating the app';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器：递增应用版本号
CREATE TRIGGER increment_app_version
BEFORE UPDATE ON app
FOR EACH ROW
EXECUTE PROCEDURE increment_app_version_func();
##