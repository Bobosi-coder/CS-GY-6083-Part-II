from flask import Blueprint, request, jsonify, session
from werkzeug.security import generate_password_hash, check_password_hash
import db
import datetime

bp = Blueprint('auth', __name__)

@bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    fname = data.get('fname')
    lname = data.get('lname')
    street = data.get('street')
    city = data.get('city')
    state = data.get('state')
    zipcode = data.get('zipcode')
    cid = data.get('cid')

    if not all([username, password, fname, lname, street, city, state, zipcode, cid]):
        return jsonify({"error": "Missing required fields"}), 400

    db_conn = db.get_db()
    cursor = db_conn.cursor()

    # Check if username already exists in DRY_VIEWER or DRY_ADMIN
    cursor.execute("SELECT USERNAME FROM DRY_VIEWER WHERE USERNAME = %s", (username,))
    if cursor.fetchone():
        return jsonify({"error": "Username already exists"}), 409
    
    cursor.execute("SELECT USERNAME FROM DRY_ADMIN WHERE USERNAME = %s", (username,))
    if cursor.fetchone():
        return jsonify({"error": "Username already exists"}), 409

    # Hash password
    password_hash = generate_password_hash(password, method="pbkdf2:sha256", salt_length=16)

    # Insert new viewer
    try:
        open_date = datetime.date.today().strftime('%Y-%m-%d')
        mcharge = 9.99  # Default monthly charge

        query = """
            INSERT INTO DRY_VIEWER (USERNAME, PASSWORD_HASH, FNAME, LNAME, STREET, CITY, STATE, ZIPCODE, OPEN_DATE, MCHARGE, CID)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(query, (username, password_hash, fname, lname, street, city, state, zipcode, open_date, mcharge, cid))
        db_conn.commit()
        
        # Optionally, log the user in automatically after registration
        user_id = cursor.lastrowid
        session['user_id'] = user_id
        session['role'] = 'viewer'
        session['username'] = username
        session['display_name'] = f"{fname} {lname}"

        return jsonify({
            "message": "Registration successful",
            "user": {
                "user_id": user_id,
                "role": "viewer",
                "username": username,
                "display_name": f"{fname} {lname}"
            }
        }), 201

    except Exception as e:
        db_conn.rollback()
        return jsonify({"error": "Database error during registration", "details": str(e)}), 500
    finally:
        cursor.close()

@bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({"error": "Username and password are required"}), 400

    db_conn = db.get_db()
    cursor = db_conn.cursor(dictionary=True)

    # Try to find user in DRY_ADMIN first
    cursor.execute("SELECT ADMIN_ID, USERNAME, PASSWORD_HASH, FNAME, LNAME FROM DRY_ADMIN WHERE USERNAME = %s", (username,))
    user = cursor.fetchone()
    role = 'admin'

    if not user:
        # If not in admin, try DRY_VIEWER
        cursor.execute("SELECT ACCOUNT, USERNAME, PASSWORD_HASH, FNAME, LNAME FROM DRY_VIEWER WHERE USERNAME = %s", (username,))
        user = cursor.fetchone()
        role = 'viewer'

    if user and check_password_hash(user['PASSWORD_HASH'], password):
        user_id = user.get('ADMIN_ID') or user.get('ACCOUNT')
        display_name = f"{user['FNAME']} {user['LNAME']}"
        
        session.clear()
        session['user_id'] = user_id
        session['role'] = role
        session['username'] = user['USERNAME']
        session['display_name'] = display_name
        
        return jsonify({
            "message": "Login successful",
            "user": {
                "user_id": user_id,
                "role": role,
                "username": user['USERNAME'],
                "display_name": display_name
            }
        }), 200
    
    return jsonify({"error": "Invalid username or password"}), 401


@bp.route('/me', methods=['GET'])
def me():
    if 'user_id' in session:
        return jsonify({
            "logged_in": True,
            "user": {
                "user_id": session['user_id'],
                "role": session['role'],
                "username": session['username'],
                "display_name": session['display_name']
            }
        }), 200
    return jsonify({"logged_in": False}), 401

@bp.route('/logout', methods=['POST'])
def logout():
    session.clear()
    return jsonify({"message": "Logout successful"}), 200
