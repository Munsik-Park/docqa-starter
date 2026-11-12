import { useEffect, useState } from 'react'

type Health = 'checking' | 'ok' | 'down'

function App() {
  const [health, setHealth] = useState<Health>('checking')

  useEffect(() => {
    fetch('/api/health')
      .then((res) => (res.ok ? res.json() : Promise.reject(res.status)))
      .then((body: { status: string }) => setHealth(body.status === 'ok' ? 'ok' : 'down'))
      .catch(() => setHealth('down'))
  }, [])

  const label = {
    checking: '백엔드 확인 중',
    ok: '백엔드 연결됨',
    down: '백엔드에 연결할 수 없음',
  }[health]

  return (
    <main>
      <h1>문서 Q&amp;A</h1>
      <p className={`status status-${health}`}>{label}</p>
      <p className="hint">
        기능은 아직 없습니다. 명세를 쓰고 이슈를 나눈 뒤 하나씩 만듭니다.
      </p>
    </main>
  )
}

export default App
