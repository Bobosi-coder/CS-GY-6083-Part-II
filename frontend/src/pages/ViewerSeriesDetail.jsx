import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import axiosClient from '../api/axiosClient';
import NavBar from '../components/NavBar';

const ViewerSeriesDetail = () => {
  const { sid } = useParams();
  const [detail, setDetail] = useState(null);
  const [feedbackData, setFeedbackData] = useState(null);
  const [form, setForm] = useState({ rate: 5, ftext: '' });
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  const loadDetail = async () => {
    try {
      const data = await axiosClient.get(`/viewer/series/${sid}`);
      setDetail(data);
    } catch (err) {
      setError(err.error || 'Failed to load series');
    }
  };

  const loadFeedback = async () => {
    try {
      const data = await axiosClient.get(`/viewer/series/${sid}/feedback`);
      setFeedbackData(data);
      if (data.user_feedback) {
        setForm({ rate: data.user_feedback.RATE, ftext: data.user_feedback.FTEXT });
      }
    } catch (err) {
      setError(err.error || 'Failed to load feedback');
    }
  };

  useEffect(() => {
    loadDetail();
    loadFeedback();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [sid]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setNotice('');
    setError('');
    try {
      await axiosClient.post(`/viewer/series/${sid}/feedback`, {
        rate: Number(form.rate),
        ftext: form.ftext,
      });
      setNotice('Feedback saved');
      loadFeedback();
    } catch (err) {
      setError(err.error || 'Failed to submit feedback');
    }
  };

  const handleDelete = async () => {
    setNotice('');
    setError('');
    try {
      await axiosClient.delete(`/viewer/series/${sid}/feedback`);
      setForm({ rate: 5, ftext: '' });
      setNotice('Feedback deleted');
      loadFeedback();
    } catch (err) {
      setError(err.error || 'Failed to delete feedback');
    }
  };

  const renderTagList = (items) => (
    <div className="tag-list">
      {items && items.length ? items.map((t) => <span className="chip" key={t}>{t}</span>) : <span className="muted">—</span>}
    </div>
  );

  if (!detail) {
    return (
      <>
        <NavBar />
        <div className="page">
          <div className="page-inner">
            <p className="muted">{error || 'Loading...'}</p>
          </div>
        </div>
      </>
    );
  }

  return (
    <>
      <NavBar />
      <div className="page">
        <div className="page-inner">
          <div className="page-header">
            <h1 className="page-title">{detail.SNAME}</h1>
            <div className="pill">SID #{detail.SID}</div>
          </div>

          {error && <p className="muted">{error}</p>}

          <div className="grid">
            <div className="card">
              <h3>Overview</h3>
              <p>Language: {detail.ORI_LANG}</p>
              <p>Episodes: {detail.NEPISODES}</p>
              <div className="section">
                <strong>Genres</strong>
                {renderTagList(detail.genres)}
              </div>
              <div className="section">
                <strong>Subtitles</strong>
                {renderTagList(detail.subtitles)}
              </div>
              <div className="section">
                <strong>Dubbings</strong>
                {renderTagList(detail.dubbings)}
              </div>
              <div className="section">
                <strong>Release Countries</strong>
                {detail.release_countries && detail.release_countries.length ? (
                  detail.release_countries.map((r, idx) => (
                    <p key={idx} className="muted">{r.CNAME} — {r.RELEASE_DATE}</p>
                  ))
                ) : <p className="muted">—</p>}
              </div>
            </div>

            <div className="card">
              <h3>Your Feedback</h3>
              <form onSubmit={handleSubmit} className="section">
                <div className="form-row">
                  <input
                    type="number"
                    min="1"
                    max="5"
                    name="rate"
                    value={form.rate}
                    onChange={(e) => setForm((prev) => ({ ...prev, rate: e.target.value }))}
                    placeholder="Rating 1-5"
                  />
                  <textarea
                    rows="4"
                    name="ftext"
                    value={form.ftext}
                    onChange={(e) => setForm((prev) => ({ ...prev, ftext: e.target.value }))}
                    placeholder="Share your thoughts"
                  />
                </div>
                <div className="inline-actions">
                  <button className="btn" type="submit">Save Feedback</button>
                  {feedbackData?.user_feedback && (
                    <button className="btn btn-secondary" type="button" onClick={handleDelete}>
                      Delete
                    </button>
                  )}
                </div>
              </form>
              {notice && <p className="notice">{notice}</p>}
            </div>
          </div>

          <div className="section card">
            <h3>Episodes</h3>
            {detail.episodes && detail.episodes.length ? (
              <table className="table">
                <thead>
                  <tr>
                    <th>#</th>
                    <th>Schedule</th>
                    <th>Viewers</th>
                    <th>Interrupted</th>
                  </tr>
                </thead>
                <tbody>
                  {detail.episodes.map((e) => (
                    <tr key={e.EID}>
                      <td>{e.E_NUM}</td>
                      <td>{e.SCHEDULE_SDATE} → {e.SCHEDULE_EDATE}</td>
                      <td>{e.NVIEWERS}</td>
                      <td>{e.INTERRUPTION}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            ) : <p className="muted">No episodes listed.</p>}
          </div>

          <div className="section card">
            <h3>Community Feedback</h3>
            {feedbackData ? (
              <>
                <p className="muted">
                  Avg Rating: {feedbackData.stats?.avg_rating ? parseFloat(feedbackData.stats.avg_rating).toFixed(2) : '—'} ·
                  Count: {feedbackData.stats?.feedback_count || 0}
                </p>
                {feedbackData.feedback_list?.length ? (
                  <ul>
                    {feedbackData.feedback_list.map((f, idx) => (
                      <li key={idx}>
                        <strong>{f.USERNAME}</strong> rated {f.RATE} — {f.FDATE}
                        <br />
                        <span className="muted">{f.FTEXT}</span>
                      </li>
                    ))}
                  </ul>
                ) : <p className="muted">No feedback yet.</p>}
              </>
            ) : <p className="muted">Loading feedback...</p>}
          </div>
        </div>
      </div>
    </>
  );
};

export default ViewerSeriesDetail;
