import React, { useEffect, useState } from 'react';
import axiosClient from '../api/axiosClient';
import NavBar from '../components/NavBar';

const AdminFeedback = () => {
  const [filters, setFilters] = useState({ sid: '', rating: '', start_date: '', end_date: '' });
  const [list, setList] = useState([]);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  const load = async () => {
    try {
      const data = await axiosClient.get('/admin/feedback', { params: filters });
      setList(data);
    } catch (err) {
      setError(err.error || 'Failed to load feedback');
    }
  };

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFilters((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    load();
  };

  const handleDelete = async (account, sid) => {
    try {
      await axiosClient.delete('/admin/feedback', { data: { account, sid } });
      setNotice('Deleted');
      load();
    } catch (err) {
      setError(err.error || 'Delete failed');
    }
  };

  return (
    <>
      <NavBar />
      <div className="page">
        <div className="page-inner">
          <div className="page-header">
            <h1 className="page-title">Feedback</h1>
            {notice && <span className="pill">{notice}</span>}
          </div>
          {error && <p className="muted">{error}</p>}
          <div className="card">
            <form onSubmit={handleSubmit} className="form-row">
              <input name="sid" placeholder="Series ID" value={filters.sid} onChange={handleChange} />
              <input name="rating" placeholder="Exact rating" value={filters.rating} onChange={handleChange} />
              <input name="start_date" type="date" placeholder="Start date" value={filters.start_date} onChange={handleChange} title="Start date (from)" />
              <input name="end_date" type="date" placeholder="End date" value={filters.end_date} onChange={handleChange} title="End date (to)" />
              <button className="btn" type="submit">Filter</button>
            </form>
            <p className="notice">Date filters: start date = from (inclusive), end date = to (inclusive).</p>
          </div>

          <div className="card section">
            <table className="table">
              <thead>
                <tr>
                  <th>Series</th>
                  <th>User</th>
                  <th>Rate</th>
                  <th>Text</th>
                  <th>Date</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {list.map((f) => (
                  <tr key={`${f.ACCOUNT}-${f.SID}-${f.FDATE}`}>
                    <td>{f.SNAME} (#{f.SID})</td>
                    <td>{f.USERNAME} (#{f.ACCOUNT})</td>
                    <td>{f.RATE}</td>
                    <td className="muted">{f.FTEXT}</td>
                    <td>{f.FDATE}</td>
                    <td><button className="btn btn-danger" onClick={() => handleDelete(f.ACCOUNT, f.SID)}>Delete</button></td>
                  </tr>
                ))}
              </tbody>
            </table>
            {!list.length && <p className="muted">No feedback found.</p>}
          </div>
        </div>
      </div>
    </>
  );
};

export default AdminFeedback;
