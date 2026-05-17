import { Progress } from 'antd';
import {
  AuditOutlined,
  CarryOutOutlined,
  DatabaseOutlined,
  ExportOutlined,
  ImportOutlined,
  PlusCircleOutlined,
  WarningOutlined,
} from '@ant-design/icons';
import DashboardLayout from '../components/DashboardLayout';
import './HomePage.css';

const statCards = [
  {
    label: 'Tổng tồn kho',
    value: '5,240',
    note: '+2.5% so với tháng trước',
    tone: 'good',
    icon: <DatabaseOutlined />,
  },
  {
    label: 'Hàng sắp hết',
    value: '12',
    note: 'Cần nhập hàng ngay',
    tone: 'danger',
    icon: <WarningOutlined />,
  },
  {
    label: 'Giao dịch hôm nay',
    value: '+85',
    note: 'Cập nhật: 5 phút trước',
    tone: 'neutral',
    icon: <AuditOutlined />,
  },
];

const quickActions = [
  { label: 'Nhập kho', icon: <ImportOutlined /> },
  { label: 'Xuất kho', icon: <ExportOutlined /> },
  { label: 'Kiểm kho', icon: <CarryOutOutlined /> },
  { label: 'Thêm SP', icon: <PlusCircleOutlined /> },
];

const transactions = [
  { id: '#NK-8821', type: 'Nhập kho', product: 'iPhone 15 Pro Max', quantity: 50, time: '10:45 AM', tone: 'in' },
  { id: '#XK-4523', type: 'Xuất kho', product: 'MacBook Pro M3', quantity: 12, time: '09:12 AM', tone: 'out' },
  { id: '#NK-8820', type: 'Nhập kho', product: 'Samsung Galaxy S24', quantity: 30, time: 'Hôm qua', tone: 'in' },
];

const lowStockItems = [
  { name: 'iPhone 15 Pro', current: 5, target: 50, percent: 10, color: '#c9151b' },
  { name: 'MacBook Pro M3', current: 2, target: 20, percent: 10, color: '#c9151b' },
  { name: 'iPad Air 5', current: 8, target: 40, percent: 20, color: '#f97316' },
];

const HomePage = ({ onLogout, me }) => {
  return (
    <DashboardLayout me={me}>
      <section className="hero-panel">
        <div className="hero-panel__content">
          <h1>Quản lý xuất nhập kho nhanh, chính xác, minh bạch</h1>
          <p>Hệ thống Inventory Intelligence giúp tối ưu hóa luồng hàng hóa và giảm thiểu sai sót vận hành lên đến 40%.</p>
        </div>
      </section>

      <section className="stats-grid" aria-label="Chỉ số kho">
        {statCards.map((card) => (
          <article className={`stat-card stat-card--${card.tone}`} key={card.label}>
            <div>
              <p>{card.label}</p>
              <strong>{card.value}</strong>
              <span>{card.note}</span>
            </div>
            <span className="stat-card__icon">{card.icon}</span>
          </article>
        ))}
      </section>

      <div className="dashboard-grid">
        <section className="quick-section">
          <div className="section-heading">
            <h2>Thao tác nhanh</h2>
          </div>

          <div className="quick-grid">
            {quickActions.map((action) => (
              <button className="quick-card" type="button" key={action.label}>
                <span>{action.icon}</span>
                {action.label}
              </button>
            ))}
          </div>
        </section>

        <section className="alert-panel">
          <div className="alert-panel__title">
            <span>
              <WarningOutlined />
            </span>
            <h2>Cảnh báo tồn kho thấp</h2>
          </div>

          <div className="stock-list">
            {lowStockItems.map((item) => (
              <div className="stock-item" key={item.name}>
                <div>
                  <span>{item.name}</span>
                  <strong style={{ color: item.color }}>
                    {item.current} / {item.target}
                  </strong>
                </div>
                <Progress percent={item.percent} showInfo={false} strokeColor={item.color} trailColor="#fff6f6" size={['100%', 8]} />
              </div>
            ))}
          </div>

          <button className="outline-danger-button" type="button">
            Lập phiếu nhập hàng ngay
          </button>
        </section>

        <section className="transactions-section">
          <div className="section-heading section-heading--split">
            <h2>Giao dịch gần đây</h2>
            <button type="button">Xem tất cả</button>
          </div>

          <div className="transaction-table">
            <div className="transaction-table__head">
              <span>Mã phiếu</span>
              <span>Loại</span>
              <span>Sản phẩm</span>
              <span>Số lượng</span>
              <span>Thời gian</span>
            </div>

            {transactions.map((transaction) => (
              <div className="transaction-row" key={transaction.id}>
                <strong>{transaction.id}</strong>
                <span className={`transaction-badge transaction-badge--${transaction.tone}`}>{transaction.type}</span>
                <span>{transaction.product}</span>
                <span>{transaction.quantity}</span>
                <span>{transaction.time}</span>
              </div>
            ))}
          </div>
        </section>

        <section className="report-card">
          <div>
            <h2>Báo cáo tổng quan</h2>
            <p>Xem xu hướng nhập xuất kho chi tiết theo tuần.</p>
            <button type="button">Mở báo cáo</button>
          </div>
          <div className="report-card__chart" aria-hidden="true">
            <span />
            <span />
            <span />
            <span />
            <span />
          </div>
        </section>
      </div>
    </DashboardLayout>
  );
};

export default HomePage;
