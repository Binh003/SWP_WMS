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

   
}
