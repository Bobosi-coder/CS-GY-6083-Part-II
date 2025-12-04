import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

const ProtectedRoute = ({ allowedRoles }) => {
  const { user, loading } = useAuth();

  if (loading) {
    return <div>Loading...</div>; // Or a spinner component
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  if (allowedRoles && !allowedRoles.includes(user.role)) {
    // User is logged in but does not have the required role
    return <Navigate to={user.role === 'admin' ? '/admin/home' : '/viewer/home'} replace />;
  }

  return <Outlet />;
};

export default ProtectedRoute;
