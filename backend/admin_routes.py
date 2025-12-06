from flask import Blueprint, request, jsonify, session
from functools import wraps
import db

bp = Blueprint('admin', __name__)

# Decorator to protect routes for logged-in admins
def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'role' not in session or session['role'] != 'admin':
            return jsonify({"error": "Access denied. Admin role required."}), 403
        return f(*args, **kwargs)
    return decorated_function

# --- Dashboard ---
@bp.route('/stats', methods=['GET'])
@admin_required
def get_dashboard_stats():
    try:
        db_conn = db.get_db()
        cursor = db_conn.cursor(dictionary=True)

        # Total series
        cursor.execute("SELECT COUNT(*) AS total_series FROM DRY_SERIES")
        total_series = cursor.fetchone()['total_series']

        # Total viewers
        cursor.execute("SELECT COUNT(*) AS total_viewers FROM DRY_VIEWER")
        total_viewers = cursor.fetchone()['total_viewers']
        
        # Total feedback
        cursor.execute("SELECT COUNT(*) AS total_feedback FROM DRY_FEEDBACK")
        total_feedback = cursor.fetchone()['total_feedback']

        # Feedback in last 7 days
        cursor.execute("SELECT COUNT(*) AS recent_feedback FROM DRY_FEEDBACK WHERE FDATE >= CURDATE() - INTERVAL 7 DAY")
        recent_feedback = cursor.fetchone()['recent_feedback']
        
        # Top 5 series by average rating
        cursor.execute("""
            SELECT s.SNAME, AVG(f.RATE) as avg_rating
            FROM DRY_FEEDBACK f
            JOIN DRY_SERIES s ON f.SID = s.SID
            GROUP BY s.SID
            ORDER BY avg_rating DESC
            LIMIT 5
        """)
        top_series = cursor.fetchall()

        return jsonify({
            "total_series": total_series,
            "total_viewers": total_viewers,
            "total_feedback": total_feedback,
            "recent_feedback": recent_feedback,
            "top_series": top_series
        })
    except Exception as e:
        return jsonify({"error": "Database query failed", "details": str(e)}), 500
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()

# --- Series CRUD ---
@bp.route('/series', methods=['GET', 'POST'])
@admin_required
def handle_series():
    db_conn = db.get_db()
    cursor = db_conn.cursor(dictionary=True)
    try:
        if request.method == 'GET':
            query = """
                SELECT 
                    s.SID, s.SNAME, s.NEPISODES, s.ORI_LANG,
                    AVG(f.RATE) as avg_rating,
                    GROUP_CONCAT(DISTINCT st.TNAME) as genres
                FROM DRY_SERIES s
                LEFT JOIN DRY_FEEDBACK f ON s.SID = f.SID
                LEFT JOIN DRY_SERIES_TYPE st ON s.SID = st.SID
                GROUP BY s.SID
                ORDER BY s.SID DESC
            """
            cursor.execute(query)
            return jsonify(cursor.fetchall())
        
        elif request.method == 'POST':
            data = request.get_json()
            # Basic series info
            sname = data.get('sname')
            nepisodes = data.get('nepisodes')
            ori_lang = data.get('ori_lang')

            if not all([sname, nepisodes, ori_lang]):
                return jsonify({"error": "Missing series information"}), 400

            db_conn.start_transaction()
            # Insert into DRY_SERIES
            cursor.execute("INSERT INTO DRY_SERIES (SNAME, NEPISODES, ORI_LANG) VALUES (%s, %s, %s)",
                           (sname, nepisodes, ori_lang))
            sid = cursor.lastrowid

            # Handle M-M relationships
            # ... (genres, subtitles, dubbings, release_countries) ...
            # This part will be implemented in the PUT endpoint for simplicity of creation
            
            db_conn.commit()
            return jsonify({"message": "Series created successfully", "sid": sid}), 201

    except Exception as e:
        db_conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()

@bp.route('/series/<int:sid>', methods=['GET', 'PUT', 'DELETE'])
@admin_required
def handle_single_series(sid):
    db_conn = db.get_db()
    cursor = db_conn.cursor(dictionary=True)
    try:
        # Check if series exists
        cursor.execute("SELECT * FROM DRY_SERIES WHERE SID = %s", (sid,))
        series = cursor.fetchone()
        if not series:
            return jsonify({"error": "Series not found"}), 404

        if request.method == 'GET':
             # Also fetch associated data for the edit form
            cursor.execute("SELECT TNAME FROM DRY_SERIES_TYPE WHERE SID = %s", (sid,))
            series['genres'] = [r['TNAME'] for r in cursor.fetchall()]
            cursor.execute("SELECT LNAME FROM DRY_SERIES_SUBTITLE WHERE SID = %s", (sid,))
            series['subtitles'] = [r['LNAME'] for r in cursor.fetchall()]
            cursor.execute("SELECT LNAME FROM DRY_SERIES_DUBBING WHERE SID = %s", (sid,))
            series['dubbings'] = [r['LNAME'] for r in cursor.fetchall()]
            cursor.execute("SELECT CID, RELEASE_DATE FROM DRY_SERIES_RELEASE_COUNTRY WHERE SID = %s", (sid,))
            series['release_countries'] = cursor.fetchall()
            return jsonify(series)

        elif request.method == 'PUT':
            data = request.get_json()
            sname = data.get('sname')
            nepisodes = data.get('nepisodes')
            ori_lang = data.get('ori_lang')

            genres = data.get('genres', [])
            subtitles = data.get('subtitles', [])
            dubbings = data.get('dubbings', [])
            release_countries = data.get('release_countries', []) # Expected format: [{"cid": 1, "release_date": "YYYY-MM-DD"}]

            db_conn.start_transaction()
            
            # 1. Update DRY_SERIES table
            cursor.execute("UPDATE DRY_SERIES SET SNAME = %s, NEPISODES = %s, ORI_LANG = %s WHERE SID = %s",
                           (sname, nepisodes, ori_lang, sid))

            # 2. Update Genres (delete all then re-insert)
            cursor.execute("DELETE FROM DRY_SERIES_TYPE WHERE SID = %s", (sid,))
            if genres:
                genre_data = [(sid, g) for g in genres]
                cursor.executemany("INSERT INTO DRY_SERIES_TYPE (SID, TNAME) VALUES (%s, %s)", genre_data)

            # 3. Update Subtitles
            cursor.execute("DELETE FROM DRY_SERIES_SUBTITLE WHERE SID = %s", (sid,))
            if subtitles:
                subtitle_data = [(sid, l) for l in subtitles]
                cursor.executemany("INSERT INTO DRY_SERIES_SUBTITLE (SID, LNAME) VALUES (%s, %s)", subtitle_data)

            # 4. Update Dubbings
            cursor.execute("DELETE FROM DRY_SERIES_DUBBING WHERE SID = %s", (sid,))
            if dubbings:
                dubbing_data = [(sid, l) for l in dubbings]
                cursor.executemany("INSERT INTO DRY_SERIES_DUBBING (SID, LNAME) VALUES (%s, %s)", dubbing_data)

            # 5. Update Release Countries
            cursor.execute("DELETE FROM DRY_SERIES_RELEASE_COUNTRY WHERE SID = %s", (sid,))
            if release_countries:
                country_data = [(sid, rc['cid'], rc['release_date']) for rc in release_countries]
                cursor.executemany("INSERT INTO DRY_SERIES_RELEASE_COUNTRY (SID, CID, RELEASE_DATE) VALUES (%s, %s, %s)", country_data)

            db_conn.commit()
            return jsonify({"message": f"Series {sid} updated successfully."})

        elif request.method == 'DELETE':
            try:
                db_conn.start_transaction()
                # Must delete from child tables first due to FK constraints
                cursor.execute("DELETE FROM DRY_SERIES_TYPE WHERE SID = %s", (sid,))
                cursor.execute("DELETE FROM DRY_SERIES_SUBTITLE WHERE SID = %s", (sid,))
                cursor.execute("DELETE FROM DRY_SERIES_DUBBING WHERE SID = %s", (sid,))
                cursor.execute("DELETE FROM DRY_SERIES_RELEASE_COUNTRY WHERE SID = %s", (sid,))
                cursor.execute("DELETE FROM DRY_FEEDBACK WHERE SID = %s", (sid,))
                cursor.execute("DELETE FROM DRY_EPISODE WHERE SID = %s", (sid,))
                # You might want to prevent deleting if a contract exists
                cursor.execute("DELETE FROM DRY_CONTRACT WHERE SID = %s", (sid,))
                
                # Finally, delete the series itself
                cursor.execute("DELETE FROM DRY_SERIES WHERE SID = %s", (sid,))
                db_conn.commit()
                return jsonify({"message": f"Series {sid} and all related data deleted successfully."})
            except mysql.connector.Error as err:
                 db_conn.rollback()
                 return jsonify({"error": f"Failed to delete series due to a database error: {err}"}), 500

    except Exception as e:
        db_conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()

# Placeholder for other CRUD endpoints...

# --- Episodes CRUD ---
@bp.route('/series/<int:sid>/episodes', methods=['GET', 'POST'])
@admin_required
def handle_episodes(sid):
    db_conn = db.get_db()
    cursor = db_conn.cursor(dictionary=True)
    try:
        if request.method == 'GET':
            cursor.execute("SELECT * FROM DRY_EPISODE WHERE SID = %s ORDER BY E_NUM", (sid,))
            return jsonify(cursor.fetchall())
        
        elif request.method == 'POST':
            data = request.get_json()
            e_num = data.get('e_num')
            sdate = data.get('schedule_sdate')
            edate = data.get('schedule_edate')
            nviewers = data.get('nviewers', 0)
            interruption = data.get('interruption', 'N')

            if not all([e_num, sdate, edate]):
                 return jsonify({"error": "Missing episode data"}), 400

            query = """
                INSERT INTO DRY_EPISODE (E_NUM, SCHEDULE_SDATE, SCHEDULE_EDATE, NVIEWERS, SID, INTERRUPTION)
                VALUES (%s, %s, %s, %s, %s, %s)
            """
            cursor.execute(query, (e_num, sdate, edate, nviewers, sid, interruption))
            db_conn.commit()
            return jsonify({"message": "Episode added"}), 201

    except Exception as e:
        db_conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()

@bp.route('/episodes/<int:eid>', methods=['PUT', 'DELETE'])
@admin_required
def handle_single_episode(eid):
    db_conn = db.get_db()
    cursor = db_conn.cursor()
    try:
        if request.method == 'PUT':
            data = request.get_json()
            e_num = data.get('e_num')
            sdate = data.get('schedule_sdate')
            edate = data.get('schedule_edate')
            nviewers = data.get('nviewers')
            interruption = data.get('interruption')
            
            query = """
                UPDATE DRY_EPISODE SET E_NUM=%s, SCHEDULE_SDATE=%s, SCHEDULE_EDATE=%s, NVIEWERS=%s, INTERRUPTION=%s
                WHERE EID = %s
            """
            cursor.execute(query, (e_num, sdate, edate, nviewers, interruption, eid))
            db_conn.commit()
            return jsonify({"message": "Episode updated"})

        elif request.method == 'DELETE':
            cursor.execute("DELETE FROM DRY_EPISODE WHERE EID = %s", (eid,))
            db_conn.commit()
            return jsonify({"message": "Episode deleted"})
    except Exception as e:
        db_conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()


# --- Production Houses CRUD ---
@bp.route('/phouses', methods=['GET', 'POST'])
@admin_required
def handle_phouses():
    db_conn = db.get_db()
    cursor = db_conn.cursor(dictionary=True)
    try:
        if request.method == 'GET':
            cursor.execute("""
                SELECT p.*, c.CNAME 
                FROM DRY_PHOUSE p 
                JOIN DRY_COUNTRY c ON p.CID = c.CID
            """)
            return jsonify(cursor.fetchall())
        if request.method == 'POST':
            data = request.get_json()
            query = """
                INSERT INTO DRY_PHOUSE (NAME, STREET, CITY, STATE, ZIPCODE, EST_YEAR, CID)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            params = (data['name'], data['street'], data['city'], data['state'], data['zipcode'], data['est_year'], data['cid'])
            cursor.execute(query, params)
            db_conn.commit()
            return jsonify({"message": "Production house created"}), 201
    except Exception as e:
        db_conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()

@bp.route('/phouses/<int:phouse_id>', methods=['PUT', 'DELETE'])
@admin_required
def handle_single_phouse(phouse_id):
    db_conn = db.get_db()
    cursor = db_conn.cursor()
    try:
        if request.method == 'PUT':
            data = request.get_json()
            query = """
                UPDATE DRY_PHOUSE SET NAME=%s, STREET=%s, CITY=%s, STATE=%s, ZIPCODE=%s, EST_YEAR=%s, CID=%s
                WHERE PHOUSE_ID = %s
            """
            params = (data['name'], data['street'], data['city'], data['state'], data['zipcode'], data['est_year'], data['cid'], phouse_id)
            cursor.execute(query, params)
            db_conn.commit()
            return jsonify({"message": "Production house updated"})
        elif request.method == 'DELETE':
            # Add safety check here - cannot delete if contracts exist
            cursor.execute("SELECT 1 FROM DRY_CONTRACT WHERE PHOUSE_ID = %s", (phouse_id,))
            if cursor.fetchone():
                return jsonify({"error": "Cannot delete production house with active contracts"}), 400
            
            cursor.execute("DELETE FROM DRY_COLLABORATION WHERE PHOUSE_ID = %s", (phouse_id,))
            cursor.execute("DELETE FROM DRY_PHOUSE WHERE PHOUSE_ID = %s", (phouse_id,))
            db_conn.commit()
            return jsonify({"message": "Production house deleted"})
    except Exception as e:
        db_conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()

# --- Producers CRUD ---
@bp.route('/producers', methods=['GET', 'POST'])
@admin_required
def handle_producers():
    db_conn = db.get_db()
    cursor = db_conn.cursor(dictionary=True)
    try:
        if request.method == 'GET':
            cursor.execute("SELECT p.*, c.CNAME FROM DRY_PRODUCER p JOIN DRY_COUNTRY c ON p.CID = c.CID")
            return jsonify(cursor.fetchall())
        if request.method == 'POST':
            data = request.get_json()
            query = """
                INSERT INTO DRY_PRODUCER (FNAME, LNAME, STREET, CITY, STATE, ZIPCODE, PHONE, EMAIL, CID)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            params = (data['fname'], data['lname'], data['street'], data['city'], data['state'], data['zipcode'], data['phone'], data['email'], data['cid'])
            cursor.execute(query, params)
            db_conn.commit()
            return jsonify({"message": "Producer created"}), 201
    except Exception as e:
        db_conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()

@bp.route('/producers/<int:pid>', methods=['PUT', 'DELETE'])
@admin_required
def handle_single_producer(pid):
    db_conn = db.get_db()
    cursor = db_conn.cursor()
    try:
        if request.method == 'PUT':
            data = request.get_json()
            query = """
                UPDATE DRY_PRODUCER SET FNAME=%s, LNAME=%s, STREET=%s, CITY=%s, STATE=%s, ZIPCODE=%s, PHONE=%s, EMAIL=%s, CID=%s
                WHERE PID = %s
            """
            params = (data['fname'], data['lname'], data['street'], data['city'], data['state'], data['zipcode'], data['phone'], data['email'], data['cid'], pid)
            cursor.execute(query, params)
            db_conn.commit()
            return jsonify({"message": "Producer updated"})
        elif request.method == 'DELETE':
            cursor.execute("DELETE FROM DRY_COLLABORATION WHERE PID = %s", (pid,))
            cursor.execute("DELETE FROM DRY_PRODUCER WHERE PID = %s", (pid,))
            db_conn.commit()
            return jsonify({"message": "Producer deleted"})
    except Exception as e:
        db_conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()


# --- Collaborations ----
@bp.route('/collaborations', methods=['GET', 'POST', 'DELETE'])
@admin_required
def handle_collaborations():
    db_conn = db.get_db()
    cursor = db_conn.cursor(dictionary=True)
    try:
        if request.method == 'GET':
            query = """
                SELECT c.PID, c.PHOUSE_ID, CONCAT(p.FNAME, ' ', p.LNAME) as producer_name, ph.NAME as phouse_name
                FROM DRY_COLLABORATION c
                JOIN DRY_PRODUCER p ON c.PID = p.PID
                JOIN DRY_PHOUSE ph ON c.PHOUSE_ID = ph.PHOUSE_ID
            """
            cursor.execute(query)
            return jsonify(cursor.fetchall())
        
        data = request.get_json()
        pid = data.get('pid')
        phouse_id = data.get('phouse_id')

        if request.method == 'POST':
            cursor.execute("INSERT INTO DRY_COLLABORATION (PID, PHOUSE_ID) VALUES (%s, %s)", (pid, phouse_id))
            db_conn.commit()
            return jsonify({"message": "Collaboration added"})
        
        if request.method == 'DELETE':
            cursor.execute("DELETE FROM DRY_COLLABORATION WHERE PID = %s AND PHOUSE_ID = %s", (pid, phouse_id))
            db_conn.commit()
            return jsonify({"message": "Collaboration removed"})

    except Exception as e:
        db_conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()


# --- Contracts CRUD ---
@bp.route('/contracts', methods=['GET', 'POST'])
@admin_required
def handle_contracts():
    db_conn = db.get_db()
    cursor = db_conn.cursor(dictionary=True)
    try:
        if request.method == 'GET':
            query = """
                SELECT con.*, s.SNAME, p.NAME as phouse_name
                FROM DRY_CONTRACT con
                JOIN DRY_SERIES s ON con.SID = s.SID
                JOIN DRY_PHOUSE p ON con.PHOUSE_ID = p.PHOUSE_ID
            """
            cursor.execute(query)
            return jsonify(cursor.fetchall())
        if request.method == 'POST':
            data = request.get_json()
            query = """
                INSERT INTO DRY_CONTRACT (ISSUED_DATE, EPISODE_PRICE, IS_RENEW, PHOUSE_ID, SID)
                VALUES (%s, %s, %s, %s, %s)
            """
            params = (data['issued_date'], data['episode_price'], data.get('is_renew'), data['phouse_id'], data['sid'])
            cursor.execute(query, params)
            db_conn.commit()
            return jsonify({"message": "Contract created"}), 201
    except Exception as e:
        db_conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()

@bp.route('/contracts/<int:cid>', methods=['PUT', 'DELETE'])
@admin_required
def handle_single_contract(cid):
    db_conn = db.get_db()
    cursor = db_conn.cursor()
    try:
        if request.method == 'PUT':
            data = request.get_json()
            query = """
                UPDATE DRY_CONTRACT SET ISSUED_DATE=%s, EPISODE_PRICE=%s, IS_RENEW=%s, PHOUSE_ID=%s, SID=%s
                WHERE CID = %s
            """
            params = (data['issued_date'], data['episode_price'], data.get('is_renew'), data['phouse_id'], data['sid'], cid)
            cursor.execute(query, params)
            db_conn.commit()
            return jsonify({"message": "Contract updated"})
        elif request.method == 'DELETE':
            cursor.execute("DELETE FROM DRY_CONTRACT WHERE CID = %s", (cid,))
            db_conn.commit()
            return jsonify({"message": "Contract deleted"})
    except Exception as e:
        db_conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()


# --- Viewers Admin ---
@bp.route('/viewers', methods=['GET'])
@admin_required
def get_viewers():
    cursor = db.get_db().cursor(dictionary=True)
    cursor.execute("""
        SELECT v.ACCOUNT, v.USERNAME, v.FNAME, v.LNAME, v.CITY, v.STATE, v.MCHARGE, v.OPEN_DATE, c.CNAME, COUNT(f.SID) as feedback_count
        FROM DRY_VIEWER v
        JOIN DRY_COUNTRY c ON v.CID = c.CID
        LEFT JOIN DRY_FEEDBACK f ON v.ACCOUNT = f.ACCOUNT
        GROUP BY v.ACCOUNT
    """)
    viewers = cursor.fetchall()
    cursor.close()
    return jsonify(viewers)

@bp.route('/viewers/<int:account_id>', methods=['GET', 'PUT'])
@admin_required
def handle_viewer(account_id):
    db_conn = db.get_db()
    cursor = db_conn.cursor(dictionary=True)
    try:
        if request.method == 'GET':
            cursor.execute("SELECT ACCOUNT, USERNAME, FNAME, LNAME, STREET, CITY, STATE, ZIPCODE, MCHARGE, CID FROM DRY_VIEWER WHERE ACCOUNT = %s", (account_id,))
            viewer = cursor.fetchone()
            return jsonify(viewer)
        elif request.method == 'PUT':
            data = request.get_json()
            query = "UPDATE DRY_VIEWER SET STREET=%s, CITY=%s, STATE=%s, ZIPCODE=%s, MCHARGE=%s, CID=%s WHERE ACCOUNT = %s"
            params = (data['street'], data['city'], data['state'], data['zipcode'], data['mcharge'], data['cid'], account_id)
            cursor.execute(query, params)
            db_conn.commit()
            return jsonify({"message": "Viewer updated"})
    except Exception as e:
        db_conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()

# --- Feedback Admin ---
@bp.route('/feedback', methods=['GET'])
@admin_required
def get_all_feedback():
    db_conn = db.get_db()
    cursor = db_conn.cursor(dictionary=True)
    try:
        # Filtering logic
        sid = request.args.get('sid')
        rating = request.args.get('rating')
        start_date = request.args.get('start_date')
        end_date = request.args.get('end_date')

        query = """
            SELECT f.*, s.SNAME, v.USERNAME
            FROM DRY_FEEDBACK f
            JOIN DRY_SERIES s ON f.SID = s.SID
            JOIN DRY_VIEWER v ON f.ACCOUNT = v.ACCOUNT
        """
        conditions = []
        params = []
        if sid:
            conditions.append("f.SID = %s")
            params.append(sid)
        if rating:
            conditions.append("f.RATE = %s")
            params.append(rating)
        if start_date:
            conditions.append("f.FDATE >= %s")
            params.append(start_date)
        if end_date:
            conditions.append("f.FDATE <= %s")
            params.append(end_date)
        
        if conditions:
            query += " WHERE " + " AND ".join(conditions)
        
        cursor.execute(query, tuple(params))
        return jsonify(cursor.fetchall())
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()


@bp.route('/feedback', methods=['DELETE'])
@admin_required
def delete_feedback():
    # Note: Primary key is (ACCOUNT, SID)
    data = request.get_json()
    account = data.get('account')
    sid = data.get('sid')
    if not account or not sid:
        return jsonify({"error": "account and sid are required"}), 400
    
    db_conn = db.get_db()
    cursor = db_conn.cursor()
    try:
        cursor.execute("DELETE FROM DRY_FEEDBACK WHERE ACCOUNT = %s AND SID = %s", (account, sid))
        db_conn.commit()
        if cursor.rowcount == 0:
            return jsonify({"error": "Feedback not found"}), 404
        return jsonify({"message": "Feedback deleted"})
    except Exception as e:
        db_conn.rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()

#————————————————XYK——————————————————————
@bp.route('/viewer-growth', methods=['GET'])
@admin_required
def viewer_growth():
    try:
        db_conn = db.get_db()
        cursor = db_conn.cursor(dictionary=True)

        query = """
            SELECT 
                DATE_FORMAT(OPEN_DATE, '%Y-%m') AS month,
                COUNT(*) AS new_viewers
            FROM DRY_VIEWER
            GROUP BY DATE_FORMAT(OPEN_DATE, '%Y-%m')
            ORDER BY month
        """
        cursor.execute(query)
        data = cursor.fetchall()

        return jsonify(data)

    except Exception as e:
        return jsonify({"error": "Failed to fetch viewer growth", "details": str(e)}), 500

    finally:
        if 'cursor' in locals():
            cursor.close()


@bp.route('/revenue-growth', methods=['GET'])
@admin_required
def revenue_growth():
    try:
        db_conn = db.get_db()
        cursor = db_conn.cursor(dictionary=True)

        query = """
            WITH monthly AS (
                SELECT
                    DATE_FORMAT(OPEN_DATE, '%Y-%m') AS month,
                    SUM(MCHARGE) AS revenue_new
                FROM DRY_VIEWER
                GROUP BY DATE_FORMAT(OPEN_DATE, '%Y-%m')
            ),
            cumulative AS (
                SELECT
                    m1.month,
                    (SELECT SUM(m2.revenue_new)
                     FROM monthly m2
                     WHERE m2.month <= m1.month
                    ) AS revenue_total
                FROM monthly m1
            )
            SELECT 
                m.month,
                m.revenue_new,
                c.revenue_total
            FROM monthly m
            JOIN cumulative c ON m.month = c.month
            ORDER BY m.month
        """
        cursor.execute(query)
        data = cursor.fetchall()

        return jsonify(data)

    except Exception as e:
        return jsonify({"error": "Failed to fetch revenue growth", "details": str(e)}), 500

    finally:
        if 'cursor' in locals():
            cursor.close()
#######————————————————XYK——————————————————————
