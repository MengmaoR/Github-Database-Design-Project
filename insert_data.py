import psycopg2
from psycopg2 import sql
from faker import Faker
import random
import string
from datetime import datetime, timedelta
import db_manager

def main():
    # 建立数据库连接
    with open('db_link.txt', 'r', encoding='utf-8') as file:
        db_link = file.readlines()

    db_link = [line.strip() for line in db_link if line.strip()]

    config = ''.join(db_link).split(',')

    # 数据库连接配置
    DB_CONFIG = {
        "database": config[0],
        "user": config[1],
        "password": config[2],
        "host": config[3],
        "port": config[4],
    }

    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()

    db_manager.reinsert(conn, cursor)

    fake = Faker('zh_CN')  # 使用中文环境

    def generate_password():
        """生成至少5位长度的随机密码"""
        chars = string.ascii_letters + string.digits + "!@#$%^&*"
        pwd = "".join(random.choices(chars, k=random.randint(5,12)))
        return pwd

    def random_date(start_year=2020, end_year=2025):
        """生成指定年份范围内的随机日期"""
        start_date = datetime(start_year, 1, 1)
        end_date = datetime(end_year, 12, 31)
        delta = end_date - start_date
        random_days = random.randint(0, delta.days)
        return (start_date + timedelta(days=random_days)).date()

    # 配置插入数量
    NUM_USERS       = 50
    NUM_EVENTS      = 10
    NUM_APPS        = 20
    NUM_ACTIONS     = 15
    NUM_REPOS       = 30
    NUM_TOPICS      = 10
    NUM_COLLECTIONS = 10

    # ---------------------- 插入 users 表 ----------------------
    user_list = []
    for _ in range(NUM_USERS):
        account_name = fake.unique.user_name()[:15]
        email        = fake.unique.email()[:15]
        address      = fake.address().replace('\n', ' ')[:15]
        user_type    = random.choice(['individualuser', 'organization'])
        password     = generate_password()[:15]

        try:
            cursor.execute("""
                INSERT INTO users (account_name, email, address, type, password)
                VALUES (%s, %s, %s, %s, %s)
            """, (account_name, email, address, user_type, password))

            conn.commit()  # 成功后提交
            user_list.append({'account_name': account_name, 'type': user_type})
        except Exception as e:
            conn.rollback()  # 回滚本条插入
            print(f"[ERROR] 插入users失败: {e} -- 跳过此记录。")

    print(f"[INFO] 实际插入成功的 users 数量：{len(user_list)}")

    # 获取individualuser和organization列表
    individual_users = [u['account_name'] for u in user_list if u['type'] == 'individualuser']
    org_users        = [u['account_name'] for u in user_list if u['type'] == 'organization']

    # ---------------------- 插入 indvuser_belong_org ----------------------
    for _ in range(30):
        if not individual_users or not org_users:
            break
        indv = random.choice(individual_users)
        org  = random.choice(org_users)
        role = random.choice(['owner', 'member'])

        try:
            cursor.execute("""
                INSERT INTO indvuser_belong_org (account_name, org_account_name, role)
                VALUES (%s, %s, %s)
                
            """, (indv, org, role))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入indvuser_belong_org失败: {e}")

    print("[INFO] indvuser_belong_org 插入完成。")

    # ---------------------- 插入 team ----------------------
    inserted_teams = []
    for org in org_users:
        team_count = random.randint(1, 5)  # 每个组织1~5个团队
        for _ in range(team_count):
            team_name   = fake.unique.word()[:15]
            visibility  = random.choice(['visible', 'secret'])
            description = fake.text(max_nb_chars=15).replace('\n',' ')

            try:
                cursor.execute("""
                    INSERT INTO team (organization_name, team_name, visibility, description)
                    VALUES (%s, %s, %s, %s)
                """, (org, team_name, visibility, description))
                conn.commit()
                inserted_teams.append({'org_name': org, 'team_name': team_name})
            except Exception as e:
                conn.rollback()
                print(f"[ERROR] 插入team失败: {e}")

    print("[INFO] team 插入完成。")

    # ---------------------- 插入 indvuser_belong_team ----------------------
    for _ in range(100):
        if not inserted_teams or not individual_users:
            break
        team   = random.choice(inserted_teams)
        account= random.choice(individual_users)
        # 确保用户先属于org
        role_org = random.choice(['owner', 'member'])
        try:
            cursor.execute("""
                INSERT INTO indvuser_belong_org (account_name, org_account_name, role)
                VALUES (%s, %s, %s)
                
            """, (account, team['org_name'], role_org))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入indvuser_belong_org(TEAM阶段)失败: {e}")

        role_team = 'maintainer' if role_org == 'owner' else 'member'
        try:
            cursor.execute("""
                INSERT INTO indvuser_belong_team (account_name, org_name, team_name, role)
                VALUES (%s, %s, %s, %s)
                
            """, (account, team['org_name'], team['team_name'], role_team))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入indvuser_belong_team失败: {e}")

    print("[INFO] indvuser_belong_team 插入完成。")

    # ---------------------- 插入 events ----------------------
    for _ in range(NUM_EVENTS):
        ev_name = fake.unique.word()[:15]
        d1      = random_date(2023, 2024)
        d2      = d1 + timedelta(days=random.randint(1,10))
        desc    = fake.text(max_nb_chars=15).replace('\n',' ')

        try:
            cursor.execute("""
                INSERT INTO events (name, date_beginning, date_ending, description)
                VALUES (%s, %s, %s, %s)
            """, (ev_name, d1, d2, desc))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入events失败: {e}")

    print("[INFO] events 插入完成。")

    # ---------------------- 插入 user_join_events ----------------------
    for _ in range(NUM_EVENTS * 2):
        cursor.execute("SELECT name, date_beginning FROM events ORDER BY random() LIMIT 1;")
        row = cursor.fetchone()
        if not row: break
        ev_name, ev_begin = row
        user_choice = random.choice(user_list)['account_name']

        try:
            cursor.execute("""
                INSERT INTO user_join_events (account_name, event_name, date_beginning)
                VALUES (%s, %s, %s)
                
            """, (user_choice, ev_name, ev_begin))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入user_join_events失败: {e}")

    print("[INFO] user_join_events 插入完成。")

    # ---------------------- 插入 app ----------------------
    app_names = []
    for _ in range(NUM_APPS):
        app_name     = fake.unique.word()[:15]
        intro        = fake.text(max_nb_chars=15).replace('\n',' ')
        langs        = ','.join(fake.words(nb=2))[:15]
        price        = random.randint(0, 500)
        install_num  = random.randint(0, 10000)

        try:
            cursor.execute("""
                INSERT INTO app (name, introduction, languages, price, install_num)
                VALUES (%s, %s, %s, %s, %s)
            """, (app_name, intro, langs, price, install_num))
            conn.commit()
            app_names.append(app_name)
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入app失败: {e}")

    print(f"[INFO] app 实际插入成功数量：{len(app_names)}")

    # ---------------------- 插入 action ----------------------
    action_ids = []
    for _ in range(NUM_ACTIONS):
        act_name     = random.randint(1000, 999999)
        stars_number = random.randint(0, 2000)
        version      = f"{random.randint(0,10)}.{random.randint(0,10)}.{random.randint(0,10)}"
        money        = random.randint(0, 1000)

        try:
            cursor.execute("""
                INSERT INTO action (name, stars_number, version, money)
                VALUES (%s, %s, %s, %s)
            """, (act_name, stars_number, version, money))
            conn.commit()
            action_ids.append(act_name)
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入action失败: {e}")

    print(f"[INFO] action 实际插入成功数量：{len(action_ids)}")

    # ---------------------- 插入 users_install_app ----------------------
    for _ in range(NUM_APPS * 2):
        if not user_list or not app_names:
            break
        user_acc = random.choice(user_list)['account_name']
        app_name = random.choice(app_names)
        dt       = random_date(2021, 2024)

        try:
            cursor.execute("""
                INSERT INTO users_install_app (account_name, app_name, date)
                VALUES (%s, %s, %s)
                
            """, (user_acc, app_name, dt))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入users_install_app失败: {e}")

    print("[INFO] users_install_app 插入完成。")

    # ---------------------- 插入 users_install_action ----------------------
    for _ in range(NUM_ACTIONS * 2):
        if not user_list or not action_ids:
            break
        user_acc = random.choice(user_list)['account_name']
        act_name = random.choice(action_ids)
        dt       = random_date(2021, 2024)

        try:
            cursor.execute("""
                INSERT INTO users_install_action (account_name, action_name, date)
                VALUES (%s, %s, %s)
                
            """, (user_acc, str(act_name), dt))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入users_install_action失败: {e}")

    print("[INFO] users_install_action 插入完成。")

    # ---------------------- 插入 org_develop_app ----------------------
    for _ in range(NUM_APPS):
        if not org_users or not app_names:
            break
        org_acc  = random.choice(org_users)
        app_name = random.choice(app_names)

        try:
            cursor.execute("""
                INSERT INTO org_develop_app (account_name, app_name)
                VALUES (%s, %s)
                
            """, (org_acc, app_name))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入org_develop_app失败: {e}")

    print("[INFO] org_develop_app 插入完成。")

    # ---------------------- 插入 user_contribute_action ----------------------
    for _ in range(NUM_ACTIONS):
        if not individual_users or not action_ids:
            break
        u   = random.choice(individual_users)
        act = random.choice(action_ids)

        try:
            cursor.execute("""
                INSERT INTO user_contribute_action (account_name, action_name)
                VALUES (%s, %s)
                
            """, (u, str(act)))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入user_contribute_action失败: {e}")

    print("[INFO] user_contribute_action 插入完成。")

    # ---------------------- 插入关注/Star关系 (user1_follow_user2, user1_star_user2) ----------------------
    for _ in range(60):
        u1 = random.choice(user_list)['account_name']
        u2 = random.choice(user_list)['account_name']
        if u1 == u2:
            continue
        dt = random_date(2021, 2024)

        try:
            cursor.execute("""
                INSERT INTO user1_follow_user2 (user1, user2, date)
                VALUES (%s, %s, %s)
                
            """, (u1, u2, dt))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] user1_follow_user2插入失败: {e}")

    for _ in range(60):
        u1 = random.choice(user_list)['account_name']
        u2 = random.choice(user_list)['account_name']
        if u1 == u2:
            continue
        dt = random_date(2021, 2024)

        try:
            cursor.execute("""
                INSERT INTO user1_star_user2 (user1, user2, date)
                VALUES (%s, %s, %s)
                
            """, (u1, u2, dt))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] user1_star_user2插入失败: {e}")

    print("[INFO] 关注/Star 用户关系 插入完成。")

    # ---------------------- 插入 repositories ----------------------
    repo_list = []
    for _ in range(NUM_REPOS):
        repo_name  = fake.unique.word()[:15]
        owner      = random.choice(user_list)['account_name']
        desc       = fake.text(max_nb_chars=15).replace('\n',' ')
        pub_priv   = random.choice([0, 1])
        updated_on = random_date(2021, 2024)
        star_num   = random.randint(0, 1000)
        watch_num  = random.randint(0, 500)
        fork_num   = random.randint(0, 200)

        try:
            cursor.execute("""
                INSERT INTO repositories (repository_name, owner, description, public_or_private,
                                          updated_on, star_number, watch_number, fork_number)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, (repo_name, owner, desc, pub_priv, updated_on, star_num, watch_num, fork_num))
            conn.commit()
            repo_list.append((repo_name, owner))
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入repositories失败: {e}")

    print(f"[INFO] repositories 插入成功数量：{len(repo_list)}")

    # ---------------------- 插入 topic ----------------------
    topic_list = []
    for _ in range(NUM_TOPICS):
        t_name      = fake.unique.word()[:15]
        description = fake.text(max_nb_chars=35).replace('\n',' ')

        try:
            cursor.execute("""
                INSERT INTO topic (topic_name, description, repositories_num)
                VALUES (%s, %s, %s)
            """, (t_name, description, 0))
            conn.commit()
            topic_list.append(t_name)
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入topic失败: {e}")

    print(f"[INFO] topic 插入成功数量：{len(topic_list)}")

    # ---------------------- 插入 repositories_match_topic ----------------------
    for _ in range(NUM_REPOS * 2):
        if not repo_list or not topic_list:
            break
        r = random.choice(repo_list)
        t = random.choice(topic_list)
        try:
            cursor.execute("""
                INSERT INTO repositories_match_topic (repository_name, owner, topic_name)
                VALUES (%s, %s, %s)
                
            """, (r[0], r[1], t))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入repositories_match_topic失败: {e}")

    print("[INFO] repositories_match_topic 插入完成。")

    # ---------------------- 插入 collections ----------------------
    collections_list = []
    for _ in range(NUM_COLLECTIONS):
        c_name = fake.unique.word()[:15]
        desc   = fake.text(max_nb_chars=35).replace('\n',' ')

        try:
            cursor.execute("""
                INSERT INTO collections (collection_name, description, repositories_num)
                VALUES (%s, %s, %s)
            """, (c_name, desc, 0))
            conn.commit()
            collections_list.append(c_name)
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入collections失败: {e}")

    print(f"[INFO] collections 插入成功数量：{len(collections_list)}")

    # ---------------------- 插入 repositories_match_collections ----------------------
    for _ in range(NUM_REPOS * 2):
        if not repo_list or not collections_list:
            break
        r = random.choice(repo_list)
        c = random.choice(collections_list)

        try:
            cursor.execute("""
                INSERT INTO repositories_match_collections (repository_name, owner, collection_name)
                VALUES (%s, %s, %s)
                
            """, (r[0], r[1], c))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入repositories_match_collections失败: {e}")

    print("[INFO] repositories_match_collections 插入完成。")

    # ---------------------- 插入 releases ----------------------
    for _ in range(NUM_REPOS * 2):
        if not repo_list:
            break
        r = random.choice(repo_list)
        tag       = "v"+str(random.randint(1,10))+"."+str(random.randint(0,20))
        rel_date  = random_date(2021, 2024)
        publisher = random.choice(user_list)['account_name']
        dl_url    = random.choice(['http://','https://']) + fake.domain_name()

        try:
            cursor.execute("""
                INSERT INTO releases (repository_name, owner, tag, release_date, publisher, download_url)
                VALUES (%s, %s, %s, %s, %s, %s)
                
            """, (r[0], r[1], tag, rel_date, publisher, dl_url))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入releases失败: {e}")

    print("[INFO] releases 插入完成。")

    # ---------------------- 插入 packages ----------------------
    package_types = ['docker', 'apache maven', 'nuget', 'rubygems', 'npm', 'containers']
    for _ in range(NUM_REPOS * 2):
        if not repo_list:
            break
        r = random.choice(repo_list)
        pkg_name  = fake.unique.word()[:15]
        pkg_type  = random.choice(package_types)
        rel_date  = random_date(2021, 2024)

        try:
            cursor.execute("""
                INSERT INTO packages (repository_name, owner, packages_name, type, release_date)
                VALUES (%s, %s, %s, %s, %s)
                
            """, (r[0], r[1], pkg_name, pkg_type, rel_date))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入packages失败: {e}")

    print("[INFO] packages 插入完成。")

    # ---------------------- 插入 code ----------------------
    for (repo_name, repo_owner) in repo_list:
        commit_num   = random.randint(0, 500)
        branch_num   = random.randint(1, 50)
        tags_num     = random.randint(0, 50)
        last_update  = random_date(2021, 2024)

        try:
            cursor.execute("""
                INSERT INTO code (repository_name, owner, commit_num, branch_num, tags_num, last_update)
                VALUES (%s, %s, %s, %s, %s, %s)
                
            """, (repo_name, repo_owner, commit_num, branch_num, tags_num, last_update))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入code失败: {e}")

    print("[INFO] code 插入完成。")

    # ---------------------- 插入 issues ----------------------
    for _ in range(NUM_REPOS * 2):
        if not repo_list or not user_list:
            break
        r = random.choice(repo_list)
        issue_num = random.randint(1,9999)
        acc       = random.choice(user_list)['account_name']
        comment   = fake.text(max_nb_chars=15).replace('\n',' ')
        dt        = random_date(2021, 2024)
        o_c       = random.choice([0,1])

        try:
            cursor.execute("""
                INSERT INTO issues (repository_name, owner, number, account_name, comment, date, open_or_close)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                
            """, (r[0], r[1], issue_num, acc, comment, dt, o_c))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入issues失败: {e}")

    print("[INFO] issues 插入完成。")

    # ---------------------- 插入 pull_requests ----------------------
    for _ in range(NUM_REPOS * 2):
        if not repo_list:
            break
        r = random.choice(repo_list)
        pr_num   = random.randint(1,9999)
        comment  = fake.sentence(nb_words=3)
        dt       = random_date(2021, 2024)
        o_c      = random.choice([0,1])

        try:
            cursor.execute("""
                INSERT INTO pull_requests (repository_name, owner, number, comment, date, open_or_close)
                VALUES (%s, %s, %s, %s, %s, %s)
                
            """, (r[0], r[1], pr_num, comment, dt, o_c))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入pull_requests失败: {e}")

    print("[INFO] pull_requests 插入完成。")

    # ---------------------- 插入 user_view/fork/star/watch_repositories ----------------------
    for _ in range(200):
        user_acc = random.choice(user_list)['account_name']
        r        = random.choice(repo_list)
        dt       = random_date(2021, 2024)

        # user_view_repositories
        try:
            cursor.execute("""
                INSERT INTO user_view_repositories (owner, repository_name, account_name, date)
                VALUES (%s, %s, %s, %s)
                
            """, (r[1], r[0], user_acc, dt))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入user_view_repositories失败: {e}")

        # user_fork_repositories
        if random.random() < 0.5:
            try:
                cursor.execute("""
                    INSERT INTO user_fork_repositories (owner, repository_name, account_name, date)
                    VALUES (%s, %s, %s, %s)
                    
                """, (r[1], r[0], user_acc, dt))
                conn.commit()
            except Exception as e:
                conn.rollback()
                print(f"[ERROR] 插入user_fork_repositories失败: {e}")

        # user_star_repositories
        if random.random() < 0.5:
            try:
                cursor.execute("""
                    INSERT INTO user_star_repositories (owner, repository_name, account_name, date)
                    VALUES (%s, %s, %s, %s)
                    
                """, (r[1], r[0], user_acc, dt))
                conn.commit()
            except Exception as e:
                conn.rollback()
                print(f"[ERROR] 插入user_star_repositories失败: {e}")

        # user_watch_repositories
        if random.random() < 0.5:
            try:
                cursor.execute("""
                    INSERT INTO user_watch_repositories (owner, repository_name, account_name, date)
                    VALUES (%s, %s, %s, %s)
                    
                """, (r[1], r[0], user_acc, dt))
                conn.commit()
            except Exception as e:
                conn.rollback()
                print(f"[ERROR] 插入user_watch_repositories失败: {e}")

    print("[INFO] user_view/fork/star/watch_repositories 插入完成。")

    # ---------------------- 插入 user_develop_repositories ----------------------
    for _ in range(50):
        user_acc = random.choice(user_list)['account_name']
        r        = random.choice(repo_list)
        role     = random.choice(['owner','member'])

        try:
            cursor.execute("""
                INSERT INTO user_develop_repositories (owner, repository_name, account_name, role)
                VALUES (%s, %s, %s, %s)
                
            """, (r[1], r[0], user_acc, role))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入user_develop_repositories失败: {e}")

    print("[INFO] user_develop_repositories 插入完成。")

    # ---------------------- 插入 user_respond_issue_repositories ----------------------
    cursor.execute("SELECT repository_name, owner, number FROM issues;")
    issues_all = cursor.fetchall()
    for _ in range(50):
        if not issues_all:
            break
        isel        = random.choice(issues_all)
        account_name= random.choice(user_list)['account_name']
        dt          = random_date(2021, 2024)
        resp        = fake.sentence(nb_words=5)

        try:
            cursor.execute("""
                INSERT INTO user_respond_issue_repositories (owner, repository_name, account_name, number, date, response)
                VALUES (%s, %s, %s, %s, %s, %s)
                
            """, (isel[1], isel[0], account_name, isel[2], dt, resp))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入user_respond_issue_repositories失败: {e}")

    print("[INFO] user_respond_issue_repositories 插入完成。")

    # ---------------------- 插入 user_fileschangedin_repositories ----------------------
    cursor.execute("SELECT repository_name, owner, number FROM pull_requests;")
    prs_all = cursor.fetchall()
    for _ in range(50):
        if not prs_all:
            break
        psel = random.choice(prs_all)
        user_acc = random.choice(user_list)['account_name']
        changed_files        = fake.word()[:15]
        changed_line_content = fake.sentence(nb_words=6)[:115]
        changed_line_num     = str(random.randint(1,500))

        try:
            cursor.execute("""
                INSERT INTO user_fileschangedin_repositories 
                (owner, repository_name, account_name, number, files, changed_line_content, changed_line_num)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                
            """, (psel[1], psel[0], user_acc, psel[2], changed_files, changed_line_content, changed_line_num))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入user_fileschangedin_repositories失败: {e}")

    print("[INFO] user_fileschangedin_repositories 插入完成。")

    # ---------------------- 插入 users_star_topic ----------------------
    for _ in range(NUM_TOPICS * 5):
        if not topic_list or not user_list:
            break
        user_acc = random.choice(user_list)['account_name']
        tname    = random.choice(topic_list)
        dt       = random_date(2021, 2024)

        try:
            cursor.execute("""
                INSERT INTO users_star_topic (account_name, topic_name, date)
                VALUES (%s, %s, %s)
                
            """, (user_acc, tname, dt))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入users_star_topic失败: {e}")

    print("[INFO] users_star_topic 插入完成。")

    # ---------------------- 插入 users_star_collections ----------------------
    for _ in range(NUM_COLLECTIONS * 5):
        if not collections_list or not user_list:
            break
        user_acc = random.choice(user_list)['account_name']
        cname    = random.choice(collections_list)
        dt       = random_date(2021, 2024)

        try:
            cursor.execute("""
                INSERT INTO users_star_collections (account_name, collections_name, date)
                VALUES (%s, %s, %s)
                
            """, (user_acc, cname, dt))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入users_star_collections失败: {e}")

    print("[INFO] users_star_collections 插入完成。")

    # ---------------------- 插入 users_star_action ----------------------
    for _ in range(NUM_ACTIONS * 2):
        if not action_ids or not user_list:
            break
        user_acc = random.choice(user_list)['account_name']
        act      = random.choice(action_ids)
        dt       = random_date(2021, 2024)

        try:
            cursor.execute("""
                INSERT INTO users_star_action (account_name, action_name, date)
                VALUES (%s, %s, %s)
                
            """, (user_acc, str(act), dt))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入users_star_action失败: {e}")

    print("[INFO] users_star_action 插入完成。")

    # ---------------------- 插入 popular_repositories ----------------------
    languages = ['Python','Java','C++','Go','JavaScript']
    for _ in range(NUM_REPOS):
        if not repo_list:
            break
        r = random.choice(repo_list)
        lang       = random.choice(languages)
        date_range = random.choice(['2024-Q1','2024-Q2','2024-Q3','2024-Q4'])

        try:
            cursor.execute("""
                INSERT INTO popular_repositories (owner, repository_name, language, date_range)
                VALUES (%s, %s, %s, %s)
                
            """, (r[1], r[0], lang, date_range))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入popular_repositories失败: {e}")

    print("[INFO] popular_repositories 插入完成。")

    # ---------------------- 插入 popular_users ----------------------
    date_ranges = ['2024-Q1','2024-Q2','2024-Q3','2024-Q4']
    for _ in range(NUM_USERS):
        u = random.choice(user_list)['account_name']
        d = random.choice(date_ranges)

        try:
            cursor.execute("""
                INSERT INTO popular_users (account_name, date_range)
                VALUES (%s, %s)
                
            """, (u, d))
            conn.commit()
        except Exception as e:
            conn.rollback()
            print(f"[ERROR] 插入popular_users失败: {e}")

    print("[INFO] popular_users 插入完成。")

    print("[INFO] 全部数据插入结束。")

    cursor.close()
    conn.close()

if __name__ == "__main__":
    main()