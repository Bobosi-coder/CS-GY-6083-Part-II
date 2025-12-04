import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import axiosClient from '../api/axiosClient';
import { Link } from 'react-router-dom';

const AdminHome = () => {
    const { user, logout } = useAuth();
    const [stats, setStats] = useState(null);
    const [error, setError] = useState('');

    useEffect(() => {
        axiosClient.get('/admin/stats')
            .then(setStats)
            .catch(err => setError(err.error || 'Could not fetch dashboard stats'));
    }, []);

    return (
        <div>
            <header style={{ display: 'flex', justifyContent: 'space-between', padding: '1rem', background: '#333', color: 'white' }}>
                <h1>Admin Dashboard</h1>
                <nav>
                    <Link to="/admin/series" style={{color: 'white'}}>Series</Link> | 
                    <Link to="/admin/phouses" style={{color: 'white'}}>Prod. Houses</Link> | 
                    <Link to="/admin/producers" style={{color: 'white'}}>Producers</Link> | 
                    <Link to="/admin/contracts" style={{color: 'white'}}>Contracts</Link> |
                    <Link to="/admin/viewers" style={{color: 'white'}}>Viewers</Link> |
                    <Link to="/admin/feedback" style={{color: 'white'}}>Feedback</Link> |
                    <Link to="/admin/reports" style={{color: 'white'}}>Reports</Link> |
                    <button onClick={logout}>Logout</button>
                </nav>
            </header>
            <main style={{ padding: '1rem' }}>
                <h2>Welcome, {user.display_name}!</h2>
                {error && <p style={{ color: 'red' }}>{error}</p>}
                {stats ? (
                    <div>
                        <h3>Key Metrics</h3>
                        <div style={{ display: 'flex', gap: '2rem' }}>
                            <div style={{ border: '1px solid #ccc', padding: '1rem' }}>
                                <h4>Total Series</h4>
                                <p style={{fontSize: '2rem'}}>{stats.total_series}</p>
                            </div>
                            <div style={{ border: '1px solid #ccc', padding: '1rem' }}>
                                <h4>Total Viewers</h4>
                                <p style={{fontSize: '2rem'}}>{stats.total_viewers}</p>
                            </div>
                            <div style={{ border: '1px solid #ccc', padding: '1rem' }}>
                                <h4>Total Feedback</h4>
                                <p style={{fontSize: '2rem'}}>{stats.total_feedback}</p>
                            </div>
                             <div style={{ border: '1px solid #ccc', padding: '1rem' }}>
                                <h4>Feedback (Last 7 Days)</h4>
                                <p style={{fontSize: '2rem'}}>{stats.recent_feedback}</p>
                            </div>
                        </div>
                        <h3 style={{marginTop: '2rem'}}>Top 5 Rated Series</h3>
                        <ul>
                            {stats.top_series.map(s => (
                                <li key={s.SNAME}>{s.SNAME} - Avg. Rating: {parseFloat(s.avg_rating).toFixed(2)}</li>
                            ))}
                        </ul>
                    </div>
                ) : (
                    <p>Loading stats...</p>
                )}
            </main>
        </div>
    );
};

export default AdminHome;
