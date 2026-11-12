# 문서 Q&A 서비스 시작 레포

개발자 AI 도입 과정의 실습 레포입니다. 과정 내내 이 레포 하나에 "개발팀 문서 Q&A 서비스"를 만들어 갑니다. 지금은 기능이 없고, 백엔드와 프론트엔드가 서로 연결되는지만 확인하는 빈 골격입니다. 기능은 명세를 쓰고 이슈로 나눈 뒤 하나씩 만듭니다.

## 내 계정으로 복사하기

이 레포에 직접 PR을 올리지 않습니다. 각자 자기 계정에 복사한 레포에서 이슈, 브랜치, PR, 머지까지 모두 합니다.

1. 레포 화면 오른쪽 위 **Use this template** > **Create a new repository**를 누릅니다.
2. Owner를 내 계정으로 고르고, 이름을 정해 만듭니다.
3. 만든 레포를 내 컴퓨터로 클론합니다.

```bash
gh repo clone <내 계정>/<레포 이름>
cd <레포 이름>
```

## 구조

```text
.
├─ backend/          FastAPI 백엔드 (Python, uv로 관리)
│  ├─ app/           서버 코드. main.py가 진입점
│  └─ tests/         pytest 테스트
├─ web/              React + TypeScript 프론트엔드 (Vite)
├─ sample-docs/      서비스에 넣어 볼 샘플 문서 (가상 회사의 사내 문서)
├─ scripts/
│  └─ precheck.sh    개발 환경 사전 점검
└─ .github/          이슈 템플릿, PR 템플릿
```

## 필요한 도구

| 도구 | 버전 |
| --- | --- |
| uv | Python은 uv가 `backend/.python-version`(3.13)을 보고 알아서 받습니다 |
| Node.js | 20.19 이상 또는 22.12 이상 (Vite 요구 사항) |
| git, GitHub CLI(`gh`) | 최신 |

설치가 됐는지는 사전 점검 스크립트로 확인합니다.

```bash
bash scripts/precheck.sh
```

`MISSING`이 있으면 그 도구를 설치하고 다시 돌립니다. `WARN`은 내용을 읽고 판단합니다.

## 처음 실행

이 절의 명령은 모두 실제로 돌려 확인했습니다.
확인: 2026-11-12 | uv 0.11.32, Python 3.13.18, Node 22.23.4, npm 10.9.9 | Ubuntu 24.04 x86_64
확인: 2026-11-12 | uv 0.13.4, Python 3.13.16, Node 22.23.4 | Ubuntu 22.04 arm64 (서버 실행은 빼고 테스트, lint, build만)
확인: macOS 미검증

### 백엔드 테스트

```bash
cd backend
uv sync
uv run pytest
```

`2 passed`가 나오면 됩니다.

### 백엔드 서버

```bash
cd backend
uv run fastapi dev app/main.py
```

브라우저에서 <http://127.0.0.1:8000/api/health>를 열면 `{"status":"ok"}`가 보입니다. <http://127.0.0.1:8000/docs>에는 FastAPI가 만든 API 문서가 있습니다. DB는 SQLite이고 파일은 `backend/data/docqa.db`에 생깁니다. 이 폴더는 커밋하지 않습니다.

### 프론트엔드

백엔드 서버를 켜 둔 채로 터미널을 하나 더 엽니다.

```bash
cd web
npm install
npm run dev
```

<http://localhost:5173>을 열면 "백엔드 연결됨"이 보입니다. 개발 중에는 `/api`로 가는 요청을 Vite가 8000번 백엔드로 넘깁니다(`web/vite.config.ts`).

프론트엔드 검사와 빌드는 다음 두 명령입니다.

```bash
npm run lint
npm run build
```

## 이슈와 PR

- 이슈는 "기능"과 "버그" 템플릿 중에서 고릅니다. 기능 이슈에는 목적, 할 일, 완료 기준, 하지 않을 것을 적습니다.
- PR을 열면 템플릿의 점검 목록이 채워집니다. 모두 확인한 뒤 머지합니다.

## 비밀 값

API 키와 봇 토큰은 `.env`에만 둡니다. `.env`는 `.gitignore`에 들어 있어 커밋되지 않습니다. 셸 설정 파일(`~/.zshrc`, `~/.bashrc`)에 키를 넣지 않습니다.

## 아직 없는 것

과정이 진행되며 하나씩 붙입니다: 에이전트 규칙 문서(AGENTS.md), 훅, 린터 설정, CI, Dockerfile.
