import React, { useEffect, useState } from 'react';
import axiosClient from '../api/axiosClient';
import NavBar from '../components/NavBar';

const AdminHistory = () => {
  const [rows, setRows] = useState([]);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    axiosClient.get('/admin/history')
      .then((data) => {
        setRows(data);
        setError('');
      })
      .catch((err) => setError(err.error || 'Failed to load history'))
      .finally(() => setLoading(false));
  }, []);

  return (
    <>
      <NavBar />
      <div className="page">
        <div className="page-inner">
          <div className="page-header">
            <h1 className="page-title">Admin History</h1>
            {loading && <span className="pill">Loading...</span>}
          </div>
          {error && <p className="muted">{error}</p>}
          <div className="card section">
            <table className="table">
              <thead>
                <tr>
                  <th>HID</th>
                  <th>Admin</th>
                  <th>Timestamp</th>
                  <th>Table</th>
                  <th>Action</th>
                  <th>SQL</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((r) => (
                  <tr key={r.HID}>
                    <td>{r.HID}</td>
                    <td>{r.admin_name ? `${r.admin_name} (#${r.ADMIN_ID})` : `#${r.ADMIN_ID}`}</td>
                    <td>{r.ACTION_TS}</td>
                    <td>{r.TARGET_TABLE}</td>
                    <td>{r.ACTION_TYPE}</td>
                    <td><pre className="muted" style={{ whiteSpace: 'pre-wrap', margin: 0 }}>{r.SQL_TEXT}</pre></td>
                  </tr>
                ))}
              </tbody>
            </table>
            {!loading && !rows.length && <p className="muted">No history records.</p>}
          </div>
        </div>
      </div>
    </>
  );
};

export default AdminHistory;
