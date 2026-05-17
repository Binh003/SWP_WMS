import React, { useEffect, useMemo, useState } from 'react';
import { Button, Drawer, Form, Input, Select, Space, Switch, Table, message } from 'antd';
import { PlusOutlined, ReloadOutlined, UsergroupAddOutlined, EditOutlined, EyeOutlined } from '@ant-design/icons';
import { createUserApi, listUsersApi, setUserEnabledApi, setUserRolesApi, updateUserApi } from '../../api/users';
import { listRolesApi } from '../../api/rbac';
import DashboardLayout from '../../components/DashboardLayout';
import '../SubPages.css';

export default function UsersPage({ me }) {
  const [loading, setLoading] = useState(false);
  const [rows, setRows] = useState([]);
  const [roles, setRoles] = useState([]);
  const [drawerOpen, setDrawerOpen] = useState(false);
  const [editingUser, setEditingUser] = useState(null);
  const [isReadOnly, setIsReadOnly] = useState(false);
  const [saving, setSaving] = useState(false);
  const [form] = Form.useForm();

  const roleOptions = useMemo(() => roles.map((r) => ({ value: r.code, label: r.code })), [roles]);

  const load = async () => {
    setLoading(true);
    try {
      const [u, r] = await Promise.all([listUsersApi(), listRolesApi()]);
      setRows(u);
      setRoles(r);
    } catch (e) {
      message.error(e?.response?.data?.message ?? 'Không tải được danh sách người dùng');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const openCreate = () => {
    setEditingUser(null);
    setIsReadOnly(false);
    form.resetFields();
    form.setFieldsValue({ roleCodes: ['VIEWER'], enabled: true });
    setDrawerOpen(true);
  };

  const openEdit = (u) => {
    setEditingUser(u);
    setIsReadOnly(false);
    form.resetFields();
    form.setFieldsValue({
      username: u.username,
      fullName: u.fullName,
      email: u.email,
      roleCodes: (u.roles ?? []).map((r) => r.code),
      enabled: !!u.enabled,
    });
    setDrawerOpen(true);
  };

  const openView = (u) => {
    setEditingUser(u);
    setIsReadOnly(true);
    form.resetFields();
    form.setFieldsValue({
      username: u.username,
      fullName: u.fullName,
      email: u.email,
      roleCodes: (u.roles ?? []).map((r) => r.code),
      enabled: !!u.enabled,
    });
    setDrawerOpen(true);
  };

  const onSaveUser = async (values) => {
    setSaving(true);
    try {
      if (!editingUser) {
        await createUserApi({
          username: values.username,
          fullName: values.fullName,
          email: values.email,
          password: values.password,
          roleCodes: values.roleCodes,
        });
        message.success('Đã tạo user');
      } else {
        await updateUserApi(editingUser.id, { fullName: values.fullName, email: values.email });
        await setUserRolesApi(editingUser.id, values.roleCodes);
        await setUserEnabledApi(editingUser.id, values.enabled);
        message.success('Đã cập nhật user');
      }
      setDrawerOpen(false);
      await load();
    } catch (e) {
      message.error(e?.response?.data?.message ?? 'Lưu thất bại');
    } finally {
      setSaving(false);
    }
  };

  const onToggleEnabled = async (userId, enabled) => {
    try {
      await setUserEnabledApi(userId, enabled);
      setRows((prev) => prev.map((u) => (u.id === userId ? { ...u, enabled } : u)));
      message.success(enabled ? 'Đã kích hoạt tài khoản' : 'Đã vô hiệu hóa tài khoản');
    } catch (e) {
      message.error(e?.response?.data?.message ?? 'Cập nhật trạng thái thất bại');
    }
  };

  const onChangeRoles = async (userId, roleCodes) => {
    try {
      await setUserRolesApi(userId, roleCodes);
      setRows((prev) =>
        prev.map((u) =>
          u.id === userId ? { ...u, roles: roleCodes.map((c) => ({ code: c, name: c })) } : u
        )
      );
      message.success('Đã cập nhật vai trò');
    } catch (e) {
      message.error(e?.response?.data?.message ?? 'Cập nhật vai trò thất bại');
    }
  };

  const columns = [
    {
      title: 'ID',
      dataIndex: 'id',
      width: 80,
      render: (id) => <strong style={{ color: 'var(--text-secondary)' }}>#{id}</strong>,
    },
    {
      title: 'Tài khoản',
      dataIndex: 'username',
      render: (text) => (
        <span style={{ fontWeight: 700, color: 'var(--text-primary)' }}>{text}</span>
      ),
    },
    {
      title: 'Họ và tên',
      width: 260,
      dataIndex: 'fullName',
    },
    {
      title: 'Email',
      dataIndex: 'email',
    },
    {
      title: 'Vai trò (Roles)',
      dataIndex: 'roles',
      width: 220,
      render: (roles, record) => (
        <Select
          mode="multiple"
          value={(roles ?? []).map((r) => r.code)}
          style={{ width: '100%' }}
          options={roleOptions}
          onChange={(v) => onChangeRoles(record.id, v)}
          className="premium-select-multiple"
          disabled={record.username === 'admin'}
        />
      ),
    },
    {
      title: 'Trạng thái',
      dataIndex: 'enabled',
      width: 140,
      render: (enabled) => (
        enabled ? (
          <span className="premium-tag premium-tag--success">ENABLED</span>
        ) : (
          <span className="premium-tag premium-tag--neutral">DISABLED</span>
        )
      ),
    },
    {
      title: 'Kích hoạt',
      dataIndex: 'enabled',
      width: 100,
      render: (enabled, record) => (
        <Switch 
          checked={enabled} 
          onChange={(v) => onToggleEnabled(record.id, v)} 
          disabled={record.username === 'admin'}
        />
      ),
    },
    {
      title: 'Hành động',
      key: 'actions',
      width: 180,
      render: (_, record) => (
        <Space size={8}>
          <Button 
            size="small" 
            icon={<EyeOutlined />}
            onClick={() => openView(record)}
            className="premium-btn-outline premium-btn-table"
          >
            Xem
          </Button>
          <Button 
            size="small" 
            icon={<EditOutlined />}
            onClick={() => openEdit(record)}
            className="premium-btn-outline premium-btn-table"
            disabled={record.username === 'admin'}
          >
            Sửa
          </Button>
        </Space>
      ),
    },
  ];

  return (
    <DashboardLayout me={me}>
      <div className="subpage-container">
        <div className="subpage-header">
          <div className="subpage-header__title">
            <h2>Quản lý tài khoản</h2>
            <p>Phê duyệt tài khoản đăng ký mới và cập nhật phân quyền truy cập hệ thống.</p>
          </div>
          <Space size={12}>
            <Button 
              icon={<ReloadOutlined />} 
              onClick={load} 
              loading={loading}
              className="premium-btn-outline"
            >
              Tải lại
            </Button>
            <Button 
              type="primary" 
              icon={<PlusOutlined />} 
              onClick={openCreate}
              className="premium-btn-primary"
            >
              Thêm thành viên
            </Button>
          </Space>
        </div>

        <div className="premium-card" style={{ padding: 20 }}>
          <Table
            rowKey="id"
            loading={loading}
            columns={columns}
            dataSource={rows}
            pagination={{ pageSize: 10 }}
            className="premium-table"
            scroll={{ x: 'max-content' }}
          />
        </div>

        <Drawer
          title={
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <UsergroupAddOutlined style={{ color: 'var(--primary-color)' }} />
              <span>
                {isReadOnly 
                  ? `Chi tiết tài khoản #${editingUser?.id}` 
                  : editingUser 
                    ? `Thông tin tài khoản #${editingUser.id}` 
                    : 'Thêm thành viên mới'}
              </span>
            </div>
          }
          open={drawerOpen}
          onClose={() => setDrawerOpen(false)}
          width={480}
          destroyOnClose
          className="premium-drawer"
        >
          <Form layout="vertical" form={form} onFinish={onSaveUser} requiredMark={false}>
            <Form.Item 
              label="Tên đăng nhập (Username)" 
              name="username" 
              rules={[{ required: true, message: 'Vui lòng nhập username' }]}
            >
              <Input disabled={true} placeholder="Username tài khoản..." />
            </Form.Item>
            
            <Form.Item 
              label="Họ và tên" 
              name="fullName" 
              rules={[{ required: true, message: 'Vui lòng nhập họ tên' }]}
            >
              <Input disabled={isReadOnly} placeholder="Nguyễn Văn A..." />
            </Form.Item>
            
            <Form.Item
              label="Địa chỉ Email"
              name="email"
              rules={[
                { required: true, message: 'Vui lòng nhập email' }, 
                { type: 'email', message: 'Email không hợp lệ' }
              ]}
            >
              <Input disabled={isReadOnly} placeholder="email@example.com..." />
            </Form.Item>

            {!editingUser && (
              <Form.Item
                label="Mật khẩu đăng nhập"
                name="password"
                rules={[
                  { required: true, message: 'Vui lòng nhập mật khẩu' }, 
                  { min: 6, message: 'Tối thiểu 6 ký tự' }
                ]}
              >
                <Input.Password disabled={isReadOnly} placeholder="Mật khẩu bảo mật..." />
              </Form.Item>
            )}

            <Form.Item label="Vai trò (Roles)" name="roleCodes" style={{ marginBottom: 24 }}>
              <Select 
                mode="multiple" 
                options={roleOptions} 
                placeholder="Gán vai trò hệ thống..." 
                disabled={isReadOnly}
              />
            </Form.Item>

            {!!editingUser && (
              <div style={{ display: 'grid', gridTemplateColumns: '1fr auto', alignItems: 'center', background: 'var(--neutral-light)', padding: '16px 20px', borderRadius: 12, marginBottom: 32 }}>
                <div>
                  <strong style={{ display: 'block', color: 'var(--text-primary)' }}>Trạng thái tài khoản</strong>
                  <span style={{ fontSize: 12, color: 'var(--text-secondary)' }}>Kích hoạt hoặc chặn quyền truy cập của người dùng này</span>
                </div>
                <Form.Item name="enabled" valuePropName="checked" style={{ margin: 0 }}>
                  <Switch disabled={isReadOnly} />
                </Form.Item>
              </div>
            )}

            <Space size={12} style={{ width: '100%', justifyContent: 'flex-end', marginTop: 24 }}>
              <Button onClick={() => setDrawerOpen(false)} disabled={saving} className="premium-btn-outline" style={{ height: '40px !important' }}>
                {isReadOnly ? 'Đóng' : 'Hủy bỏ'}
              </Button>
              {!isReadOnly && (
                <Button type="primary" htmlType="submit" loading={saving} className="premium-btn-primary" style={{ height: '40px !important' }}>
                  Lưu tài khoản
                </Button>
              )}
            </Space>
          </Form>
        </Drawer>
      </div>
    </DashboardLayout>
  );
}
