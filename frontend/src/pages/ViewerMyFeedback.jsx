import React, { useEffect, useState } from 'react';
import axiosClient from '../api/axiosClient';
import { Link } from 'react-router-dom';

const ViewerMyFeedback = () => {
  const [items, setItems] = useState([]);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({ rate: 5, ftext: '' });
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  const load = async () => {
    try {
      const data = await axiosClient.get('/viewer/my-feedback');
      setItems(data);
      setError('');
    } catch (err) {
      setError(err.error || 'Failed to load feedback');
    }
  };

  useEffect(() => {
    load();
  }, []);

  const startEdit = (item) => {
    setEditing(item);
    setForm({ rate: item.RATE, ftext: item.FTEXT });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!editing) return;
    try {
      await axiosClient.post(`/viewer/series/${editing.SID}/feedback`, {
        rate: Number(form.rate),
        ftext: form.ftext,
      });
      setNotice('Updated');
      setEditing(null);
      setForm({ rate: 5, ftext: '' });
      load();
    } catch (err) {
      setError(err.error || 'Failed to update feedback');
    }
  };

  const handleDelete = async (sid) => {
    try {
      await axiosClient.delete(`/viewer/series/${sid}/feedback`);
      setNotice('Deleted');
      load();
    } catch (err) {
      setError(err.error || 'Failed to delete feedback');
    }
  };

  return (
    <div className="page">
      <div className="page-inner">
        <div className="page-header">
          <h1 className="page-title">My Feedback</h1>
          {notice && <span className="pill">{notice}</span>}
        </div>
        {error && <p className="muted">{error}</p>}
        <div className="card">
          <table className="table">
            <thead>
              <tr>
                <th>Series</th>
                <th>Rate</th>
                <th>Text</th>
                <th>Date</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {items.map((f) => (
                <tr key={`${f.SID}-${f.FDATE}`}>
                  <td><Link to={`/viewer/series/${f.SID}`}>{f.SNAME}</Link></td>
                  <td>{f.RATE}</td>
                  <td className="muted">{f.FTEXT}</td>
                  <td>{f.FDATE}</td>
                  <td className="inline-actions">
                    <button className="btn btn-secondary" onClick={() => startEdit(f)}>Edit</button>
                    <button className="btn btn-danger" onClick={() => handleDelete(f.SID)}>Delete</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {!items.length && <p className="muted">No feedback yet.</p>}
        </div>

        {editing && (
          <div className="card section">
            <h3>Edit Feedback for {editing.SNAME}</h3>
            <form onSubmit={handleSubmit}>
              <div className="form-row">
                <input
                  type="number"
                  min="1"
                  max="5"
                  value={form.rate}
                  onChange={(e) => setForm((prev) => ({ ...prev, rate: e.target.value }))}
                  placeholder="Rate 1-5"
                />
                <textarea
                  rows="4"
                  value={form.ftext}
                  onChange={(e) => setForm((prev) => ({ ...prev, ftext: e.target.value }))}
                  placeholder="Feedback text"
                />
              </div>
              <div className="inline-actions">
                <button className="btn" type="submit">Save</button>
                <button className="btn btn-secondary" type="button" onClick={() => setEditing(null)}>Cancel</button>
              </div>
            </form>
          </div>
        )}
      </div>
    </div>
  );
};

export default ViewerMyFeedback;
