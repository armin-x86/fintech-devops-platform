export type Asset = {
  id: string;
  nominal_value: number;
  status: 'active' | 'defaulted' | 'paid';
  due_date: string;
};

export function AssetsTable({ assets }: { assets: Asset[] }) {
  return (
    <section>
      <h2 style={{ fontSize: 18, fontWeight: 600, marginBottom: 12 }}>Assets</h2>
      <div style={{ overflowX: 'auto', border: '1px solid #e5e7eb', borderRadius: 10 }}>
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead style={{ background: '#f9fafb' }}>
            <tr>
              {['ID', 'Nominal value', 'Status', 'Due date'].map((h) => (
                <th
                  key={h}
                  style={{
                    textAlign: 'left',
                    padding: 10,
                    fontSize: 12,
                    color: '#374151',
                    borderBottom: '1px solid #e5e7eb',
                  }}
                >
                  {h}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {assets.map((a) => (
              <tr key={a.id}>
                <td style={{ padding: 10, borderBottom: '1px solid #f3f4f6' }}>
                  <code>{a.id}</code>
                </td>
                <td style={{ padding: 10, borderBottom: '1px solid #f3f4f6' }}>
                  {a.nominal_value.toLocaleString(undefined, { maximumFractionDigits: 2 })}
                </td>
                <td style={{ padding: 10, borderBottom: '1px solid #f3f4f6' }}>{a.status}</td>
                <td style={{ padding: 10, borderBottom: '1px solid #f3f4f6' }}>{a.due_date}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
  );
}

