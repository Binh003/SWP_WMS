import React, { useEffect, useState } from 'react';
import { BrowserRouter, Route, Routes, Navigate } from 'react-router-dom';
import 'antd/dist/reset.css';
import './index.css';
import LoginPage from './pages/auth/LoginPage';
import RegisterPage from './pages/auth/RegisterPage';
import ForgotPasswordPage from './pages/auth/ForgotPasswordPage';
import ResetPasswordPage from './pages/auth/ResetPasswordPage';
import HomePage from './pages/HomePage';
import UsersPage from './pages/admin/UsersPage';
import RolesPage from './pages/admin/RolesPage';
import ProfilePage from './pages/profile/ProfilePage';
import ChangePasswordPage from './pages/profile/ChangePasswordPage';
import { clearAccessToken, getAccessToken } from './auth/token';
import { meApi } from './api/auth';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(!!getAccessToken());
  const [me, setMe] = useState(null);

  const refreshAuth = async (optimisticMe = null) => {
    const token = getAccessToken();
    if (!token) {
      setIsAuthenticated(false);
      setMe(null);
      return;
    }

    // Allow callers (login) to set immediate auth state from response,
    // then we re-check with /me to keep the client in sync.
    if (optimisticMe) {
      setIsAuthenticated(true);
      setMe(optimisticMe);
    }

    try {
      const data = await meApi();
      setIsAuthenticated(true);
      setMe(data);
    } catch {
      clearAccessToken();
      setIsAuthenticated(false);
      setMe(null);
    }
  };

  useEffect(() => {
    refreshAuth();
  }, []);

  return (
    <BrowserRouter>
      <Routes>
        <Route 
          path="/login" 
          element={
            isAuthenticated ? 
            <Navigate to="/" replace /> : 
            <LoginPage onLogin={refreshAuth} />
          } 
        />
        <Route 
          path="/register" 
          element={
            isAuthenticated ? 
            <Navigate to="/" replace /> : 
            <RegisterPage />
          } 
        />
        <Route
          path="/forgot-password"
          element={isAuthenticated ? <Navigate to="/" replace /> : <ForgotPasswordPage />}
        />
        <Route
          path="/reset-password"
          element={isAuthenticated ? <Navigate to="/" replace /> : <ResetPasswordPage />}
        />
        <Route 
          path="/" 
          element={
            isAuthenticated ? 
            <HomePage me={me} onLogout={refreshAuth} /> : 
            <Navigate to="/login" replace />
          } 
        />
        <Route
          path="/profile"
          element={
            !isAuthenticated ? (
              <Navigate to="/login" replace />
            ) : !me ? (
              <div style={{ padding: 24 }}>Loading...</div>
            ) : (
              <ProfilePage me={me} />
            )
          }
        />
        <Route
          path="/change-password"
          element={
            !isAuthenticated ? (
              <Navigate to="/login" replace />
            ) : (
              <ChangePasswordPage me={me} />
            )
          }
        />
        <Route
          path="/admin/users"
          element={
            !isAuthenticated ? (
              <Navigate to="/login" replace />
            ) : !me ? (
              <div style={{ padding: 24 }}>Loading...</div>
            ) : !(me.roles ?? []).some((r) => r.code === 'ADMIN') ? (
              <Navigate to="/" replace />
            ) : (
              <UsersPage me={me} />
            )
          }
        />
        <Route
          path="/admin/roles"
          element={
            !isAuthenticated ? (
              <Navigate to="/login" replace />
            ) : !me ? (
              <div style={{ padding: 24 }}>Loading...</div>
            ) : !(me.roles ?? []).some((r) => r.code === 'ADMIN') ? (
              <Navigate to="/" replace />
            ) : (
              <RolesPage me={me} />
            )
          }
        />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
