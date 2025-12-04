from flask import Blueprint, jsonify
from admin_routes import admin_required
import db

bp = Blueprint('reports', __name__)

def run_query(query, params=None):
    try:
        db_conn = db.get_db()
        cursor = db_conn.cursor(dictionary=True)
        cursor.execute(query, params or ())
        result = cursor.fetchall()
        return jsonify({"query": query.strip(), "result": result})
    except Exception as e:
        return jsonify({"error": "Query failed", "details": str(e)}), 500
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()

@bp.route('/q1', methods=['GET'])
@admin_required
def report_q1():
    # Q1: JOIN with at least 3 tables.
    # Business Question: List all series with their genres and release countries.
    query = """
        SELECT s.SNAME, gt.TNAME as Genre, c.CNAME as ReleaseCountry, src.RELEASE_DATE
        FROM DRY_SERIES s
        JOIN DRY_SERIES_TYPE st ON s.SID = st.SID
        JOIN DRY_GENRE_TYPE gt ON st.TNAME = gt.TNAME
        JOIN DRY_SERIES_RELEASE_COUNTRY src ON s.SID = src.SID
        JOIN DRY_COUNTRY c ON src.CID = c.CID
        ORDER BY s.SNAME, c.CNAME;
    """
    return run_query(query)

@bp.route('/q2', methods=['GET'])
@admin_required
def report_q2():
    # Q2: Multi-row subquery (IN).
    # Business Question: Find all viewers who have written feedback for any 'Drama' series.
    query = """
        SELECT v.USERNAME, v.FNAME, v.LNAME
        FROM DRY_VIEWER v
        WHERE v.ACCOUNT IN (
            SELECT f.ACCOUNT
            FROM DRY_FEEDBACK f
            JOIN DRY_SERIES_TYPE st ON f.SID = st.SID
            WHERE st.TNAME = 'Drama'
        );
    """
    return run_query(query)

@bp.route('/q3', methods=['GET'])
@admin_required
def report_q3():
    # Q3: Correlated subquery.
    # Business Question: Find feedback entries whose rating is above the average rating for that specific series.
    query = """
        SELECT s.SNAME, v.USERNAME, f.RATE, f.FTEXT
        FROM DRY_FEEDBACK f
        JOIN DRY_SERIES s ON f.SID = s.SID
        JOIN DRY_VIEWER v ON f.ACCOUNT = v.ACCOUNT
        WHERE f.RATE > (
            SELECT AVG(f2.RATE)
            FROM DRY_FEEDBACK f2
            WHERE f2.SID = f.SID
        )
        ORDER BY s.SNAME, f.RATE DESC;
    """
    return run_query(query)

@bp.route('/q4', methods=['GET'])
@admin_required
def report_q4():
    # Q4: SET operator (UNION).
    # Business Question: List all series that have either English subtitles or English dubbing.
    query = """
        (SELECT SID, SNAME FROM DRY_SERIES WHERE SID IN (
            SELECT SID FROM DRY_SERIES_SUBTITLE WHERE LNAME = 'English'
        ))
        UNION
        (SELECT SID, SNAME FROM DRY_SERIES WHERE SID IN (
            SELECT SID FROM DRY_SERIES_DUBBING WHERE LNAME = 'English'
        ));
    """
    return run_query(query)

@bp.route('/q5', methods=['GET'])
@admin_required
def report_q5():
    # Q5: Inline view or WITH clause.
    # Business Question: Find high-rated series (avg rating > 4) that have at least 2 feedbacks.
    query = """
        WITH SeriesRatings AS (
            SELECT
                SID,
                AVG(RATE) as avg_rating,
                COUNT(ACCOUNT) as feedback_count
            FROM DRY_FEEDBACK
            GROUP BY SID
        )
        SELECT s.SNAME, sr.avg_rating, sr.feedback_count
        FROM SeriesRatings sr
        JOIN DRY_SERIES s ON sr.SID = s.SID
        WHERE sr.avg_rating > 4.0 AND sr.feedback_count >= 2
        ORDER BY sr.avg_rating DESC;
    """
    return run_query(query)

@bp.route('/q6', methods=['GET'])
@admin_required
def report_q6():
    # Q6: TOP-N query.
    # Business Question: Who are the top 3 most active viewers (by number of feedbacks given)?
    query = """
        SELECT v.USERNAME, v.FNAME, v.LNAME, COUNT(f.SID) AS total_feedback
        FROM DRY_VIEWER v
        JOIN DRY_FEEDBACK f ON v.ACCOUNT = f.ACCOUNT
        GROUP BY v.ACCOUNT
        ORDER BY total_feedback DESC
        LIMIT 3;
    """
    return run_query(query)
