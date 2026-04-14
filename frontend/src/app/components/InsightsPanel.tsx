export type Insight = {
  id: string;
  name: string;
  value: number;
};

function formatValue(name: string, value: number) {
  if (name.includes('rate')) return `${(value * 100).toFixed(2)}%`;
  if (name.includes('value') || name.includes('debt')) return value.toLocaleString(undefined, { maximumFractionDigits: 2 });
  return value.toString();
}

export function InsightsPanel({ insights }: { insights: Insight[] }) {
  return (
    <section>
      <h2 style={{ fontSize: 18, fontWeight: 600, marginBottom: 12 }}>Portfolio insights</h2>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: 12 }}>
        {insights.map((i) => (
          <div
            key={i.id}
            style={{
              border: '1px solid #e5e7eb',
              borderRadius: 10,
              padding: 12,
              background: '#fff',
            }}
          >
            <div style={{ fontSize: 12, color: '#6b7280', marginBottom: 6 }}>{i.name}</div>
            <div style={{ fontSize: 20, fontWeight: 700 }}>{formatValue(i.name, i.value)}</div>
          </div>
        ))}
      </div>
    </section>
  );
}

