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
