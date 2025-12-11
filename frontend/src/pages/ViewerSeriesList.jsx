import React, { useEffect, useState } from 'react';
import axiosClient from '../api/axiosClient';
import { Link } from 'react-router-dom';
import NavBar from '../components/NavBar';

const ViewerSeriesList = () => {
  const [series, setSeries] = useState([]);
  const [filters, setFilters] = useState({ genre: '', language: '', country: '' });
  const [options, setOptions] = useState({ genres: [], languages: [], countries: [] });
  const [countryMap, setCountryMap] = useState({});
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  const loadAndProcessData = async () => {
    try {
      setLoading(true);
      // Fetch all series to populate options and for initial display
      const allSeriesData = await axiosClient.get('/viewer/series');
      setSeries(allSeriesData);

      const genresSet = new Set();
      const languagesSet = new Set();
      const countriesSet = new Set(); // This will hold CIDs
      const newCountryMap = {};

      allSeriesData.forEach((item) => {
        if (item.genres) {
          item.genres.split(',').map((g) => g.trim()).filter(Boolean).forEach((g) => genresSet.add(g));
        }
        if (item.ORI_LANG) {
          languagesSet.add(item.ORI_LANG);
        }
        if (item.countries) {
          try {
            // The data from backend might be a string, ensure it's parsed
            const countryList = typeof item.countries === 'string' ? JSON.parse(item.countries) : item.countries;
            countryList.forEach(country => {
              if (country && country.CID) {
                countriesSet.add(country.CID);
                if (!newCountryMap[country.CID]) {
                  newCountryMap[country.CID] = country.CNAME;
                }
              }
            });
          } catch (e) {
            console.error("Failed to parse countries JSON:", item.countries, e);
          }
        }
      });

      setOptions({
        genres: Array.from(genresSet).sort(),
        languages: Array.from(languagesSet).sort(),
        countries: Array.from(countriesSet).sort((a, b) => newCountryMap[a].localeCompare(newCountryMap[b])),
      });
      setCountryMap(newCountryMap);
      setError('');
    } catch (err) {
      setError(err.error || 'Failed to load initial data');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadAndProcessData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleFilterChange = (e) => {
    const { name, value } = e.target;
    setFilters((prev) => ({ ...prev, [name]: value }));
  };

  const handleFilterSubmit = async (e) => {
    e.preventDefault();
    try {
      setLoading(true);
      const filteredData = await axiosClient.get('/viewer/series', { params: filters });
      setSeries(filteredData);
      setError('');
    } catch (err) {
      setError(err.error || 'Failed to load filtered series');
    } finally {
      setLoading(false);
    }
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
                <option value="">All original languages</option>
                {options.languages.map((l) => <option key={l} value={l}>{l}</option>)}
              </select>
              {/* <select name="country" value={filters.country} onChange={handleFilterChange}>
                <option value="">All countries</option>
                {options.countries.map((c) => <option key={c} value={c}>{countryMap[c] || c}</option>)}
              </select> */}
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
                  <p className="muted">Original Language: {s.ORI_LANG || 'N/A'}</p>
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
