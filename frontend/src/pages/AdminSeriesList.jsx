import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import axiosClient from '../api/axiosClient';
import NavBar from '../components/NavBar';

const AdminSeriesList = () => {
  const [list, setList] = useState([]);
  const [form, setForm] = useState({ sname: '', nepisodes: '', ori_lang: '' });
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  const load = async () => {
    try {
      const data = await axiosClient.get('/admin/series');
      setList(data);
      setError('');
    } catch (err) {
      setError(err.error || 'Failed to load series');
    }
  };

  useEffect(() => {
    load();
  }, []);

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await axiosClient.post('/admin/series', {
        sname: form.sname,
        nepisodes: Number(form.nepisodes),
        ori_lang: form.ori_lang,
      });
      setForm({ sname: '', nepisodes: '', ori_lang: '' });
      setNotice('Created');
      load();
    } catch (err) {
      setError(err.error || 'Failed to create series');
    }
  };

  const handleDelete = async (sid) => {
    try {
      await axiosClient.delete(`/admin/series/${sid}`);
      setNotice(`Deleted series ${sid}`);
      load();
    } catch (err) {
      setError(err.error || 'Failed to delete');
    }
  };

  return (
    <>
      <NavBar />
      <div className="page">
        <div className="page-inner">
          <div className="page-header">
            <h1 className="page-title">Manage Series</h1>
            {notice && <span className="pill">{notice}</span>}
          </div>
          {error && <p className="muted">{error}</p>}
          <div className="card section">
            <h3>Create Series</h3>
            <form onSubmit={handleCreate} className="form-row">
              <input name="sname" placeholder="Name" value={form.sname} onChange={(e) => setForm((p) => ({ ...p, sname: e.target.value }))} />
              <input name="nepisodes" type="number" placeholder="Episodes" value={form.nepisodes} onChange={(e) => setForm((p) => ({ ...p, nepisodes: e.target.value }))} />
              <input name="ori_lang" placeholder="Original language" value={form.ori_lang} onChange={(e) => setForm((p) => ({ ...p, ori_lang: e.target.value }))} />
              <button className="btn" type="submit">Create</button>
            </form>
          </div>

          <div className="card section">
            <table className="table">
              <thead>
                <tr>
                  <th>SID</th>
                  <th>Name</th>
                  <th>Episodes</th>
                  <th>Language</th>
                  <th>Genres</th>
                  <th>Avg Rating</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {list.map((s) => (
                  <tr key={s.SID}>
                    <td>{s.SID}</td>
                    <td>{s.SNAME}</td>
                    <td>{s.NEPISODES}</td>
                    <td>{s.ORI_LANG}</td>
                    <td>{s.genres}</td>
                    <td>{s.avg_rating ? parseFloat(s.avg_rating).toFixed(2) : '—'}</td>
                    <td className="inline-actions">
                      <Link className="btn btn-secondary" to={`/admin/series/${s.SID}/edit`}>Edit</Link>
                      <Link className="btn btn-secondary" to={`/admin/series/${s.SID}/episodes`}>Episodes</Link>
                      <button className="btn btn-danger" onClick={() => handleDelete(s.SID)}>Delete</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            {!list.length && <p className="muted">No series yet.</p>}
          </div>
        </div>
      </div>
    </>
  );
};

export default AdminSeriesList;
