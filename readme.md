# Github-Database-Design-Project

## Project Introduction
This project is based on the basic data of the Github website and designs a database to store information about users, repositories, code, issues, comments, etc. on the Github website. The project includes database design documents, database creation scripts, database generation scripts, database management scripts, and database interaction scripts.

## Database Connection
To connect the project scripts to your database, you need to create a db_link.txt file in the main directory and write your database configuration information in the following format:
``` ./db_link.txt
your_database,
your_user,
your_password,
your_host,
your_port
```

## Database Management
Run the ./db_manage.py script to manage the database structure, including creating and deleting tables, views, and triggers.
``` shell
python3 db_manage.py
```

## Random Data Generation
Run the ./db_generate.py script to randomly generate data based on the faker library and insert it into the database. The data covers all tables and views and can meet all table-level constraints. However, due to the presence of triggers, constraint conflicts may occur when inserting data, in which case the data insertion will be skipped.
``` shell
python3 db_generate.py
```

## Database Interaction
Run the ./web/app.py script to start a simple web application for interacting with the database. The web page will run on the local port 5000. The web page allows input of SQL statements for querying and can interact with generative AI to assist users in writing SQL statements.
``` shell
python3 web/app.py
```

## Authors
- MengmaoR
- lifang535
- iPhone38