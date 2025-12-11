from flask import Blueprint, request, jsonify, session
from werkzeug.security import generate_password_hash, check_password_hash
from functools import wraps
import db

bp = Blueprint('viewer', __name__)

# Decorator to protect routes for logged-in viewers
def viewer_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'role' not in session or session['role'] != 'viewer':
            return jsonify({"error": "Access denied. Viewer role required."}), 403
        return f(*args, **kwargs)
    return decorated_function

@bp.route('/recommendations', methods=['GET'])
@viewer_required
def get_recommendations():
    try:
        db_conn = db.get_db()
        cursor = db_conn.cursor(dictionary=True)
        
        # 调用存储过程（而不是直接SQL查询）
        cursor.callproc('GetTopSeriesByRating', [5])
        
        # 获取存储过程的结果
        recommendations = []
        for result in cursor.stored_results():
            recommendations = result.fetchall()
        
        return jsonify(recommendations)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()

@bp.route('/series', methods=['GET'])
@viewer_required
def get_series_list():
    """Returns a list of all series with optional filters."""
    # Extract query parameters
    genre = request.args.get('genre')
    language = request.args.get('language')
    country_id = request.args.get('country')

    try:
        db_conn = db.get_db()
        cursor = db_conn.cursor(dictionary=True)

        # Base query
        query = """
            SELECT
                s.SID,
                s.SNAME,
                s.NEPISODES,
                s.ORI_LANG,
                GROUP_CONCAT(DISTINCT st.TNAME ORDER BY st.TNAME SEPARATOR ', ') AS genres,
                COALESCE(
                    CONCAT('[', GROUP_CONCAT(DISTINCT JSON_OBJECT('CID', c.CID, 'CNAME', c.CNAME) ORDER BY c.CNAME SEPARATOR ','), ']'),
                    '[]'
                ) AS countries,
                AVG(f.RATE) AS avg_rating,
                COUNT(DISTINCT f.ACCOUNT) AS feedback_count
            FROM
                DRY_SERIES s
            LEFT JOIN DRY_SERIES_TYPE st ON s.SID = st.SID
            LEFT JOIN DRY_FEEDBACK f ON s.SID = f.SID
            LEFT JOIN DRY_SERIES_RELEASE_COUNTRY src ON s.SID = src.SID
            LEFT JOIN DRY_COUNTRY c ON src.CID = c.CID
        """
        
        # Conditions and parameters for filtering
        conditions = []
        params = []

        if genre:
            conditions.append("s.SID IN (SELECT SID FROM DRY_SERIES_TYPE WHERE TNAME = %s)")
            params.append(genre)
        
        if language:
            conditions.append("s.ORI_LANG = %s")
            params.append(language)
            
        if country_id:
            conditions.append("src.CID = %s")
            params.append(country_id)

        if conditions:
            query += " WHERE " + " AND ".join(conditions)

        query += " GROUP BY s.SID ORDER BY s.SNAME;"

        cursor.execute(query, tuple(params))
        series_list = cursor.fetchall()
        return jsonify(series_list)

    except Exception as e:
        return jsonify({"error": "Database query failed", "details": str(e)}), 500
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()

@bp.route('/series/<int:sid>', methods=['GET'])
@viewer_required
def get_series_detail(sid):
    # This endpoint can be quite large, combining multiple queries might be better for performance
    # but for simplicity, we do it in separate queries.
    try:
        db_conn = db.get_db()
        cursor = db_conn.cursor(dictionary=True)
        
        # 1. Series base info
        cursor.execute("SELECT * FROM DRY_SERIES WHERE SID = %s", (sid,))
        series_info = cursor.fetchone()
        if not series_info:
            return jsonify({"error": "Series not found"}), 404

        # 2. Genres
        cursor.execute("SELECT TNAME FROM DRY_SERIES_TYPE WHERE SID = %s", (sid,))
        series_info['genres'] = [row['TNAME'] for row in cursor.fetchall()]

        # 3. Subtitle Languages
        cursor.execute("SELECT LNAME FROM DRY_SERIES_SUBTITLE WHERE SID = %s", (sid,))
        series_info['subtitles'] = [row['LNAME'] for row in cursor.fetchall()]

        # 4. Dubbing Languages
        cursor.execute("SELECT LNAME FROM DRY_SERIES_DUBBING WHERE SID = %s", (sid,))
        series_info['dubbings'] = [row['LNAME'] for row in cursor.fetchall()]

        # 5. Release Countries
        cursor.execute("""
            SELECT c.CNAME, src.RELEASE_DATE
            FROM DRY_SERIES_RELEASE_COUNTRY src
            JOIN DRY_COUNTRY c ON src.CID = c.CID
            WHERE src.SID = %s
        """, (sid,))
        series_info['release_countries'] = cursor.fetchall()
        
        # 6. Episodes
        cursor.execute("SELECT EID, E_NUM, SCHEDULE_SDATE, SCHEDULE_EDATE, NVIEWERS, INTERRUPTION FROM DRY_EPISODE WHERE SID = %s ORDER BY E_NUM", (sid,))
        series_info['episodes'] = cursor.fetchall()

        return jsonify(series_info)
        
    except Exception as e:
        return jsonify({"error": "Database query failed", "details": str(e)}), 500
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()


@bp.route('/series/<int:sid>/feedback', methods=['GET', 'POST', 'DELETE'])
@viewer_required
def handle_feedback(sid):
    db_conn = db.get_db()
    cursor = db_conn.cursor(dictionary=True)
    viewer_id = session['user_id']

    try:
        if request.method == 'GET':
            # Get all feedback for a series, plus aggregate stats
            cursor.execute("""
                SELECT f.FTEXT, f.RATE, f.FDATE, v.USERNAME, v.FNAME, v.LNAME
                FROM DRY_FEEDBACK f
                JOIN DRY_VIEWER v ON f.ACCOUNT = v.ACCOUNT
                WHERE f.SID = %s
                ORDER BY f.FDATE DESC
            """, (sid,))
            feedback_list = cursor.fetchall()

            cursor.execute("""
                SELECT AVG(RATE) as avg_rating, COUNT(*) as feedback_count
                FROM DRY_FEEDBACK
                WHERE SID = %s
            """, (sid,))
            stats = cursor.fetchone()
            
            # Check if current user has feedback
            cursor.execute("SELECT * FROM DRY_FEEDBACK WHERE SID = %s AND ACCOUNT = %s", (sid, viewer_id))
            user_feedback = cursor.fetchone()

            return jsonify({
                "feedback_list": feedback_list,
                "stats": stats,
                "user_feedback": user_feedback
            })

        elif request.method == 'POST': # Create or Update
            data = request.get_json()
            rate = data.get('rate')
            ftext = data.get('ftext')

            if not rate or not ftext or not (1 <= rate <= 5) or len(ftext) < 5:
                return jsonify({"error": "Invalid input. Rate must be 1-5 and text must be at least 5 characters."}), 400

            # Check if feedback already exists
            cursor.execute("SELECT 1 FROM DRY_FEEDBACK WHERE SID = %s AND ACCOUNT = %s", (sid, viewer_id))
            exists = cursor.fetchone()

            if exists: # Update
                query = "UPDATE DRY_FEEDBACK SET RATE = %s, FTEXT = %s, FDATE = CURDATE() WHERE SID = %s AND ACCOUNT = %s"
                cursor.execute(query, (rate, ftext, sid, viewer_id))
            else: # Insert
                query = "INSERT INTO DRY_FEEDBACK (SID, ACCOUNT, RATE, FTEXT, FDATE) VALUES (%s, %s, %s, %s, CURDATE())"
                cursor.execute(query, (sid, viewer_id, rate, ftext))
            
            db_conn.commit()
            return jsonify({"message": "Feedback submitted successfully"}), 200

        elif request.method == 'DELETE':
            cursor.execute("DELETE FROM DRY_FEEDBACK WHERE SID = %s AND ACCOUNT = %s", (sid, viewer_id))
            if cursor.rowcount == 0:
                return jsonify({"error": "No feedback found to delete"}), 404
            
            db_conn.commit()
            return jsonify({"message": "Feedback deleted successfully"}), 200

    except Exception as e:
        db_conn.rollback()
        return jsonify({"error": "Database operation failed", "details": str(e)}), 500
    finally:
        cursor.close()

@bp.route('/my-feedback', methods=['GET'])
@viewer_required
def get_my_feedback():
    viewer_id = session['user_id']
    try:
        db_conn = db.get_db()
        cursor = db_conn.cursor(dictionary=True)
        query = """
            SELECT s.SNAME, f.SID, f.RATE, f.FTEXT, f.FDATE
            FROM DRY_FEEDBACK f
            JOIN DRY_SERIES s ON f.SID = s.SID
            WHERE f.ACCOUNT = %s
            ORDER BY f.FDATE DESC;
        """
        cursor.execute(query, (viewer_id,))
        my_feedback = cursor.fetchall()
        return jsonify(my_feedback)
    except Exception as e:
        return jsonify({"error": "Database query failed", "details": str(e)}), 500
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()

@bp.route('/profile', methods=['GET', 'PUT'])
@viewer_required
def profile():
    viewer_id = session['user_id']
    db_conn = db.get_db()
    cursor = db_conn.cursor(dictionary=True)

    try:
        if request.method == 'GET':
            query = """
                SELECT v.ACCOUNT, v.USERNAME, v.FNAME, v.LNAME, v.STREET, v.CITY, v.STATE, v.ZIPCODE, v.MCHARGE, c.CNAME
                FROM DRY_VIEWER v
                JOIN DRY_COUNTRY c ON v.CID = c.CID
                WHERE v.ACCOUNT = %s
            """
            cursor.execute(query, (viewer_id,))
            profile_data = cursor.fetchone()
            if not profile_data:
                return jsonify({"error": "Profile not found"}), 404
            return jsonify(profile_data)
        
        elif request.method == 'PUT':
            data = request.get_json()
            # Fields that can be updated
            street = data.get('street')
            city = data.get('city')
            state = data.get('state')
            zipcode = data.get('zipcode')
            cid = data.get('cid')
            
            if not all([street, city, state, zipcode, cid]):
                return jsonify({"error": "All address fields and country are required."}), 400

            query = """
                UPDATE DRY_VIEWER
                SET STREET = %s, CITY = %s, STATE = %s, ZIPCODE = %s, CID = %s
                WHERE ACCOUNT = %s
            """
            cursor.execute(query, (street, city, state, zipcode, cid, viewer_id))
            db_conn.commit()
            return jsonify({"message": "Profile updated successfully"})

    except Exception as e:
        db_conn.rollback()
        return jsonify({"error": "Database operation failed", "details": str(e)}), 500
    finally:
        cursor.close()

@bp.route('/change-password', methods=['POST'])
@viewer_required
def change_password():
    data = request.get_json()
    old_password = data.get('old_password')
    new_password = data.get('new_password')
    security_answer = data.get('security_answer')
    viewer_id = session['user_id']

    if not old_password or not security_answer or not new_password:
        return jsonify({"error": "Old password, security answer and new password are required"}), 400

    db_conn = db.get_db()
    cursor = db_conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT PASSWORD_HASH, SECURITY_ANSWER FROM DRY_VIEWER WHERE ACCOUNT = %s", (viewer_id,))
        user = cursor.fetchone()

        if not user:
            return jsonify({"error": "User not found"}), 404

        if not check_password_hash(user['PASSWORD_HASH'], old_password):
            return jsonify({"error": "Invalid old password"}), 401

        if not user.get('SECURITY_ANSWER'):
            return jsonify({"error": "Security answer not set for this account"}), 400

        if user['SECURITY_ANSWER'].strip() != security_answer.strip():
            return jsonify({"error": "Incorrect security answer"}), 401

        new_password_hash = generate_password_hash(new_password, method="pbkdf2:sha256", salt_length=16)
        
        cursor.execute("UPDATE DRY_VIEWER SET PASSWORD_HASH = %s WHERE ACCOUNT = %s", (new_password_hash, viewer_id))
        db_conn.commit()
        
        return jsonify({"message": "Password updated successfully"}), 200

    except Exception as e:
        db_conn.rollback()
        return jsonify({"error": "Database operation failed", "details": str(e)}), 500
    finally:
        cursor.close()

@bp.route('/security-question', methods=['GET'])
@viewer_required
def get_security_question():
    viewer_id = session['user_id']
    cursor = db.get_db().cursor(dictionary=True)
    cursor.execute("SELECT SECURITY_QUESTION FROM DRY_VIEWER WHERE ACCOUNT = %s", (viewer_id,))
    row = cursor.fetchone()
    cursor.close()
    if not row or not row.get('SECURITY_QUESTION'):
        return jsonify({"error": "Security question not set"}), 404
    return jsonify({"security_question": row['SECURITY_QUESTION']})
