import React from 'react';
import { Checkbox, Form, Input, message } from 'antd';
import {
  ArrowRightOutlined,
  LockOutlined,
  MailOutlined,
  ReloadOutlined,
  UserOutlined,
} from '@ant-design/icons';
import { Link, useNavigate } from 'react-router-dom';
import inventoryLogo from '../../assets/inventory-logo.png';
import inventoryRobot from '../../assets/inventory-robot.png';
import { registerApi } from '../../api/auth';
import './RegisterPage.css';

const RegisterPage = () => {
  const navigate = useNavigate();

  const onFinish = async (values) => {
    try {
      await registerApi({
        username: values.email,
        password: values.password,
      });
      message.success('Đăng ký thành công. Tài khoản đang chờ admin xác thực.');
      navigate('/login');
    } catch (e) {
      message.error(e?.response?.data?.message ?? 'Đăng ký thất bại');
    }
  };

  return (
    <main className="login-page register-page">
      <section className="login-shell" aria-label="\u0110\u0103ng k\u00fd t\u00e0i kho\u1ea3n qu\u1ea3n tr\u1ecb kho h\u00e0ng">
        <div className="login-visual">

          <div className="visual-copy">
            <span className="eyebrow logo-eyebrow">
              <img src={inventoryLogo} alt="InventoryTracking" />
            </span>
            <h1>QU&#7842;N TR&#7882; KHO H&#192;NG TH&#212;NG MINH</h1>
            <p>H&#7906;P NH&#7844;T</p>
          </div>

          <div className="avatar-frame" aria-hidden="true">
            <span className="floating-square top" />
            <span className="floating-square bottom" />
            <img className="robot-image" src={inventoryRobot} alt="" />

          </div>
        </div>

        <div className="login-form-panel register-form-panel">
          <div className="login-form-card register-form-card">
            <div className="form-heading">
              <span className="heading-logo">
                <img src={inventoryLogo} alt="InventoryTracking" />
              </span>
              <h2>T&#7841;o t&#224;i kho&#7843;n</h2>
            </div>

            <Form layout="vertical" onFinish={onFinish} requiredMark={false}>
              <div className="input-group">
                <span className="input-label">H&#7885; v&#224; t&#234;n</span>
                <Form.Item
                  name="fullname"
                  rules={[{ required: true, message: 'Vui lòng nhập tài khoản' }]}
                >
                  <Input
                    prefix={<UserOutlined />}
                    placeholder="Nguyễn Văn A"
                    className="custom-input"
                  />
                </Form.Item>
              </div>

              <div className="input-group">
                <span className="input-label">Email</span>
                <Form.Item
                  name="email"
                  rules={[
                    { required: true, message: 'Vui lòng nhập email' },
                    { type: 'email', message: 'Email không hợp lệ' },
                  ]}
                >
                  <Input
                    prefix={<MailOutlined />}
                    placeholder="admin@inventory.vn"
                    className="custom-input"
                  />
                </Form.Item>
              </div>

              <div className="input-group">
                <span className="input-label">M&#7853;t kh&#7849;u</span>
                <Form.Item
                  name="password"
                  rules={[{ required: true, message: 'Vui lòng nhập mật khẩu' }]}
                >
                  <Input.Password
                    prefix={<LockOutlined />}
                    placeholder="Nhập mật khẩu"
                    className="custom-input"
                  />
                </Form.Item>
              </div>

              <div className="input-group">
                <span className="input-label">X&#225;c nh&#7853;n m&#7853;t kh&#7849;u</span>
                <Form.Item
                  name="confirm"
                  dependencies={['password']}
                  rules={[
                    { required: true, message: 'Vui lòng xác nhận mật khẩu' },
                    ({ getFieldValue }) => ({
                      validator(_, value) {
                        if (!value || getFieldValue('password') === value) {
                          return Promise.resolve();
                        }
                        return Promise.reject(new Error('Mật khẩu không khớp'));
                      },
                    }),
                  ]}
                >
                  <Input.Password
                    prefix={<ReloadOutlined />}
                    placeholder="Nhập xác nhận mật khẩu"
                    className="custom-input"
                  />
                </Form.Item>
              </div>

              <Form.Item
                name="agreement"
                valuePropName="checked"
                className="terms-row"
                rules={[
                  {
                    validator: (_, value) =>
                      value
                        ? Promise.resolve()
                        : Promise.reject(new Error('Vui l\u00f2ng \u0111\u1ed3ng \u00fd \u0111i\u1ec1u kho\u1ea3n')),
                  },
                ]}
              >
                <Checkbox>
                  T&#244;i &#273;&#7891;ng &#253; v&#7899;i <span>&#272;i&#7873;u kho&#7843;n d&#7883;ch v&#7909;</span> v&#224;{' '}
                  <span>Ch&#237;nh s&#225;ch b&#7843;o m&#7853;t</span>.
                </Checkbox>
              </Form.Item>

              <button type="submit" className="btn-primary">
                &#272;&#259;ng k&#253; <ArrowRightOutlined />
              </button>
            </Form>

            <p className="register-note">
              &#272;&#227; c&#243; t&#224;i kho&#7843;n? <Link to="/login">&#272;&#259;ng nh&#7853;p</Link>
            </p>
          </div>
        </div>
      </section>
    </main>
  );
};

export default RegisterPage;
