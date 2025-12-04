import React, { useEffect, useState } from 'react';
import axiosClient from '../api/axiosClient';
import NavBar from '../components/NavBar';

const emptyForm = { issued_date: '', episode_price: '', is_renew: '', phouse_id: '', sid: '' };

const AdminContracts = () => {
  const [list, setList] = useState([]);
  const [form, setForm] = useState(emptyForm);
  const [editingId, setEditingId] = useState(null);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  const load = async () => {
    try {
      const data = await axiosClient.get('/admin/contracts');
      setList(data);
    } catch (err) {
      setError(err.error || 'Failed to load contracts');
    }
  };

  useEffect(() => {
    load();
  }, []);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const submit = async (e) => {
    e.preventDefault();
    try {
      if (editingId) {
        await axiosClient.put(`/admin/contracts/${editingId}`, {
          ...form,
          phouse_id: Number(form.phouse_id),
          sid: Number(form.sid),
          episode_price: Number(form.episode_price),
        });
        setNotice('Updated');
      } else {
        await axiosClient.post('/admin/contracts', {
          ...form,
          phouse_id: Number(form.phouse_id),
          sid: Number(form.sid),
          episode_price: Number(form.episode_price),
        });
        setNotice('Created');
      }
      setForm(emptyForm);
      setEditingId(null);
      load();
    } catch (err) {
      setError(err.error || 'Save failed');
    }
  };

  const editRow = (row) => {
    setEditingId(row.CID);
    setForm({
      issued_date: row.ISSUED_DATE,
      episode_price: row.EPISODE_PRICE,
      is_renew: row.IS_RENEW || '',
      phouse_id: row.PHOUSE_ID,
      sid: row.SID,
    });
  };

  const deleteRow = async (id) => {
    try {
      await axiosClient.delete(`/admin/contracts/${id}`);
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
            <h1 className="page-title">Contracts</h1>
            {notice && <span className="pill">{notice}</span>}
          </div>
          {error && <p className="muted">{error}</p>}
          <div className="card">
            <form onSubmit={submit} className="form-row">
              <input name="issued_date" type="date" placeholder="Issued date" value={form.issued_date} onChange={handleChange} />
              <input name="episode_price" type="number" placeholder="Episode price" value={form.episode_price} onChange={handleChange} />
              <input name="is_renew" placeholder="Is renew (Y/N/null)" value={form.is_renew} onChange={handleChange} />
              <input name="phouse_id" type="number" placeholder="Production House ID" value={form.phouse_id} onChange={handleChange} />
              <input name="sid" type="number" placeholder="Series ID" value={form.sid} onChange={handleChange} />
              <button className="btn" type="submit">{editingId ? 'Update' : 'Create'}</button>
              {editingId && <button className="btn btn-secondary" type="button" onClick={() => { setEditingId(null); setForm(emptyForm); }}>Cancel</button>}
            </form>
          </div>

          <div className="card section">
            <table className="table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Series</th>
                  <th>House</th>
                  <th>Price</th>
                  <th>Issued</th>
                  <th>Renew</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {list.map((c) => (
                  <tr key={c.CID}>
                    <td>{c.CID}</td>
                    <td>{c.SNAME} (#{c.SID})</td>
                    <td>{c.phouse_name} (#{c.PHOUSE_ID})</td>
                    <td>{c.EPISODE_PRICE}</td>
                    <td>{c.ISSUED_DATE}</td>
                    <td>{c.IS_RENEW}</td>
                    <td className="inline-actions">
                      <button className="btn btn-secondary" onClick={() => editRow(c)}>Edit</button>
                      <button className="btn btn-danger" onClick={() => deleteRow(c.CID)}>Delete</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            {!list.length && <p className="muted">No contracts.</p>}
          </div>
        </div>
      </div>
    </>
  );
};

export default AdminContracts;
