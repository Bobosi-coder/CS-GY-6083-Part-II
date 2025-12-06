import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import axiosClient from '../api/axiosClient';
import { Link } from 'react-router-dom';
import NavBar from '../components/NavBar';

//——————————XYK——————————
import { 
    LineChart, 
    Line, 
    BarChart,
    Bar,
    ComposedChart,
    XAxis, 
    YAxis, 
    CartesianGrid, 
    Tooltip, 
    Legend, 
    ResponsiveContainer 
} from 'recharts';
////////___________XYK_________



const AdminHome = () => {
    const { user, logout } = useAuth();
    const [stats, setStats] = useState(null);
    const [error, setError] = useState('');

    useEffect(() => {
        axiosClient.get('/admin/stats')
            .then(setStats)
            .catch(err => setError(err.error || 'Could not fetch dashboard stats'));
    }, []);


    //________XYK__________
    const [viewerGrowth, setViewerGrowth] = useState([]);

    useEffect(() => {
        axiosClient.get("/admin/viewer-growth")
            .then(data => {
                console.log(data);
                setViewerGrowth(data);
            })
            .catch(err => {
                console.error(err);
            });
    }, []);

    const [revenueGrowth, setRevenueGrowth] = useState([]);

    useEffect(() => {
        axiosClient.get("/admin/revenue-growth")
            .then(data => {
                console.log("Revenue Data:", data);
                setRevenueGrowth(data);
            })
            .catch(err => {
                console.error(err);
            });
    }, []);

    ///////________XYK_________


    return (
        <>
            <NavBar />
            <div className="page">
                <div className="page-inner">
                    <div className="page-header">
                        <h1 className="page-title">Admin Dashboard</h1>
                        {/* <div className="inline-actions">
                            <Link className="btn btn-secondary" to="/admin/series">Series</Link>
                            <Link className="btn btn-secondary" to="/admin/phouses">Prod. Houses</Link>
                            <Link className="btn btn-secondary" to="/admin/producers">Producers</Link>
                            <Link className="btn btn-secondary" to="/admin/contracts">Contracts</Link>
                            <Link className="btn btn-secondary" to="/admin/viewers">Viewers</Link>
                            <Link className="btn btn-secondary" to="/admin/feedback">Feedback</Link>
                            <Link className="btn btn-secondary" to="/admin/reports">Reports</Link>
                            <button className="btn btn-danger" onClick={logout}>Logout</button>
                        </div> */}
                    </div>
                    <div className="card">
                        <h2>Welcome, {user.display_name}!</h2>
                        {error && <p className="muted">{error}</p>}
                        {stats ? (
                            <div>
                                <div className="grid" style={{gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))'}}>
                                    <div className="card">
                                        <h4>Total Series</h4>
                                        <p style={{fontSize: '2rem'}}>{stats.total_series}</p>
                                    </div>
                                    <div className="card">
                                        <h4>Total Viewers</h4>
                                        <p style={{fontSize: '2rem'}}>{stats.total_viewers}</p>
                                    </div>
                                    <div className="card">
                                        <h4>Total Feedback</h4>
                                        <p style={{fontSize: '2rem'}}>{stats.total_feedback}</p>
                                    </div>
                                    <div className="card">
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
                            <p className="muted">Loading stats...</p>
                        )}
                    </div>

                    {/* //________XYK________ */}

                    <div className="card" style={{ marginTop: "2rem" }}>
                        <h3>Viewer Growth Over Time</h3>
                        <ResponsiveContainer width="100%" height={300}>
                            <LineChart data={viewerGrowth}>
                                <CartesianGrid strokeDasharray="3 3" />
                                <XAxis dataKey="month" />
                                <YAxis />

                                <Tooltip
                                    contentStyle={{ 
                                        backgroundColor: '#1a1a2e', 
                                        border: '1px solid #666',
                                        borderRadius: '4px'
                                    }}
                                    labelStyle={{ 
                                        fontWeight: "bold", 
                                        color: '#ffffff',
                                        marginBottom: '5px'
                                    }}
                                    itemStyle={{ color: '#ffffff' }}
                                />
                                <Legend />
                                <Line 
                                    type="monotone" 
                                    dataKey="new_viewers" 
                                    stroke="#ffffff" 
                                    strokeWidth={2}
                                    name="New Viewers"
                                />
                            </LineChart>
                        </ResponsiveContainer>
                    </div>


                    <div className="card" style={{ marginTop: "2rem" }}>
                        <h3>Revenue Growth Over Time</h3>
                        <ResponsiveContainer width="100%" height={300}>
                            <ComposedChart data={revenueGrowth}>
                                <XAxis dataKey="month" />
                                <YAxis yAxisId="left" stroke="#ffffffff" >
                                    <CartesianGrid strokeDasharray="3 3" />
                                </YAxis>
                                <YAxis yAxisId="right" orientation="right" stroke="#ffffff" >
                                
                                </YAxis>
                                <Tooltip
                                    contentStyle={{ 
                                        backgroundColor: '#1a1a2e', 
                                        border: '1px solid #666',
                                        borderRadius: '4px'
                                    }}
                                    labelStyle={{ 
                                        fontWeight: "bold", 
                                        color: '#ffffff',
                                        marginBottom: '5px'
                                    }}
                                    itemStyle={{ color: '#ffffff' }}
                                />
                                <Legend />
                                
                                <Bar 
                                    yAxisId="right"
                                    dataKey="revenue_new" 
                                    fill="#396182ff"
                                    name="New Revenue"
                                    barSize={30}
                                />
                                
                                <Line 
                                    yAxisId="left"
                                    type="monotone"
                                    dataKey="revenue_total"
                                    stroke="#ffffffff"
                                    strokeWidth={2}
                                    name="Total Revenue"
                                />
                            </ComposedChart>
                        </ResponsiveContainer>
                    </div>
                    {/* ///////________XYK________ */}

                </div>
            </div>
        </>
    );
};

export default AdminHome;
