import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import ProtectedRoute from './components/ProtectedRoute';

// Page Imports
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
// Viewer pages
import ViewerHome from './pages/ViewerHome';
import ViewerSeriesList from './pages/ViewerSeriesList';
import ViewerSeriesDetail from './pages/ViewerSeriesDetail';
import ViewerMyFeedback from './pages/ViewerMyFeedback';
import ViewerProfile from './pages/ViewerProfile';
import ViewerChangePassword from './pages/ViewerChangePassword';
// Admin pages
import AdminHome from './pages/AdminHome';
import AdminSeriesList from './pages/AdminSeriesList';
import AdminSeriesEdit from './pages/AdminSeriesEdit';
import AdminEpisodes from './pages/AdminEpisodes';
import AdminPhouses from './pages/AdminPhouses';
import AdminProducers from './pages/AdminProducers';
import AdminContracts from './pages/AdminContracts';
import AdminViewers from './pages/AdminViewers';
import AdminFeedback from './pages/AdminFeedback';
import AdminReports from './pages/AdminReports';
import AdminCollaboration from './pages/AdminCollaboration';


function App() {
  return (
    <AuthProvider>
      <Routes>
        {/* Public Routes */}
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />

        {/* Redirect root to a default page */}
        <Route path="/" element={<Navigate to="/login" replace />} />

        {/* Viewer Protected Routes */}
        <Route element={<ProtectedRoute allowedRoles={['viewer']} />}>
          <Route path="viewer/home" element={<ViewerHome />} />
          <Route path="viewer/series" element={<ViewerSeriesList />} />
          <Route path="viewer/series/:sid" element={<ViewerSeriesDetail />} />
          <Route path="viewer/my-feedback" element={<ViewerMyFeedback />} />
          <Route path="viewer/profile" element={<ViewerProfile />} />
          <Route path="viewer/change-password" element={<ViewerChangePassword />} />
        </Route>

        {/* Admin Protected Routes */}
        <Route element={<ProtectedRoute allowedRoles={['admin']} />}>
          <Route path="admin/home" element={<AdminHome />} />
          <Route path="admin/series" element={<AdminSeriesList />} />
          <Route path="admin/series/:sid/edit" element={<AdminSeriesEdit />} />
          <Route path="admin/series/:sid/episodes" element={<AdminEpisodes />} />
          <Route path="admin/phouses" element={<AdminPhouses />} />
          <Route path="admin/producers" element={<AdminProducers />} />
          <Route path="admin/collaboration" element={<AdminCollaboration />} />
          <Route path="admin/contracts" element={<AdminContracts />} />
          <Route path="admin/viewers" element={<AdminViewers />} />
          <Route path="admin/feedback" element={<AdminFeedback />} />
          <Route path="admin/reports" element={<AdminReports />} />
        </Route>

        {/* Fallback for unmatched routes */}
        <Route path="*" element={<h2>404 Not Found</h2>} />
      </Routes>
    </AuthProvider>
  );
}

export default App;
