import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import axiosClient from '../api/axiosClient';
import NavBar from '../components/NavBar';

const AdminEpisodes = () => {
  const { sid } = useParams();
  const [list, setList] = useState([]);
  const [form, setForm] = useState({
    e_num: '',
    schedule_sdate: '',
    schedule_edate: '',
    nviewers: '',
    interruption: 'N',
  });
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  const load = async () => {
    try {
      const data = await axiosClient.get(`/admin/series/${sid}/episodes`);
      setList(data);
      setError('');
    } catch (err) {
      setError(err.error || 'Failed to load episodes');
    }
  };

  useEffect(() => {
    load();
  }, [sid]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await axiosClient.post(`/admin/series/${sid}/episodes`, {
        e_num: Number(form.e_num),
        schedule_sdate: form.schedule_sdate,
        schedule_edate: form.schedule_edate,
        nviewers: Number(form.nviewers || 0),
        interruption: form.interruption,
      });
      setForm({ e_num: '', schedule_sdate: '', schedule_edate: '', nviewers: '', interruption: 'N' });
      setNotice('Episode added');
      load();
    } catch (err) {
      setError(err.error || 'Failed to add episode');
    }
  };

  const updateLocal = (eid, field, value) => {
    setList((prev) => prev.map((row) => row.EID === eid ? { ...row, [field]: value } : row));
  };

  const updateEpisode = async (eid, payload) => {
    try {
      await axiosClient.put(`/admin/episodes/${eid}`, payload);
      setNotice('Episode updated');
      load();
    } catch (err) {
      setError(err.error || 'Failed to update');
    }
  };

  const deleteEpisode = async (eid) => {
    try {
      await axiosClient.delete(`/admin/episodes/${eid}`);
      setNotice('Deleted');
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
            <h1 className="page-title">Episodes for Series #{sid}</h1>
            {notice && <span className="pill">{notice}</span>}
          </div>
          {error && <p className="muted">{error}</p>}
          <div className="card">
            <h3>Add Episode</h3>
            <form onSubmit={handleCreate} className="form-row">
              <input name="e_num" placeholder="Episode #" type="number" value={form.e_num} onChange={handleChange} />
              <input name="schedule_sdate" type="date" value={form.schedule_sdate} onChange={handleChange} />
              <input name="schedule_edate" type="date" value={form.schedule_edate} onChange={handleChange} />
              <input name="nviewers" placeholder="Viewers" type="number" value={form.nviewers} onChange={handleChange} />
              <input name="interruption" placeholder="Interruption (Y/N)" value={form.interruption} onChange={handleChange} />
              <button className="btn" type="submit">Add</button>
            </form>
          </div>

          <div className="card section">
            <table className="table">
              <thead>
                <tr>
                  <th>EID</th>
                  <th>#</th>
                  <th>Schedule</th>
                  <th>Viewers</th>
                  <th>Interruption</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {list.map((e) => (
                  <tr key={e.EID}>
                    <td>{e.EID}</td>
                    <td>
                      <input
                        type="number"
                        value={e.E_NUM}
                        onChange={(evt) => updateLocal(e.EID, 'E_NUM', Number(evt.target.value))}
                      />
                    </td>
                    <td>
                      <div className="form-row">
                        <input
                          type="date"
                          value={e.SCHEDULE_SDATE ? e.SCHEDULE_SDATE.slice(0, 10) : ''}
                          onChange={(evt) => updateLocal(e.EID, 'SCHEDULE_SDATE', evt.target.value)}
                        />
                        <input
                          type="date"
                          value={e.SCHEDULE_EDATE ? e.SCHEDULE_EDATE.slice(0, 10) : ''}
                          onChange={(evt) => updateLocal(e.EID, 'SCHEDULE_EDATE', evt.target.value)}
                        />
                      </div>
                    </td>
                    <td>
                      <input
                        type="number"
                        value={e.NVIEWERS}
                        onChange={(evt) => updateLocal(e.EID, 'NVIEWERS', Number(evt.target.value))}
                      />
                    </td>
                    <td>
                      <input
                        value={e.INTERRUPTION}
                        onChange={(evt) => updateLocal(e.EID, 'INTERRUPTION', evt.target.value)}
                      />
                    </td>
                    <td className="inline-actions">
                      <button
                        className="btn btn-secondary"
                        onClick={() => updateEpisode(e.EID, {
                          e_num: e.E_NUM,
                          schedule_sdate: e.SCHEDULE_SDATE,
                          schedule_edate: e.SCHEDULE_EDATE,
                          nviewers: e.NVIEWERS,
                          interruption: e.INTERRUPTION,
                        })}
                      >
                        Save
                      </button>
                      <button className="btn btn-danger" onClick={() => deleteEpisode(e.EID)}>Delete</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            {!list.length && <p className="muted">No episodes yet.</p>}
          </div>
        </div>
      </div>
    </>
  );
};

export default AdminEpisodes;
