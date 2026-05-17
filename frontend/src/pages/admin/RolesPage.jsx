import React, { useEffect, useMemo, useState } from 'react';
import { Button, Form, Input, Select, Space, Switch, message } from 'antd';
import { ReloadOutlined, SaveOutlined, SafetyOutlined } from '@ant-design/icons';
import { getRoleApi, listPermissionsApi, listRolesApi, setRolePermissionsApi } from '../../api/rbac';
import { http } from '../../api/http';
import DashboardLayout from '../../components/DashboardLayout';
import '../SubPages.css';

export default function RolesPage({ me }) {
  const [loading, setLoading] = useState(false);
  const [roles, setRoles] = useState([]);
  const [permissions, setPermissions] = useState([]);
  const [selectedRoleId, setSelectedRoleId] = useState(null);
  const [selectedPermissionCodes, setSelectedPermissionCodes] = useState([]);
  const [saving, setSaving] = useState(false);
  const [roleEnabled, setRoleEnabled] = useState(true);
  const [form] = Form.useForm();

  const roleOptions = useMemo(
    () => roles.map((r) => ({ value: r.id, label: `${r.code}` })),
    [roles]
  );

  const permissionOptions = useMemo(
    () => permissions.map((p) => ({ value: p.code, label: `${p.code}` })),
    [permissions]
  );

  const load = async () => {
    setLoading(true);
    try {
      const [r, p] = await Promise.all([listRolesApi(), listPermissionsApi()]);
      setRoles(r);
      setPermissions(p);
      if (!selectedRoleId && r.length > 0) {
        setSelectedRoleId(r[0].id);
      }
    } catch (e) {
      message.error(e?.response?.data?.message ?? 'Không tải được RBAC data');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    const fetchRole = async () => {
      if (!selectedRoleId) return;
      try {
        const detail = await getRoleApi(selectedRoleId);
        setSelectedPermissionCodes(detail.permissionCodes ?? []);
        setRoleEnabled(!!detail.enabled);
        form.setFieldsValue({ name: detail.name, description: detail.description });
      } catch (e) {
        message.error(e?.response?.data?.message ?? 'Không tải được role detail');
      }
    };
    fetchRole();
  }, [selectedRoleId, form]);

  const onSave = async () => {
    if (!selectedRoleId) return;
    setSaving(true);
    try {
      const values = form.getFieldsValue();
      await http.put(`/api/roles/${selectedRoleId}`, { name: values.name, description: values.description });
      await http.put(`/api/roles/${selectedRoleId}/enabled`, null, { params: { enabled: roleEnabled } });
      await setRolePermissionsApi(selectedRoleId, selectedPermissionCodes);
      message.success('Đã cập nhật permissions cho role');
    } catch (e) {
      message.error(e?.response?.data?.message ?? 'Lưu thất bại');
    } finally {
      setSaving(false);
    }
  };

  return (
    <DashboardLayout me={me}>
      <div className="subpage-container">
        <div className="subpage-header">
          <div className="subpage-header__title">
            <h2>Cấu hình vai trò & quyền</h2>
            <p>Phân quyền hệ thống một cách linh hoạt cho các bộ phận nghiệp vụ.</p>
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
              icon={<SaveOutlined />} 
              onClick={onSave} 
              loading={saving}
              className="premium-btn-primary"
            >
              Lưu thay đổi
            </Button>
          </Space>
        </div>

        <div className="roles-grid">
          {/* Left Column: Role Selector */}
          <div className="premium-card role-select-card">
            <div className="premium-card__title">
              <SafetyOutlined style={{ color: 'var(--primary-color)', marginRight: 8 }} />
              Chọn vai trò
            </div>
            
            <div style={{ marginBottom: 8 }}>
              <label style={{ fontWeight: 700, fontSize: 13, color: 'var(--text-secondary)', display: 'block', marginBottom: 8 }}>
                Danh sách vai trò
              </label>
              <Select
                style={{ width: '100%' }}
                options={roleOptions}
                value={selectedRoleId}
                onChange={setSelectedRoleId}
                className="premium-select"
                popupClassName="premium-select-popup"
              />
            </div>
          </div>

          {/* Right Column: Details form */}
          <div className="premium-card role-detail-card">
            <div className="premium-card__title">Chi tiết phân quyền</div>

            <Form form={form} layout="vertical" requiredMark={false}>
              <Form.Item 
                label="Tên vai trò (Name)" 
                name="name" 
                rules={[{ required: true, message: 'Vui lòng nhập tên role' }]}
              >
                <Input placeholder="Tên vai trò..." />
              </Form.Item>
              
              <Form.Item label="Mô tả chi tiết" name="description">
                <Input.TextArea rows={3} placeholder="Mô tả chức năng nhiệm vụ của vai trò này..." />
              </Form.Item>
            </Form>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr auto', alignItems: 'center', background: 'var(--neutral-light)', padding: '16px 20px', borderRadius: 12, marginBottom: 24 }}>
              <div>
                <strong style={{ display: 'block', color: 'var(--text-primary)' }}>Trạng thái hoạt động</strong>
                <span style={{ fontSize: 12, color: 'var(--text-secondary)' }}>Kích hoạt hoặc tạm thời vô hiệu hóa vai trò này trên hệ thống</span>
              </div>
              <Switch checked={roleEnabled} onChange={setRoleEnabled} />
            </div>

            <div>
              <label style={{ fontWeight: 700, fontSize: 13, color: 'var(--text-primary)', display: 'block', marginBottom: 8 }}>
                Danh sách quyền hạn (Permissions)
              </label>
              <Select
                mode="multiple"
                style={{ width: '100%' }}
                options={permissionOptions}
                value={selectedPermissionCodes}
                onChange={setSelectedPermissionCodes}
                placeholder="Chọn permissions cho vai trò này..."
                className="premium-select-multiple"
              />
            </div>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}
