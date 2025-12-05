import React, { useEffect, useState } from 'react';
import axiosClient from '../api/axiosClient';
import NavBar from '../components/NavBar';

const ViewerProfile = () => {
  const [profile, setProfile] = useState(null);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  const load = async () => {
    try {
      const data = await axiosClient.get('/viewer/profile');
      setProfile(data);
      setError('');
    } catch (err) {
      setError(err.error || 'Failed to load profile');
    }
  };

  useEffect(() => {
    load();
  }, []);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setProfile((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setNotice('');
    try {
      await axiosClient.put('/viewer/profile', {
        street: profile.STREET,
        city: profile.CITY,
        state: profile.STATE,
        zipcode: profile.ZIPCODE,
        cid: profile.CID,
      });
      setNotice('Profile updated');
      load();
    } catch (err) {
      setError(err.error || 'Failed to update profile');
    }
  };

  if (!profile) {
    return (
      <>
        <NavBar />
        <div className="page">
          <div className="page-inner">
            <p className="muted">{error || 'Loading...'}</p>
          </div>
        </div>
      </>
    );
  }

  return (
    <>
      <NavBar />
      <div className="page">
        <div className="page-inner">
          <div className="page-header">
            <h1 className="page-title">My Profile</h1>
            {notice && <span className="pill">{notice}</span>}
          </div>
          {error && <p className="muted">{error}</p>}
          <div className="card">
            <p className="muted">Username: {profile.USERNAME}</p>
            <p className="muted">Name: {profile.FNAME} {profile.LNAME}</p>
            <p className="muted">Country: {profile.CNAME}</p>
            <p className="muted">Monthly Charge: {profile.MCHARGE}</p>
            <form onSubmit={handleSubmit} className="section">
              <div className="form-row">
                <input name="STREET" placeholder="Street" value={profile.STREET || ''} onChange={handleChange} />
                <input name="CITY" placeholder="City" value={profile.CITY || ''} onChange={handleChange} />
                <input name="STATE" placeholder="State" value={profile.STATE || ''} onChange={handleChange} />
                <input name="ZIPCODE" placeholder="Zipcode" value={profile.ZIPCODE || ''} onChange={handleChange} />
                {/* <input name="CID" placeholder="Country ID" value={profile.CID || ''} onChange={handleChange} /> */}
              </div>
              <button className="btn" type="submit">Save</button>
            </form>
          </div>
        </div>
      </div>
    </>
  );
};

export default ViewerProfile;
