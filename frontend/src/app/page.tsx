import { InsightsPanel, type Insight } from './components/InsightsPanel';
import { AssetsTable, type Asset } from './components/AssetsTable';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

async function getAssets(): Promise<Asset[]> {
  const res = await fetch(`${API_URL}/assets`, { cache: 'no-store' });
  if (!res.ok) throw new Error('Failed to fetch assets');
  return res.json();
}

async function getInsights(): Promise<Insight[]> {
  const res = await fetch(`${API_URL}/insights`, { cache: 'no-store' });
  if (!res.ok) throw new Error('Failed to fetch insights');
  return res.json();
}

export default async function Home() {
  const [assets, insights] = await Promise.all([getAssets(), getInsights()]);
  return (
    <main style={{ maxWidth: 1100, margin: '0 auto', padding: 24 }}>
      <h1 style={{ fontSize: 28, fontWeight: 700, marginBottom: 16 }}>Portfolio Dashboard</h1>
      <p style={{ marginBottom: 16, color: '#555' }}>
        Data source: <code>{API_URL}</code>
      </p>
      <InsightsPanel insights={insights} />
      <div style={{ height: 16 }} />
      <AssetsTable assets={assets} />
    </main>
  );
}
