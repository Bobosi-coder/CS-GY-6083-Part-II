import React from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

const NavBar = () => {
  const { user, logout } = useAuth();

  const viewerLinks = [
    { to: '/viewer/home', label: 'Home' },
    { to: '/viewer/series', label: 'Series' },
    { to: '/viewer/my-feedback', label: 'My Feedback' },
    { to: '/viewer/profile', label: 'Profile' },
    { to: '/viewer/change-password', label: 'Password' },
  ];

  const adminLinks = [
    { to: '/admin/home', label: 'Dashboard' },
    { to: '/admin/series', label: 'Series' },
    { to: '/admin/phouses', label: 'Prod. Houses' },
    { to: '/admin/producers', label: 'Producers' },
    { to: '/admin/collaboration', label: 'Collab' },
    { to: '/admin/contracts', label: 'Contracts' },
    { to: '/admin/viewers', label: 'Viewers' },
    { to: '/admin/feedback', label: 'Feedback' },
    { to: '/admin/reports', label: 'Reports' },
    { to: '/admin/history', label: 'History' },
  ];

  const links = user?.role === 'admin' ? adminLinks : viewerLinks;

  return (
    <header className="nav">
      <div className="nav-left">
        <Link className="nav-logo" to={user?.role === 'admin' ? '/admin/home' : '/viewer/home'}>
          DRY NEWS
        </Link>
        <div className="nav-links">
          {links.map((l) => (
            <Link key={l.to} to={l.to}>{l.label}</Link>
          ))}
        </div>
      </div>
      <div className="nav-right">
        {user && <span className="muted">Hi, {user.display_name}</span>}
        <button className="btn btn-secondary" onClick={logout}>Logout</button>
      </div>
    </header>
  );
};

export default NavBar;
