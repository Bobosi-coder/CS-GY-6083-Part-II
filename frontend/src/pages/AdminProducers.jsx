import React, { useEffect, useState } from 'react';
import axiosClient from '../api/axiosClient';
import NavBar from '../components/NavBar';

const emptyForm = { fname: '', lname: '', street: '', city: '', state: '', zipcode: '', phone: '', email: '', cid: '' };

const AdminProducers = () => {
  const [list, setList] = useState([]);
  const [form, setForm] = useState(emptyForm);
  const [editingId, setEditingId] = useState(null);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  const load = async () => {
    try {
      const data = await axiosClient.get('/admin/producers');
      setList(data);
      setError('');
    } catch (err) {
      setError(err.error || 'Failed to load producers');
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
        await axiosClient.put(`/admin/producers/${editingId}`, { ...form, cid: Number(form.cid) });
        setNotice('Updated');
      } else {
        await axiosClient.post('/admin/producers', { ...form, cid: Number(form.cid) });
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
    setEditingId(row.PID);
    setForm({
      fname: row.FNAME,
      lname: row.LNAME,
      street: row.STREET,
      city: row.CITY,
      state: row.STATE,
      zipcode: row.ZIPCODE,
      phone: row.PHONE,
      email: row.EMAIL,
      cid: row.CID,
    });
  };

  const deleteRow = async (id) => {
    try {
      await axiosClient.delete(`/admin/producers/${id}`);
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
            <h1 className="page-title">Producers</h1>
            {notice && <span className="pill">{notice}</span>}
          </div>
          {error && <p className="muted">{error}</p>}
          <div className="card">
            <form onSubmit={submit} className="form-row">
              <input name="fname" placeholder="First name" value={form.fname} onChange={handleChange} />
              <input name="lname" placeholder="Last name" value={form.lname} onChange={handleChange} />
              <input name="street" placeholder="Street" value={form.street} onChange={handleChange} />
              <input name="city" placeholder="City" value={form.city} onChange={handleChange} />
              <input name="state" placeholder="State" value={form.state} onChange={handleChange} />
              <input name="zipcode" placeholder="Zipcode" value={form.zipcode} onChange={handleChange} />
              <input name="phone" placeholder="Phone" value={form.phone} onChange={handleChange} />
              <input name="email" placeholder="Email" value={form.email} onChange={handleChange} />
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
                  <th>Contact</th>
                  <th>Country</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {list.map((p) => (
                  <tr key={p.PID}>
                    <td>{p.PID}</td>
                    <td>{p.FNAME} {p.LNAME}</td>
                    <td className="muted">{p.EMAIL} · {p.PHONE}</td>
                    <td>{p.CNAME}</td>
                    <td className="inline-actions">
                      <button className="btn btn-secondary" onClick={() => editRow(p)}>Edit</button>
                      <button className="btn btn-danger" onClick={() => deleteRow(p.PID)}>Delete</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            {!list.length && <p className="muted">No records.</p>}
          </div>
        </div>
      </div>
    </>
  );
};

export default AdminProducers;
