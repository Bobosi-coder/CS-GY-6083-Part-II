import React, { useState } from 'react';
import axiosClient from '../api/axiosClient';

const ViewerChangePassword = () => {
  const [form, setForm] = useState({ old_password: '', new_password: '' });
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setNotice('');
    try {
      await axiosClient.post('/viewer/change-password', form);
      setNotice('Password updated');
      setForm({ old_password: '', new_password: '' });
    } catch (err) {
      setError(err.error || 'Failed to update password');
    }
  };

  return (
    <div className="page">
      <div className="page-inner">
        <div className="page-header">
          <h1 className="page-title">Change Password</h1>
          {notice && <span className="pill">{notice}</span>}
        </div>
        {error && <p className="muted">{error}</p>}
        <div className="card">
          <form onSubmit={handleSubmit} className="form-row">
            <input
              name="old_password"
              type="password"
              placeholder="Current password"
              value={form.old_password}
              onChange={handleChange}
            />
            <input
              name="new_password"
              type="password"
              placeholder="New password"
              value={form.new_password}
              onChange={handleChange}
            />
            <button className="btn" type="submit">Update</button>
          </form>
          <p className="notice">Use a strong password to protect your account.</p>
        </div>
      </div>
    </div>
  );
};

export default ViewerChangePassword;
