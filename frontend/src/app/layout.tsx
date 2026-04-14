export const metadata = {
  title: 'Portfolio Dashboard',
  description: 'Asset-backed lending portfolio metrics',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body style={{ fontFamily: 'system-ui, -apple-system, Segoe UI, Roboto, sans-serif' }}>
        {children}
      </body>
    </html>
  );
}

