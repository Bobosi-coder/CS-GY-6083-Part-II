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
        <div>
            <header style={{ display: 'flex', justifyContent: 'space-between', padding: '1rem', background: '#eee' }}>
                <h1>Welcome, {user.display_name}!</h1>
                <nav>
                    <Link to="/viewer/series">All Series</Link> | 
                    <Link to="/viewer/my-feedback">My Feedback</Link> | 
                    <Link to="/viewer/profile">Profile</Link> | 
                    <button onClick={logout}>Logout</button>
                </nav>
            </header>
            <main style={{ padding: '1rem' }}>
                <h2>Top Recommended Series</h2>
                {error && <p style={{ color: 'red' }}>{error}</p>}
                <div style={{ display: 'flex', gap: '1rem' }}>
                    {recommendations.map(series => (
                        <div key={series.SID} style={{ border: '1px solid #ccc', padding: '1rem', borderRadius: '5px' }}>
                            <h3><Link to={`/viewer/series/${series.SID}`}>{series.SNAME}</Link></h3>
                            <p>Language: {series.ORI_LANG}</p>
                            <p>Avg. Rating: {parseFloat(series.avg_rating).toFixed(2)}</p>
                        </div>
                    ))}
                </div>
            </main>
        </div>
    );
};

export default ViewerHome;
