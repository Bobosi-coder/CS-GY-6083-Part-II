import React, { useEffect, useState } from 'react';
import axiosClient from '../api/axiosClient';

const emptyForm = { name: '', street: '', city: '', state: '', zipcode: '', est_year: '', cid: '' };

const AdminPhouses = () => {
  const [list, setList] = useState([]);
  const [form, setForm] = useState(emptyForm);
  const [editingId, setEditingId] = useState(null);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  const load = async () => {
    try {
      const data = await axiosClient.get('/admin/phouses');
      setList(data);
      setError('');
    } catch (err) {
      setError(err.error || 'Failed to load production houses');
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
        await axiosClient.put(`/admin/phouses/${editingId}`, {
          ...form,
          cid: Number(form.cid),
          est_year: Number(form.est_year),
        });
        setNotice('Updated');
      } else {
        await axiosClient.post('/admin/phouses', {
          ...form,
          cid: Number(form.cid),
          est_year: Number(form.est_year),
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
    setEditingId(row.PHOUSE_ID);
    setForm({
      name: row.NAME,
      street: row.STREET,
      city: row.CITY,
      state: row.STATE,
      zipcode: row.ZIPCODE,
      est_year: row.EST_YEAR,
      cid: row.CID,
    });
  };

  const deleteRow = async (id) => {
    try {
      await axiosClient.delete(`/admin/phouses/${id}`);
      setNotice('Deleted');
      load();
    } catch (err) {
      setError(err.error || 'Delete failed');
    }
  };

  return (
    <div className="page">
      <div className="page-inner">
        <div className="page-header">
          <h1 className="page-title">Production Houses</h1>
          {notice && <span className="pill">{notice}</span>}
        </div>
        {error && <p className="muted">{error}</p>}
        <div className="card">
          <form onSubmit={submit} className="form-row">
            <input name="name" placeholder="Name" value={form.name} onChange={handleChange} />
            <input name="street" placeholder="Street" value={form.street} onChange={handleChange} />
            <input name="city" placeholder="City" value={form.city} onChange={handleChange} />
            <input name="state" placeholder="State" value={form.state} onChange={handleChange} />
            <input name="zipcode" placeholder="Zipcode" value={form.zipcode} onChange={handleChange} />
            <input name="est_year" type="number" placeholder="Est. Year" value={form.est_year} onChange={handleChange} />
            <input name="cid" type="number" placeholder="Country ID" value={form.cid} onChange={handleChange} />
            <button className="btn" type="submit">{editingId ? 'Update' : 'Create'}</button>
            {editingId && (
              <button className="btn btn-secondary" type="button" onClick={() => { setEditingId(null); setForm(emptyForm); }}>
                Cancel
              </button>
            )}
          </form>
        </div>

        <div className="card section">
          <table className="table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Address</th>
                <th>Country</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {list.map((p) => (
                <tr key={p.PHOUSE_ID}>
                  <td>{p.PHOUSE_ID}</td>
                  <td>{p.NAME}</td>
                  <td className="muted">{p.STREET}, {p.CITY}, {p.STATE} {p.ZIPCODE} (Est. {p.EST_YEAR})</td>
                  <td>{p.CNAME}</td>
                  <td className="inline-actions">
                    <button className="btn btn-secondary" onClick={() => editRow(p)}>Edit</button>
                    <button className="btn btn-danger" onClick={() => deleteRow(p.PHOUSE_ID)}>Delete</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {!list.length && <p className="muted">No records.</p>}
        </div>
      </div>
    </div>
  );
};

export default AdminPhouses;
