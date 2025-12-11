import React, { useEffect, useState } from 'react';
import axiosClient from '../api/axiosClient';
import NavBar from '../components/NavBar';

const ViewerChangePassword = () => {
  const [form, setForm] = useState({ old_password: '', security_answer: '', new_password: '' });
  const [question, setQuestion] = useState('');
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  useEffect(() => {
    axiosClient.get('/viewer/security-question')
      .then((data) => {
        setQuestion(data.security_question);
      })
      .catch((err) => {
        setError(err.error || 'Failed to load security question');
      });
  }, []);

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
      setForm({ old_password: '', security_answer: '', new_password: '' });
    } catch (err) {
      setError(err.error || 'Failed to update password');
    }
  };

  return (
    <>
      <NavBar />
      <div className="page">
        <div className="page-inner">
          <div className="page-header">
            <h1 className="page-title">Change Password</h1>
            {notice && <span className="pill">{notice}</span>}
          </div>
          {error && <p className="muted">{error}</p>}
          <div className="card">
            <form onSubmit={handleSubmit} className="form-row">
              <div className="form-group" style={{ width: '100%', textAlign: 'left' }}>
                <label className="muted">Security question</label>
                <div style={{ padding: '0.75rem 0.5rem', border: '1px solid #ccc', borderRadius: '6px', background: '#1f1f2e' }}>
                  {question || 'Not set'}
                </div>
              </div>
              <input
                name="security_answer"
                placeholder="Your answer"
                value={form.security_answer}
                onChange={handleChange}
              />
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
    </>
  );
};

export default ViewerChangePassword;
