import React, { useEffect, useState } from 'react';
import axiosClient from '../api/axiosClient';
import { Link } from 'react-router-dom';
import NavBar from '../components/NavBar';

const ViewerSeriesList = () => {
  const [series, setSeries] = useState([]);
  const [filters, setFilters] = useState({ genre: '', language: '', country: '' });
  const [options, setOptions] = useState({ genres: [], languages: [], countries: [] });
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
    // Preload options
    axiosClient.get('/viewer/series')
      .then((data) => {
        const genresSet = new Set();
        const languagesSet = new Set();
        const countriesSet = new Set();
        data.forEach((item) => {
          // genres string comma separated
          if (item.genres) {
            item.genres.split(',').map((g) => g.trim()).filter(Boolean).forEach((g) => genresSet.add(g));
          }
          if (item.ORI_LANG) {
            languagesSet.add(item.ORI_LANG);
          }
          if (item.country_ids) {
            item.country_ids.split(',').map((c) => c.trim()).filter(Boolean).forEach((c) => countriesSet.add(c));
          }
        });
        setOptions({
          genres: Array.from(genresSet),
          languages: Array.from(languagesSet),
          countries: Array.from(countriesSet),
        });
      })
      .catch(() => {});
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
    <>
      <NavBar />
      <div className="page">
        <div className="page-inner">
          <div className="page-header">
            <h1 className="page-title">Series Library</h1>
            <form className="toolbar" onSubmit={handleFilterSubmit}>
              <select name="genre" value={filters.genre} onChange={handleFilterChange}>
                <option value="">All genres</option>
                {options.genres.map((g) => <option key={g} value={g}>{g}</option>)}
              </select>
              <select name="language" value={filters.language} onChange={handleFilterChange}>
                <option value="">All languages</option>
                {options.languages.map((l) => <option key={l} value={l}>{l}</option>)}
              </select>
              <select name="country" value={filters.country} onChange={handleFilterChange}>
                <option value="">All countries</option>
                {options.countries.map((c) => <option key={c} value={c}>{c}</option>)}
              </select>
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
    </>
  );
};

export default ViewerSeriesList;
