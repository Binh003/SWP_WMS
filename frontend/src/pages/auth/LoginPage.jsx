import React from 'react';
import { Form, Input, Checkbox, message } from 'antd';
import { LockOutlined, MailOutlined } from '@ant-design/icons';
import { Link, useNavigate } from 'react-router-dom';
import { loginApi } from '../../api/auth';
import { setAccessToken } from '../../auth/token';
import inventoryLogo from '../../assets/inventory-logo.png';
import inventoryRobot from '../../assets/inventory-robot.png';
import './LoginPage.css';

const LoginPage = ({ onLogin }) => {
  const navigate = useNavigate();

  const onFinish = async (values) => {
    try {
      const data = await loginApi({
        username: values.username,
        password: values.password,
      });
      setAccessToken(data.accessToken);
      if (onLogin) await onLogin(data.user);
      message.success('Ch\u00e0o m\u1eebng tr\u1edf l\u1ea1i!');
      navigate('/');
    } catch (e) {
      message.error(e?.response?.data?.message ?? '\u0110\u0103ng nh\u1eadp th\u1ea5t b\u1ea1i');
    }
  };

  return (
    <main className="login-page">
      <section className="login-shell" aria-label="\u0110\u0103ng nh\u1eadp qu\u1ea3n tr\u1ecb kho h\u00e0ng">
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

        <div className="login-form-panel">
          <div className="login-form-card">
            <div className="form-heading">
              <span className="heading-logo">
                <img src={inventoryLogo} alt="InventoryTracking" />
              </span>
              <h2>&#272;&#259;ng nh&#7853;p</h2>
            </div>

            <Form layout="vertical" onFinish={onFinish} requiredMark={false}>
              <div className="input-group">
                <span className="input-label">T&#224;i kho&#7843;n</span>
                <Form.Item
                  name="username"
                  rules={[{ required: true, message: 'Vui lòng nhập tài khoản' }]}
                >
                  <Input
                    prefix={<MailOutlined />}
                    placeholder="Nhập tài khoản"
                    className="custom-input"
                  />
                </Form.Item>
              </div>

              <div className="input-group">
                <div className="label-row">
                  <span className="input-label">M&#7853;t kh&#7849;u</span>
                  
                </div>
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
                <div className="label-row">
                  <Link to="/forgot-password">Qu&#234;n m&#7853;t kh&#7849;u?</Link>
                </div>
              </div>

              <Form.Item name="remember" valuePropName="checked" className="remember-row">
                <Checkbox>Ghi nh&#7899; &#273;&#259;ng nh&#7853;p</Checkbox>
              </Form.Item>

              <button type="submit" className="btn-primary">
                &#272;&#259;ng nh&#7853;p
              </button>
            </Form>

            <p className="register-note">
              Ch&#432;a c&#243; t&#224;i kho&#7843;n? <Link to="/register">Li&#234;n h&#7879; qu&#7843;n tr&#7883; vi&#234;n</Link>
            </p>
          </div>
        </div>
      </section>
    </main>
  );
};

export default LoginPage;
