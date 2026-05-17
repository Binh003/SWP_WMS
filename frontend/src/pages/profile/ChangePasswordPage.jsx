import React, { useState } from 'react';
import { Button, Form, Input, message } from 'antd';
import { KeyOutlined } from '@ant-design/icons';
import { changePasswordApi } from '../../api/auth';
import DashboardLayout from '../../components/DashboardLayout';
import '../SubPages.css';

export default function ChangePasswordPage({ me }) {
  const [saving, setSaving] = useState(false);
  const [form] = Form.useForm();

  const onFinish = async (values) => {
    setSaving(true);
    try {
      await changePasswordApi({
        currentPassword: values.currentPassword,
        newPassword: values.newPassword,
      });
      message.success('Đổi mật khẩu thành công');
      form.resetFields();
    } catch (e) {
      message.error(e?.response?.data?.message ?? 'Đổi mật khẩu thất bại');
    } finally {
      setSaving(false);
    }
  };

  return (
    <DashboardLayout me={me}>
      <div className="subpage-container" style={{ maxWidth: 720 }}>
        <div className="subpage-header">
          <div className="subpage-header__title">
            <h2>Đổi mật khẩu</h2>
            <p>Cập nhật mật khẩu đăng nhập bảo mật cho tài khoản của bạn.</p>
          </div>
        </div>

        <div className="premium-card">
          <div className="premium-card__title">
            <KeyOutlined style={{ color: 'var(--primary-color)', marginRight: 8 }} />
            Đổi mật khẩu đăng nhập
          </div>

          <Form form={form} layout="vertical" onFinish={onFinish} requiredMark={false}>
            <Form.Item
              label="Mật khẩu hiện tại"
              name="currentPassword"
              rules={[{ required: true, message: 'Vui lòng nhập mật khẩu hiện tại' }]}
            >
              <Input.Password placeholder="Nhập mật khẩu hiện tại" />
            </Form.Item>

            <Form.Item
              label="Mật khẩu mới"
              name="newPassword"
              rules={[
                { required: true, message: 'Vui lòng nhập mật khẩu mới' },
                { min: 6, message: 'Mật khẩu tối thiểu 6 ký tự' },
              ]}
            >
              <Input.Password placeholder="Nhập mật khẩu mới" />
            </Form.Item>

            <Form.Item
              label="Xác nhận mật khẩu mới"
              name="confirmNewPassword"
              dependencies={['newPassword']}
              rules={[
                { required: true, message: 'Vui lòng xác nhận mật khẩu mới' },
                ({ getFieldValue }) => ({
                  validator(_, value) {
                    if (!value || getFieldValue('newPassword') === value) return Promise.resolve();
                    return Promise.reject(new Error('Mật khẩu xác nhận không khớp'));
                  },
                }),
              ]}
            >
              <Input.Password placeholder="Nhập lại mật khẩu mới" />
            </Form.Item>

            <div style={{ marginTop: 24 }}>
              <Button 
                type="primary" 
                htmlType="submit" 
                loading={saving}
                className="premium-btn-primary"
                style={{ width: '100%' }}
              >
                Đổi mật khẩu
              </Button>
            </div>
          </Form>
        </div>
      </div>
    </DashboardLayout>
  );
}
