import React, { useState } from 'react'
import { Button, Card, Form, Input, Space, Typography, message } from 'antd'
import { Link } from 'react-router-dom'
import { forgotPasswordApi } from '../../api/auth'

export default function ForgotPasswordPage() {
  const [loading, setLoading] = useState(false)
  const [token, setToken] = useState(null)

  const onFinish = async (values) => {
    setLoading(true)
    setToken(null)
    try {
      const res = await forgotPasswordApi({ usernameOrEmail: values.usernameOrEmail })
      setToken(res.resetToken ?? null)
      message.success('Nếu tài khoản tồn tại, hệ thống đã tạo yêu cầu đặt lại mật khẩu')
    } catch (e) {
      message.error(e?.response?.data?.message ?? 'Thao tác thất bại')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{ padding: 24, maxWidth: 520, margin: '0 auto' }}>
      <Space direction="vertical" style={{ width: '100%' }} size={16}>
        <div>
          <Typography.Title level={3} style={{ margin: 0 }}>Quên mật khẩu</Typography.Title>
          <Typography.Text type="secondary">
            Nhập username hoặc email. (Dev mode: hệ thống sẽ trả về reset token)
          </Typography.Text>
        </div>

        <Card>
          <Form layout="vertical" onFinish={onFinish} requiredMark={false}>
            <Form.Item
              label="Username hoặc Email"
              name="usernameOrEmail"
              rules={[{ required: true, message: 'Vui lòng nhập username hoặc email' }]}
            >
              <Input placeholder="admin / admin@..." />
            </Form.Item>

            <Button type="primary" htmlType="submit" loading={loading} block>
              Tạo reset token
            </Button>
          </Form>

          {token && (
            <div style={{ marginTop: 16 }}>
              <Typography.Text strong>Reset token:</Typography.Text>
              <pre style={{ marginTop: 8, padding: 12, background: '#0b1220', color: '#e2e8f0', borderRadius: 8, overflowX: 'auto' }}>
{token}
              </pre>
              <Typography.Text type="secondary">
                Đi tới <Link to={`/reset-password?token=${encodeURIComponent(token)}`}>Reset password</Link>
              </Typography.Text>
            </div>
          )}
        </Card>

        <Typography.Text type="secondary">
          <Link to="/login">Quay lại đăng nhập</Link>
        </Typography.Text>
      </Space>
    </div>
  )
}
