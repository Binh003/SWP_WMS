import React from 'react';
import { Space } from 'antd';
import { MailOutlined, SafetyCertificateOutlined, UserOutlined } from '@ant-design/icons';
import DashboardLayout from '../../components/DashboardLayout';
import '../SubPages.css';

export default function ProfilePage({ me }) {
  const rolesText = (me?.roles ?? []).map((r) => r.code).join(', ') || 'NO_ROLE';
  const initialLetter = (me?.username || 'Admin').charAt(0).toUpperCase();

  return (
    <DashboardLayout me={me}>
      <div className="subpage-container">
        <div className="subpage-header">
          <div className="subpage-header__title">
            <h2>Hồ sơ cá nhân</h2>
            <p>Quản lý và cập nhật thông tin tài khoản của bạn.</p>
          </div>
        </div>

        <div className="premium-card" style={{ padding: 0, overflow: 'hidden' }}>
          <div className="profile-banner" />
          
          <div className="profile-header-wrapper">
            <div className="profile-avatar-glow">
              <div className="profile-avatar-inner">
                {initialLetter}
              </div>
            </div>
            <div className="profile-meta-text">
              <h3>{me?.username || 'Admin User'}</h3>
              <p>
                <SafetyCertificateOutlined style={{ color: 'var(--primary-color)' }} />
                <span className="premium-tag premium-tag--primary">{rolesText}</span>
              </p>
            </div>
          </div>

          <div style={{ padding: '0 32px 32px 32px' }}>
            <div className="premium-card__title">
              Thông tin chi tiết tài khoản
            </div>

            <div className="info-grid">
              <div className="info-item">
                <div className="info-item__label">
                  <UserOutlined style={{ marginRight: 6 }} /> Tên đăng nhập
                </div>
                <div className="info-item__value">
                  {me?.username ?? '-'}
                </div>
              </div>

              <div className="info-item">
                <div className="info-item__label">
                  <MailOutlined style={{ marginRight: 6 }} /> Địa chỉ Email
                </div>
                <div className="info-item__value">
                  {me?.email ?? 'Chưa cập nhật email'}
                </div>
              </div>

              <div className="info-item">
                <div className="info-item__label">Trạng thái hệ thống</div>
                <div className="info-item__value">
                  {me?.enabled ? (
                    <span className="premium-tag premium-tag--success" style={{ margin: 0 }}>ĐANG HOẠT ĐỘNG</span>
                  ) : (
                    <span className="premium-tag premium-tag--neutral" style={{ margin: 0 }}>VÔ HIỆU HÓA</span>
                  )}
                </div>
              </div>

              <div className="info-item">
                <div className="info-item__label">Vai trò truy cập</div>
                <div className="info-item__value">
                  <Space size={6} wrap>
                    {(me?.roles ?? []).length ? (
                      (me.roles ?? []).map((r) => (
                        <span className="premium-tag premium-tag--primary" key={r.code}>
                          {r.code}
                        </span>
                      ))
                    ) : (
                      <span className="premium-tag premium-tag--neutral">NO_ROLE</span>
                    )}
                  </Space>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}
