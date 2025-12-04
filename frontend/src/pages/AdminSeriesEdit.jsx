import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import axiosClient from '../api/axiosClient';
import NavBar from '../components/NavBar';

const csvToArray = (value) => value.split(',').map((v) => v.trim()).filter(Boolean);
const releaseToArray = (value) => value.split('\n').map((line) => line.trim()).filter(Boolean)
  .map((line) => {
    const [cid, release_date] = line.split(':').map((v) => v.trim());
    return cid && release_date ? { cid: Number(cid), release_date } : null;
  }).filter(Boolean);

const AdminSeriesEdit = () => {
  const { sid } = useParams();
  const [form, setForm] = useState({
    sname: '',
    nepisodes: '',
    ori_lang: '',
    genres: '',
    subtitles: '',
    dubbings: '',
    releaseText: '',
  });
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  const load = async () => {
    try {
      const data = await axiosClient.get(`/admin/series/${sid}`);
      setForm({
        sname: data.SNAME || '',
        nepisodes: data.NEPISODES || '',
        ori_lang: data.ORI_LANG || '',
        genres: (data.genres || []).join(', '),
        subtitles: (data.subtitles || []).join(', '),
        dubbings: (data.dubbings || []).join(', '),
        releaseText: (data.release_countries || []).map((r) => `${r.CID}:${r.RELEASE_DATE}`).join('\n'),
      });
      setError('');
    } catch (err) {
      setError(err.error || 'Failed to load series');
    }
  };

  useEffect(() => {
    load();
  }, [sid]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await axiosClient.put(`/admin/series/${sid}`, {
        sname: form.sname,
        nepisodes: Number(form.nepisodes),
        ori_lang: form.ori_lang,
        genres: csvToArray(form.genres),
        subtitles: csvToArray(form.subtitles),
        dubbings: csvToArray(form.dubbings),
        release_countries: releaseToArray(form.releaseText),
      });
      setNotice('Updated');
      load();
    } catch (err) {
      setError(err.error || 'Failed to update');
    }
  };

  return (
    <>
      <NavBar />
      <div className="page">
        <div className="page-inner">
          <div className="page-header">
            <h1 className="page-title">Edit Series #{sid}</h1>
            {notice && <span className="pill">{notice}</span>}
          </div>
          {error && <p className="muted">{error}</p>}
          <div className="card">
            <form onSubmit={handleSubmit} className="form-row">
              <input name="sname" placeholder="Name" value={form.sname} onChange={handleChange} />
              <input name="nepisodes" type="number" placeholder="Episodes" value={form.nepisodes} onChange={handleChange} />
              <input name="ori_lang" placeholder="Original language" value={form.ori_lang} onChange={handleChange} />
              <input name="genres" placeholder="Genres (comma separated)" value={form.genres} onChange={handleChange} />
              <input name="subtitles" placeholder="Subtitles (comma separated)" value={form.subtitles} onChange={handleChange} />
              <input name="dubbings" placeholder="Dubbings (comma separated)" value={form.dubbings} onChange={handleChange} />
              <textarea
                name="releaseText"
                rows="4"
                placeholder="Release countries (cid:YYYY-MM-DD per line)"
                value={form.releaseText}
                onChange={handleChange}
              />
              <button className="btn" type="submit">Save</button>
            </form>
          </div>
        </div>
      </div>
    </>
  );
};

export default AdminSeriesEdit;
