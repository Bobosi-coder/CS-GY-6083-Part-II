import React, { useEffect, useState } from 'react';
import axiosClient from '../api/axiosClient';
import NavBar from '../components/NavBar';

const AdminViewers = () => {
  const [list, setList] = useState([]);
  const [selected, setSelected] = useState(null);
  const [form, setForm] = useState({ street: '', city: '', state: '', zipcode: '', mcharge: '', cid: '' });
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  const load = async () => {
    try {
      const data = await axiosClient.get('/admin/viewers');
      setList(data);
    } catch (err) {
      setError(err.error || 'Failed to load viewers');
    }
  };

  useEffect(() => {
    load();
  }, []);

  const pick = async (account) => {
    try {
      const data = await axiosClient.get(`/admin/viewers/${account}`);
      setSelected(account);
      setForm({
        street: data.STREET || '',
        city: data.CITY || '',
        state: data.STATE || '',
        zipcode: data.ZIPCODE || '',
        mcharge: data.MCHARGE || '',
        cid: data.CID || '',
      });
    } catch (err) {
      setError(err.error || 'Failed to load viewer');
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!selected) return;
    try {
      await axiosClient.put(`/admin/viewers/${selected}`, {
        ...form,
        mcharge: Number(form.mcharge),
        cid: Number(form.cid),
      });
      setNotice('Updated viewer');
      load();
    } catch (err) {
      setError(err.error || 'Update failed');
    }
  };

  return (
    <>
      <NavBar />
      <div className="page">
        <div className="page-inner">
          <div className="page-header">
            <h1 className="page-title">Viewers</h1>
            {notice && <span className="pill">{notice}</span>}
          </div>
          {error && <p className="muted">{error}</p>}
          <div className="card">
            <table className="table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Name</th>
                  <th>Location</th>
                  <th>Country</th>
                  <th>Feedback</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {list.map((v) => (
                  <tr key={v.ACCOUNT}>
                    <td>{v.ACCOUNT}</td>
                    <td>{v.USERNAME} ({v.FNAME} {v.LNAME})</td>
                    <td className="muted">{v.CITY}, {v.STATE}</td>
                    <td>{v.CNAME}</td>
                    <td>{v.feedback_count}</td>
                    <td><button className="btn btn-secondary" onClick={() => pick(v.ACCOUNT)}>Edit</button></td>
                  </tr>
                ))}
              </tbody>
            </table>
            {!list.length && <p className="muted">No viewers.</p>}
          </div>

          {selected && (
            <div className="card section">
              <h3>Edit Viewer #{selected}</h3>
              <form onSubmit={handleSubmit} className="form-row">
                <input name="street" placeholder="Street" value={form.street} onChange={handleChange} />
                <input name="city" placeholder="City" value={form.city} onChange={handleChange} />
                <input name="state" placeholder="State" value={form.state} onChange={handleChange} />
                <input name="zipcode" placeholder="Zipcode" value={form.zipcode} onChange={handleChange} />
                <input name="mcharge" type="number" placeholder="Monthly charge" value={form.mcharge} onChange={handleChange} />
                <input name="cid" type="number" placeholder="Country ID" value={form.cid} onChange={handleChange} />
                <button className="btn" type="submit">Save</button>
                <button className="btn btn-secondary" type="button" onClick={() => { setSelected(null); setForm({ street: '', city: '', state: '', zipcode: '', mcharge: '', cid: '' }); }}>Cancel</button>
              </form>
            </div>
          )}
        </div>
      </div>
    </>
  );
};

export default AdminViewers;
