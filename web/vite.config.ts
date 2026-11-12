import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    // 개발 중에는 /api 요청을 FastAPI 개발 서버(8000번)로 넘긴다
    proxy: {
      '/api': 'http://127.0.0.1:8000',
    },
  },
})
