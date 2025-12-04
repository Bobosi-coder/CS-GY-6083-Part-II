import React, { createContext, useState, useContext, useEffect } from 'react';
import axiosClient from '../api/axiosClient';
import { useNavigate } from 'react-router-dom';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    // Check if user is logged in on mount
    axiosClient.get('/me')
      .then(data => {
        if (data.logged_in) {
          setUser(data.user);
        }
      })
      .catch(() => {
        setUser(null);
      })
      .finally(() => {
        setLoading(false);
      });
  }, []);

  const login = async (username, password) => {
    try {
      const { user: loggedInUser } = await axiosClient.post('/login', { username, password });
      setUser(loggedInUser);
      // Redirect based on role
      if (loggedInUser.role === 'admin') {
        navigate('/admin/home');
      } else if (loggedInUser.role === 'viewer') {
        navigate('/viewer/home');
      }
    } catch (error) {
      console.error('Login failed:', error);
      throw error; // Re-throw to be caught by the login form
    }
  };

  const register = async (userData) => {
    try {
      const { user: registeredUser } = await axiosClient.post('/register', userData);
      setUser(registeredUser);
      // Redirect after registration
      navigate('/viewer/home');
    } catch (error) {
        console.error('Registration failed:', error);
        throw error;
    }
  };

  const logout = async () => {
    try {
      await axiosClient.post('/logout');
      setUser(null);
      navigate('/login');
    } catch (error) {
      console.error('Logout failed:', error);
    }
  };

  const authValue = {
    user,
    setUser,
    login,
    register,
    logout,
    loading
  };

  return (
    <AuthContext.Provider value={authValue}>
      {!loading && children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  return useContext(AuthContext);
};
