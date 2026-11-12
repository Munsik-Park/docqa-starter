#!/usr/bin/env bash
# 개발자 AI 도입 과정 사전 점검
#
# 실행: bash scripts/precheck.sh
# 레포를 받기 전이면 강사가 안내한 주소에서 이 파일만 받아 bash로 실행합니다.
# 결과 화면 전체를 캡처해 강사에게 보냅니다. 이 스크립트는 아무것도 설치하거나 고치지 않습니다.
#
# 표시
#   OK       필요한 조건을 만족함
#   MISSING  설치돼 있지 않음 (3장에서 설치)
#   WARN     설치는 됐지만 확인이 필요함
#
# macOS 기본 bash(3.2)에서도 돌도록 배열, 연관 배열, ${var,,} 같은 문법은 쓰지 않습니다.

missing=0
warned=0

ok()   { printf 'OK       %-8s %s\n' "$1" "$2"; }
miss() { printf 'MISSING  %-8s %s\n' "$1" "$2"; missing=$((missing + 1)); }
warn() { printf 'WARN     %-8s %s\n' "$1" "$2"; warned=$((warned + 1)); }

# 버전 a가 b 이상이면 0을 돌려준다. 점으로 나눈 숫자를 앞에서부터 비교한다.
version_ge() {
  awk -v a="$1" -v b="$2" 'BEGIN {
    na = split(a, x, "."); nb = split(b, y, ".")
    n = (na > nb) ? na : nb
    for (i = 1; i <= n; i++) {
      xi = (i <= na) ? x[i] + 0 : 0
      yi = (i <= nb) ? y[i] + 0 : 0
      if (xi > yi) exit 0
      if (xi < yi) exit 1
    }
    exit 0
  }'
}

echo "== 컴퓨터 =="

os="$(uname -s)"
if [ "$os" = "Darwin" ]; then
  ver="$(sw_vers -productVersion)"
  if version_ge "$ver" 13; then ok macOS "$ver"; else warn macOS "$ver (13 이상 필요)"; fi
  mem_bytes="$(sysctl -n hw.memsize)"
elif [ "$os" = "Linux" ]; then
  name="unknown"; ver=""
  if [ -r /etc/os-release ]; then
    name="$(. /etc/os-release && echo "$ID")"
    ver="$(. /etc/os-release && echo "$VERSION_ID")"
  fi
  if [ "$name" = "ubuntu" ] && version_ge "$ver" 20.04; then
    ok Linux "Ubuntu $ver"
  elif [ "$name" = "ubuntu" ]; then
    warn Linux "Ubuntu $ver (20.04 이상 필요)"
  else
    warn Linux "$name $ver (강의는 Ubuntu 기준)"
  fi
  mem_bytes="$(awk '/^MemTotal:/ {print $2 * 1024}' /proc/meminfo)"
else
  warn OS "$os (macOS 또는 Linux만 지원)"
  mem_bytes=0
fi

# 4GB 장비도 운영체제가 일부를 잡아 3.7GiB 안팎으로 보이므로 3.5GiB를 기준으로 본다.
mem_gib="$(awk -v b="$mem_bytes" 'BEGIN { printf "%.1f", b / 1024 / 1024 / 1024 }')"
if awk -v g="$mem_gib" 'BEGIN { exit !(g >= 3.5) }'; then
  ok RAM "${mem_gib} GiB"
else
  warn RAM "${mem_gib} GiB (4GB 이상 필요)"
fi

echo
echo "== 도구 =="

for c in git gh code uv docker claude codex; do
  if ! command -v "$c" >/dev/null 2>&1; then
    case "$c" in
      code) miss code "VS Code를 설치했다면 명령 팔레트에서 Shell Command: Install 'code' command in PATH 실행" ;;
      *)    miss "$c" "" ;;
    esac
    continue
  fi
  ok "$c" "$("$c" --version 2>/dev/null | head -1)"
done

# Node.js: Vite가 20.19 이상 또는 22.12 이상을 요구한다 (vite.dev/guide).
if ! command -v node >/dev/null 2>&1; then
  miss node "20.19 이상 또는 22.12 이상 필요"
else
  nv="$(node --version | sed 's/^v//')"
  major="${nv%%.*}"
  if { [ "$major" -eq 20 ] && version_ge "$nv" 20.19; } ||
     { [ "$major" -eq 22 ] && version_ge "$nv" 22.12; } ||
     [ "$major" -ge 23 ]; then
    ok node "v$nv"
  else
    warn node "v$nv (20.19 이상 또는 22.12 이상 필요)"
  fi
fi

# Docker는 설치만이 아니라 데몬이 떠 있어야 쓸 수 있다.
if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    ok docker "데몬 실행 중"
  else
    warn docker "데몬에 연결할 수 없음 (macOS는 Docker Desktop 실행, Linux는 sudo 없이 쓰도록 docker 그룹 확인)"
  fi
fi

echo
echo "== 계정과 설정 =="

if command -v git >/dev/null 2>&1; then
  if [ -n "$(git config --global user.name)" ] && [ -n "$(git config --global user.email)" ]; then
    ok git "user.name, user.email 설정됨"
  else
    warn git "user.name 또는 user.email 미설정 (4장에서 설정)"
  fi
fi

if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then
    ok gh "GitHub 로그인됨"
  else
    warn gh "GitHub 로그인 안 됨 (gh auth login, 4장에서 진행)"
  fi
fi

# ANTHROPIC_API_KEY가 셸 전역에 있으면 Claude Code가 구독 대신 API 키로 과금된다.
if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  warn KEY "ANTHROPIC_API_KEY가 셸에 설정됨 (Claude Code가 API로 과금됨, ~/.zshrc나 ~/.bashrc에서 지우세요)"
else
  ok KEY "셸에 ANTHROPIC_API_KEY 없음"
fi

if command -v claude >/dev/null 2>&1; then
  echo
  echo "== claude doctor =="
  claude doctor < /dev/null 2>&1
fi

echo
echo "== 결과 =="
echo "MISSING ${missing}개, WARN ${warned}개"
if [ "$missing" -gt 0 ]; then
  exit 1
fi
exit 0
