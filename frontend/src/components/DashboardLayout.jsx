import { useState } from 'react';
import { Dropdown } from 'antd';
import {
  AppstoreOutlined,
  BellOutlined,
  ExportOutlined,
  ImportOutlined,
  LockOutlined,
  LogoutOutlined,
  PlusCircleOutlined,
  ProfileOutlined,
  SettingOutlined,
  ShopOutlined,
  UserOutlined,
  MenuFoldOutlined,
  MenuUnfoldOutlined,
  BarChartOutlined,
} from '@ant-design/icons';
import { useNavigate, useLocation } from 'react-router-dom';
import { logoutApi } from '../api/auth';
import { clearAccessToken } from '../auth/token';
import inventoryLogo from '../assets/inventory-logo.png';
import '../pages/HomePage.css';

export default function DashboardLayout({ children, me }) {
  const [isCollapsed, setIsCollapsed] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();

  const isAdmin = (me?.roles ?? []).some((role) => role.code === 'ADMIN');
  const rolesText = (me?.roles ?? []).map((role) => role.code).join(', ') || 'NO_ROLE';

  const handleLogout = async () => {
    try {
      await logoutApi();
    } catch {
      // Ignore
    } finally {
      clearAccessToken();
      window.location.href = '/login';
    }
  };

  const userMenuItems = [
    {
      key: 'profile',
      icon: <UserOutlined />,
      label: 'Hồ sơ cá nhân',
      onClick: () => navigate('/profile'),
    },
    {
      key: 'password',
      icon: <LockOutlined />,
      label: 'Đổi mật khẩu',
      onClick: () => navigate('/change-password'),
    },
    {
      type: 'divider',
    },
    {
      key: 'logout',
      danger: true,
      icon: <LogoutOutlined />,
      label: 'Đăng xuất',
      onClick: handleLogout,
    },
  ];

  const getNavClass = (path) => {
    return location.pathname === path ? 'active' : '';
  };

  return (
    <div className="home-shell">
      <header className="home-topbar">
        <button className="home-brand" type="button" onClick={() => navigate('/')}>
          <img src={inventoryLogo} alt="V-Inventory" />
        </button>

        <label className="home-search" aria-label="Tìm kiếm">
          <span className="home-search__icon">⌕</span>
          <input type="search" placeholder="Tìm kiếm sản phẩm, mã phiếu..." />
        </label>

        <div className="home-toolbar">
          <button className="icon-button" type="button" aria-label="Thông báo">
            <BellOutlined />
          </button>
          <button className="icon-button" type="button" aria-label="Cài đặt">
            <SettingOutlined />
          </button>

          <Dropdown menu={{ items: userMenuItems }} trigger={['click']} placement="bottomRight">
            <button className="user-menu" type="button">
              <span className="user-menu__text">
                <strong>{me?.username || 'Admin User'}</strong>
                <span>{rolesText}</span>
              </span>
              <span className="user-menu__avatar user-menu__avatar--letter">
                {(me?.username || 'Admin').charAt(0).toUpperCase()}
              </span>
            </button>
          </Dropdown>
        </div>
      </header>

      <div className={`home-layout ${isCollapsed ? 'home-layout--collapsed' : ''}`}>
        <aside className="home-sidebar">
          <button 
            className="sidebar-toggle" 
            type="button" 
            onClick={() => setIsCollapsed(!isCollapsed)}
            title={isCollapsed ? "Mở rộng" : "Thu gọn"}
          >
            {isCollapsed ? <MenuUnfoldOutlined /> : <MenuFoldOutlined />}
          </button>

          <nav className="sidebar-nav" aria-label="Điều hướng quản lý kho">
            <button className={getNavClass('/')} type="button" onClick={() => navigate('/')}>
              <AppstoreOutlined /> <span>Bảng điều khiển</span>
            </button>
            <button className={getNavClass('/kho')} type="button">
              <ShopOutlined /> <span>Kho hàng</span>
            </button>
            <button className={getNavClass('/nhap-kho')} type="button">
              <ImportOutlined /> <span>Nhập kho</span>
            </button>
            <button className={getNavClass('/xuat-kho')} type="button">
              <ExportOutlined /> <span>Xuất kho</span>
            </button>
            <button className={getNavClass('/bao-cao')} type="button">
              <BarChartOutlined /> <span>Báo cáo</span>
            </button>
            {isAdmin && (
              <>
                <button className={getNavClass('/admin/users')} type="button" onClick={() => navigate('/admin/users')}>
                  <UserOutlined /> <span>Tài khoản</span>
                </button>
                <button className={getNavClass('/admin/roles')} type="button" onClick={() => navigate('/admin/roles')}>
                  <ProfileOutlined /> <span>Vai trò</span>
                </button>
              </>
            )}
          </nav>

          <button className="create-ticket-button" type="button">
            <PlusCircleOutlined /> <span>Tạo phiếu mới</span>
          </button>
        </aside>

        <main className="home-main">
          {children}
        </main>
      </div>
    </div>
  );
}
