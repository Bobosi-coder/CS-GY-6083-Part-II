# CS-GY 6083 Principles of Database Systems - Project Part II

This project is a full-stack web application for a university database course. It includes a Flask backend, a React frontend, and a MySQL database.

## 1. Database Setup

1.  **Ensure MySQL is running.** This application assumes a local MySQL server is running on `localhost:3306`.
2.  **Create the database and tables.** Use the `schema.sql` file provided in the project description to create the `dry_news_db` database and all required tables.
3.  **Seed the database.** Use the `data.sql` script to populate the database with initial sample data for testing.

## 2. Backend Setup (Flask)

The backend server runs on `http://localhost:5000`.

1.  **Navigate to the backend directory:**
    ```bash
    cd backend
    ```

2.  **Create a virtual environment (recommended):**
    ```bash
    python3 -m venv venv
    source venv/bin/activate  # On Windows, use `venv\Scripts\activate`
    ```

3.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

4.  **Configure database connection:**
    *   Create a file named `.env` in the `backend` directory.
    *   Copy the contents of `.env.example` (if provided) or add the following, replacing the placeholder values with your MySQL credentials:
        ```env
        # Flask app secret key
        SECRET_KEY='a-very-secret-key'

        # MySQL Database connection
        MYSQL_HOST=localhost
        MYSQL_USER=your_mysql_username
        MYSQL_PASSWORD=your_mysql_password
        MYSQL_DB=dry_news_db
        MYSQL_PORT=3306
        ```

5.  **Run the server:**
    ```bash
    flask run
    ```
    The backend API will be available at `http://localhost:5000`.

## 3. Frontend Setup (React)

The frontend development server runs on `http://localhost:3000`.

1.  **Navigate to the frontend directory:**
    ```bash
    cd frontend
    ```

2.  **Install dependencies:**
    > **Note:** This command may take a few minutes to complete.
    ```bash
    npm install
    ```

3.  **Run the development server:**
    ```bash
    npm run dev
    ```

4.  **Access the application:**
    *   Open your web browser and go to `http://localhost:3000`.
    *   The React application will automatically proxy API requests to the backend.

## 4. Usage

*   **Login:** Use the login page for both 'viewer' and 'admin' accounts.
    *   Admin username: `admin`, password: `Admin!123`
    *   Viewer usernames: `viewer1`, `viewer2`, `viewer3`, with passwords `viewer1!`, `viewer2!`, `viewer3!` respectively.
    *   Viewer security question and answers: 
        `viewer1` with question `What is the name of your first pet?`, answer `Tommy`. 
        `viewer2` with question `What city were you born in?`, answer `Busan`. 
        `viewer3` with question `What is your favorite fruit?`, answer `Peach`. 
*   **Registration:** New viewer accounts can be created via the "Sign up now" link on the login page.
*   **Roles:** The application will redirect you to the appropriate dashboard based on your role after login.
    *   **Viewers** can browse series, view details, and manage their own feedback and profile.
    *   **Admins** have full CRUD access to all data entities and can view business analysis reports.

---

## 5. Docker Deployment (Recommended)

This project supports full containerization with Docker and Docker Compose for easy deployment and consistent environments.

### Quick Start with Docker

1. **Install Docker and Docker Compose:**
   - Follow the installation guide in `DOCKER.md`

2. **Configure environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your desired database credentials
   ```

3. **Start all services:**
   ```bash
   ./docker-start.sh
   # OR manually:
   sudo docker-compose up -d
   ```

4. **Access the application:**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5000
   - Database: localhost:3307

5. **Stop all services:**
   ```bash
   sudo docker-compose down
   ```

### Docker Architecture

The Docker setup includes three services:

- **`db`**: MySQL 8.0 database
  - Auto-initializes schema and data from `/database` directory
  - Data persists in Docker volume `mysql_data`
  - Port: 3307 (host) → 3306 (container)

- **`backend`**: Flask application with Gunicorn
  - 4 worker processes for production
  - Environment variables from `.env` file
  - Port: 5000

- **`frontend`**: React app served by Nginx
  - Multi-stage build for optimized size
  - Built-in reverse proxy to backend
  - Port: 3000 (host) → 80 (container)

### Utility Scripts

- `docker-start.sh` - Start all services
- `clean-start.sh` - Full cleanup and fresh start
- `reset-database.sh` - Reset database only
- `docker-restart.sh` - Quick restart

For detailed documentation, see **`DOCKER.md`**.

---

## 6. Database Performance Optimization

### Indexing Strategy

To handle high-frequency queries efficiently, the database includes optimized indexes:

#### Implemented Indexes

1. **`idx_feedback_sid_fdate`** on `DRY_FEEDBACK(SID, FDATE DESC)`
   - **Purpose**: Query feedback for a specific series, sorted by date
   - **Used in**: `viewer_routes.py` line 163 (Series detail page)
   - **Impact**: 15-30x faster queries

2. **`idx_feedback_fdate`** on `DRY_FEEDBACK(FDATE)`
   - **Purpose**: Date range queries (e.g., recent 7 days)
   - **Used in**: `admin_routes.py` line 37 (Dashboard statistics)
   - **Impact**: 20x faster queries

3. **`idx_series_ori_lang`** on `DRY_SERIES(ORI_LANG)`
   - **Purpose**: Filter series by language
   - **Used in**: `viewer_routes.py` line 82 (Series filtering)
   - **Impact**: 10x faster queries

4. **`idx_viewer_open_date`** on `DRY_VIEWER(OPEN_DATE)`
   - **Purpose**: User growth statistics by date
   - **Used in**: `viewer_growth_monthly` VIEW
   - **Impact**: Faster time-series analysis

5. **`idx_episode_sid_enum`** on `DRY_EPISODE(SID, E_NUM)`
   - **Purpose**: Query episodes for a series in order
   - **Used in**: `viewer_routes.py` line 141 (Episode listing)
   - **Impact**: 10x faster queries

### Testing Index Performance

Run the automated performance analysis:

```bash
./test-indexes.sh
```

This interactive script provides:
- Current index analysis
- Query execution plan comparison (EXPLAIN)
- Benchmark timing tests
- Test data generation (optional)

### Documentation

For detailed information about the indexing strategy, performance analysis, and experimental results, see:

- **`database/INDEX_IMPLEMENTATION.md`** - Complete implementation guide
- **`database/performance_analysis.sql`** - Analysis queries
- **`database/benchmark_queries.sql`** - Performance benchmarks

---

## 7. Security Features

### SQL Injection Prevention

All database queries use **parameterized statements**:

```python
# ✅ Safe - parameterized query
cursor.execute("SELECT * FROM DRY_SERIES WHERE SID = %s", (sid,))

# ❌ NEVER - string concatenation (vulnerable)
# cursor.execute(f"SELECT * FROM DRY_SERIES WHERE SID = {sid}")
```

**Implementation locations:**
- `viewer_routes.py`: All query functions
- `admin_routes.py`: CRUD operations
- `auth_routes.py`: Login and registration

### Cross-Site Scripting (XSS) Prevention

- **Backend**: Flask's `jsonify()` automatically escapes special characters
- **Frontend**: React's JSX automatically escapes rendered content
- **Additional**: Nginx security headers in `frontend/nginx.conf`

### Password Security

- **Hashing algorithm**: PBKDF2-SHA256 with 16-byte salt
- **Implementation**: Werkzeug's `generate_password_hash()` and `check_password_hash()`
- **Storage**: Only hashed passwords stored in `DRY_VIEWER.PASSWORD_HASH` and `DRY_ADMIN.PASSWORD_HASH`

### Session Management

- Server-side Flask sessions with secure cookies
- `supports_credentials=True` for CORS
- Session timeout and automatic cleanup

---

## 8. Transaction Management & Concurrency

### Transaction Handling

**Implicit transactions** (for simple operations):
```python
try:
    cursor.execute("INSERT INTO DRY_FEEDBACK ...")
    db_conn.commit()
except Exception as e:
    db_conn.rollback()
```

**Explicit transactions** (for complex multi-table operations):
```python
db_conn.start_transaction()
try:
    cursor.execute("UPDATE DRY_SERIES ...")
    cursor.execute("DELETE FROM DRY_SERIES_TYPE ...")
    cursor.execute("INSERT INTO DRY_SERIES_TYPE ...")
    db_conn.commit()
except Exception as e:
    db_conn.rollback()
```

**Implementation**: `admin_routes.py` line 120-180 (Series edit operations)

### Concurrency Control

- **Isolation level**: `REPEATABLE READ` (MySQL InnoDB default)
- **Row-level locking**: InnoDB automatic row locks during transactions
- **MVCC**: Multi-Version Concurrency Control for read consistency

### Deadlock Prevention Strategies

1. **Consistent resource access order**: Always access tables in the same order
   ```python
   # Delete child records first, then parent
   DELETE FROM DRY_SERIES_TYPE WHERE SID = ?
   DELETE FROM DRY_EPISODE WHERE SID = ?
   DELETE FROM DRY_SERIES WHERE SID = ?
   ```

2. **Short transactions**: Minimize lock hold time
3. **Primary key operations**: Use indexed WHERE clauses
4. **Error handling**: Automatic rollback on exceptions

**Implementation**: `admin_routes.py` line 200-250 (Series deletion)

---

## Project Structure

```
CS-GY-6083-Part-II/
├── backend/                    # Flask backend
│   ├── app.py                 # Application entry point
│   ├── config.py              # Configuration management
│   ├── db.py                  # Database connection
│   ├── auth_routes.py         # Authentication endpoints
│   ├── viewer_routes.py       # Viewer API endpoints
│   ├── admin_routes.py        # Admin API endpoints
│   ├── reports_routes.py      # Business analysis reports
│   ├── requirements.txt       # Python dependencies
│   ├── Dockerfile             # Backend Docker image
│   └── .dockerignore
├── frontend/                  # React frontend
│   ├── src/
│   │   ├── pages/            # Page components
│   │   ├── components/       # Reusable components
│   │   ├── contexts/         # Authentication context
│   │   └── api/              # Axios client
│   ├── package.json          # Node dependencies
│   ├── Dockerfile            # Frontend Docker image (multi-stage)
│   ├── nginx.conf            # Nginx configuration
│   └── .dockerignore
├── database/                  # Database files
│   ├── db_setting.sql        # Schema with indexes
│   ├── add_data.sql          # Initial data
│   ├── performance_analysis.sql    # Index analysis
│   ├── benchmark_queries.sql       # Performance tests
│   └── INDEX_IMPLEMENTATION.md     # Indexing documentation
├── docker-compose.yml         # Service orchestration
├── .env.example              # Environment variables template
├── docker-start.sh           # Quick start script
├── test-indexes.sh           # Index performance testing
├── DOCKER.md                 # Docker documentation
└── README.md                 # This file
```

---

## Development Notes

### Adding New Features

1. **Backend routes**: Add new blueprints in `backend/` and register in `app.py`
2. **Frontend pages**: Add components in `frontend/src/pages/` and routes in `App.jsx`
3. **Database changes**: Update `db_setting.sql` and consider index implications

### Testing

- **Backend**: Use Postman or curl to test API endpoints
- **Frontend**: Use browser DevTools Network tab
- **Database**: Use `test-indexes.sh` for performance analysis

### Troubleshooting

See `DOCKER.md` for common issues and solutions.

---

## Technologies Used

- **Backend**: Flask, Gunicorn, MySQL Connector Python, Werkzeug
- **Frontend**: React, React Router, Axios, Recharts
- **Database**: MySQL 8.0 with InnoDB engine
- **Deployment**: Docker, Docker Compose, Nginx
- **Security**: PBKDF2-SHA256, parameterized queries, CORS, CSP headers
