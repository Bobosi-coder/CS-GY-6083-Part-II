import React, { useEffect, useState } from 'react';
import axiosClient from '../api/axiosClient';
import { Link } from 'react-router-dom';

const ViewerSeriesList = () => {
  const [series, setSeries] = useState([]);
  const [filters, setFilters] = useState({ genre: '', language: '', country: '' });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  const load = async () => {
    try {
      setLoading(true);
      const data = await axiosClient.get('/viewer/series', { params: filters });
      setSeries(data);
      setError('');
    } catch (err) {
      setError(err.error || 'Failed to load series');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleFilterChange = (e) => {
    const { name, value } = e.target;
    setFilters((prev) => ({ ...prev, [name]: value }));
  };

  const handleFilterSubmit = (e) => {
    e.preventDefault();
    load();
  };

  return (
    <div className="page">
      <div className="page-inner">
        <div className="page-header">
          <h1 className="page-title">Series Library</h1>
          <form className="toolbar" onSubmit={handleFilterSubmit}>
            <input name="genre" placeholder="Genre" value={filters.genre} onChange={handleFilterChange} />
            <input name="language" placeholder="Language" value={filters.language} onChange={handleFilterChange} />
            <input name="country" placeholder="Country ID" value={filters.country} onChange={handleFilterChange} />
            <button className="btn" type="submit">Filter</button>
          </form>
        </div>

        {error && <p className="muted">{error}</p>}
        {loading ? (
          <p className="muted">Loading...</p>
        ) : (
          <div className="grid">
            {series.map((s) => (
              <div key={s.SID} className="card">
                <h3>{s.SNAME}</h3>
                <p className="muted">Language: {s.ORI_LANG || 'N/A'}</p>
                <p className="muted">Episodes: {s.NEPISODES}</p>
                <p className="muted">Genres: {s.genres || '—'}</p>
                <p className="muted">Rating: {s.avg_rating ? parseFloat(s.avg_rating).toFixed(2) : 'No ratings'}</p>
                <Link className="btn" to={`/viewer/series/${s.SID}`}>Open</Link>
              </div>
            ))}
            {!series.length && <p className="muted">No series found.</p>}
          </div>
        )}
      </div>
    </div>
  );
};

export default ViewerSeriesList;
