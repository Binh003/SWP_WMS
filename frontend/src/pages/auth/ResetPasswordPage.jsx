import React, { useMemo, useState } from 'react'
import { Button, Card, Form, Input, Space, Typography, message } from 'antd'
import { Link, useLocation, useNavigate } from 'react-router-dom'
import { resetPasswordApi } from '../../api/auth'

function useQuery() {
  const { search } = useLocation()
  return useMemo(() => new URLSearchParams(search), [search])
}

export default function ResetPasswordPage() {
  const q = useQuery()
  const navigate = useNavigate()
  const [loading, setLoading] = useState(false)

  const initialToken = q.get('token') ?? ''

  const onFinish = async (values) => {
    setLoading(true)
    try {
      await resetPasswordApi({ token: values.token, newPassword: values.newPassword })
      message.success('Đặt lại mật khẩu thành công, vui lòng đăng nhập')
      navigate('/login')
    } catch (e) {
      message.error(e?.response?.data?.message ?? 'Reset password thất bại')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{ padding: 24, maxWidth: 520, margin: '0 auto' }}>
      <Space direction="vertical" style={{ width: '100%' }} size={16}>
        <div>
          <Typography.Title level={3} style={{ margin: 0 }}>Reset password</Typography.Title>
          <Typography.Text type="secondary">Nhập token và mật khẩu mới.</Typography.Text>
        </div>

        <Card>
          <Form layout="vertical" onFinish={onFinish} requiredMark={false} initialValues={{ token: initialToken }}>
            <Form.Item label="Token" name="token" rules={[{ required: true, message: 'Vui lòng nhập token' }]}>
              <Input placeholder="reset token" />
            </Form.Item>

            <Form.Item
              label="Mật khẩu mới"
              name="newPassword"
              rules={[
                { required: true, message: 'Vui lòng nhập mật khẩu mới' },
                { min: 6, message: 'Mật khẩu tối thiểu 6 ký tự' },
              ]}
            >
              <Input.Password placeholder="mật khẩu mới" />
            </Form.Item>

            <Form.Item
              label="Xác nhận mật khẩu mới"
              name="confirmNewPassword"
              dependencies={['newPassword']}
              rules={[
                { required: true, message: 'Vui lòng xác nhận mật khẩu mới' },
                ({ getFieldValue }) => ({
                  validator(_, value) {
                    if (!value || getFieldValue('newPassword') === value) return Promise.resolve()
                    return Promise.reject(new Error('Mật khẩu xác nhận không khớp'))
                  },
                }),
              ]}
            >
              <Input.Password placeholder="nhập lại mật khẩu mới" />
            </Form.Item>

            <Button type="primary" htmlType="submit" loading={loading} block>
              Reset
            </Button>
          </Form>
        </Card>

        <Typography.Text type="secondary">
          <Link to="/login">Quay lại đăng nhập</Link>
        </Typography.Text>
      </Space>
    </div>
  )
}
