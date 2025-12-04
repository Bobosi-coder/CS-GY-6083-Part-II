import React, { useEffect, useState } from 'react';
import axiosClient from '../api/axiosClient';
import NavBar from '../components/NavBar';

const AdminCollaboration = () => {
  const [list, setList] = useState([]);
  const [form, setForm] = useState({ pid: '', phouse_id: '' });
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  const load = async () => {
    try {
      const data = await axiosClient.get('/admin/collaborations');
      setList(data);
    } catch (err) {
      setError(err.error || 'Failed to load collaborations');
    }
  };

  useEffect(() => {
    load();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await axiosClient.post('/admin/collaborations', {
        pid: Number(form.pid),
        phouse_id: Number(form.phouse_id),
      });
      setForm({ pid: '', phouse_id: '' });
      setNotice('Added');
      load();
    } catch (err) {
      setError(err.error || 'Failed to add');
    }
  };

  const handleDelete = async (pid, phouse_id) => {
    try {
      await axiosClient.delete('/admin/collaborations', { data: { pid, phouse_id } });
      setNotice('Removed');
      load();
    } catch (err) {
      setError(err.error || 'Failed to remove');
    }
  };

  return (
    <>
      <NavBar />
      <div className="page">
        <div className="page-inner">
          <div className="page-header">
            <h1 className="page-title">Collaborations</h1>
            {notice && <span className="pill">{notice}</span>}
          </div>
          {error && <p className="muted">{error}</p>}
          <div className="card">
            <form onSubmit={handleSubmit} className="form-row">
              <input name="pid" type="number" placeholder="Producer ID" value={form.pid} onChange={(e) => setForm((p) => ({ ...p, pid: e.target.value }))} />
              <input name="phouse_id" type="number" placeholder="Production House ID" value={form.phouse_id} onChange={(e) => setForm((p) => ({ ...p, phouse_id: e.target.value }))} />
              <button className="btn" type="submit">Add</button>
            </form>
          </div>

          <div className="card section">
            <table className="table">
              <thead>
                <tr>
                  <th>Producer</th>
                  <th>Production House</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {list.map((c) => (
                  <tr key={`${c.PID}-${c.PHOUSE_ID}`}>
                    <td>{c.producer_name} (#{c.PID})</td>
                    <td>{c.phouse_name} (#{c.PHOUSE_ID})</td>
                    <td className="inline-actions">
                      <button className="btn btn-danger" onClick={() => handleDelete(c.PID, c.PHOUSE_ID)}>Remove</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            {!list.length && <p className="muted">No collaborations recorded.</p>}
          </div>
        </div>
      </div>
    </>
  );
};

export default AdminCollaboration;
