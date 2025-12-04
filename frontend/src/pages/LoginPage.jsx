import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate, Link } from 'react-router-dom';
import './LoginPage.css';

const LoginPage = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [isPanelVisible, setPanelVisible] = useState(false);

  const { login, user } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    // If user is already logged in, redirect them
    if (user) {
      navigate(user.role === 'admin' ? '/admin/home' : '/viewer/home');
    }
  }, [user, navigate]);

  useEffect(() => {
    // Trigger the animation shortly after the component mounts
    const timer = setTimeout(() => setPanelVisible(true), 100);
    return () => clearTimeout(timer);
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    try {
      await login(username, password);
    } catch (err) {
      setError(err.error || 'Failed to login');
    }
  };

  return (
    <div className="login-page">
      <div className="background-overlay"></div>
      <div className="header">
        <h1 className="logo">DRY NEWS</h1>
      </div>
      
      <div className={`login-panel ${isPanelVisible ? 'visible' : ''}`}>
        <div className="login-card">
          <h2>NEWS Login</h2>
          <form onSubmit={handleSubmit}>
            <div className="input-group">
              <input
                type="text"
                placeholder="Username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                required
              />
            </div>
            <div className="input-group">
              <input
                type="password"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
            {error && <p className="error-message">{error}</p>}
            <button type="submit" className="signin-button">Sign In</button>
            <p className="info-text">
              New to Dry News? <Link to="/register" style={{ color: 'white' }}>Sign up now</Link>.
            </p>
            <p className="info-text" style={{ marginTop: '10px' }}>
              Viewer and admin accounts use the same login page.
            </p>
          </form>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;
