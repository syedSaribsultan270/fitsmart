export function SpecTable({ headers, rows }) {
  return (
    <div style={{
      background: 'var(--glass-bg)',
      backdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
      WebkitBackdropFilter: 'blur(var(--blur-lg)) saturate(180%)',
      border: '0.5px solid var(--glass-border)',
      borderRadius: 'var(--r-xl)',
      overflow: 'hidden',
      boxShadow: 'var(--glass-shadow), var(--glass-specular)',
      marginBottom: 24,
    }}>
      <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 15 }}>
        <thead>
          <tr>
            {headers.map((h, i) => (
              <th key={i} style={{
                textAlign: 'left', padding: '12px 20px',
                borderBottom: '0.5px solid var(--separator)',
                fontWeight: 600, color: 'var(--label)',
                background: 'var(--fill-tertiary)',
              }}>{h}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row, i) => (
            <tr key={i}>
              {row.map((cell, j) => (
                <td key={j} style={{
                  padding: '10px 20px',
                  borderBottom: i < rows.length - 1 ? '0.5px solid var(--separator)' : 'none',
                  color: j === 0 ? 'var(--label)' : 'var(--label-secondary)',
                  fontWeight: j === 0 ? 500 : 400,
                  fontFamily: typeof cell === 'string' && cell.startsWith('--') ? 'var(--font-mono)' : 'inherit',
                  fontSize: typeof cell === 'string' && cell.startsWith('--') ? 13 : 'inherit',
                }}>{cell}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
