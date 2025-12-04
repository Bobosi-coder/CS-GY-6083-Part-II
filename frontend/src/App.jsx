import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import ProtectedRoute from './components/ProtectedRoute';

// Page Imports
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
// Viewer pages
import ViewerHome from './pages/ViewerHome';
// Admin pages
import AdminHome from './pages/AdminHome';

// Dummy components for pages to be created
const ViewerSeriesList = () => <h2>Viewer Series List</h2>;
const ViewerSeriesDetail = () => <h2>Viewer Series Detail</h2>;
const ViewerMyFeedback = () => <h2>My Feedback</h2>;
const ViewerProfile = () => <h2>My Profile</h2>;
const ViewerChangePassword = () => <h2>Change Password</h2>;

const AdminSeriesList = () => <h2>Admin Series List</h2>;
const AdminSeriesEdit = () => <h2>Admin Series Edit</h2>;
const AdminEpisodes = () => <h2>Admin Episodes</h2>;
const AdminPhouses = () => <h2>Admin Production Houses</h2>;
const AdminProducers = () => <h2>Admin Producers</h2>;
const AdminContracts = () => <h2>Admin Contracts</h2>;
const AdminViewers = () => <h2>Admin Viewers</h2>;
const AdminFeedback = () => <h2>Admin Feedback</h2>;
import AdminReports from './pages/AdminReports';
const AdminCollaboration = () => <h2>Admin Collaborations</h2>;


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