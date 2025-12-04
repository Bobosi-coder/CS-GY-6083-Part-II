import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import axiosClient from '../api/axiosClient';
import { Link } from 'react-router-dom';

const ViewerHome = () => {
    const { user, logout } = useAuth();
    const [recommendations, setRecommendations] = useState([]);
    const [error, setError] = useState('');

    useEffect(() => {
        axiosClient.get('/viewer/recommendations')
            .then(setRecommendations)
            .catch(err => setError(err.error || 'Could not fetch recommendations'));
    }, []);

    return (
        <div className="page">
            <div className="page-inner">
                <div className="page-header">
                    <h1 className="page-title">Welcome, {user.display_name}!</h1>
                    <div className="inline-actions">
                        <Link className="btn btn-secondary" to="/viewer/series">All Series</Link>
                        <Link className="btn btn-secondary" to="/viewer/my-feedback">My Feedback</Link>
                        <Link className="btn btn-secondary" to="/viewer/profile">Profile</Link>
                        <button className="btn btn-danger" onClick={logout}>Logout</button>
                    </div>
                </div>
                <div className="card">
                    <h2>Top Recommended Series</h2>
                    {error && <p className="muted">{error}</p>}
                    <div className="grid">
                        {recommendations.map(series => (
                            <div key={series.SID} className="card">
                                <h3><Link to={`/viewer/series/${series.SID}`}>{series.SNAME}</Link></h3>
                                <p className="muted">Language: {series.ORI_LANG}</p>
                                <p className="muted">Avg. Rating: {parseFloat(series.avg_rating).toFixed(2)}</p>
                            </div>
                        ))}
                    </div>
                    {!recommendations.length && <p className="muted">No recommendations yet.</p>}
                </div>
            </div>
        </div>
    );
};

export default ViewerHome;
