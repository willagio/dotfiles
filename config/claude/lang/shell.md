# Shell (bash / zsh) conventions

## 모든 스크립트 첫 줄

```bash
#!/usr/bin/env bash
set -euo pipefail
```

zsh 스크립트는 `#!/usr/bin/env zsh` + `setopt err_exit nounset pipefail`.

## 도구

- 린터: `shellcheck`. 작성 후 직접 실행 또는 CI.
- 포매터: `shfmt -i 4 -ci -bn` (4 spaces, switch case 들여쓰기, binary op 줄 시작).
- 호환성: 본인 dotfiles 스크립트는 macOS + Ubuntu 모두에서 동작해야 함. BSD/GNU 차이 (`sed -i`, `date`, `readlink -f`, `mktemp`) 주의.

## 스타일

- 변수: `"$var"` 항상 쿼트. `"${arr[@]}"`도 쿼트.
- 함수: `func() { ... }`. `function func` 키워드 회피 (POSIX 비호환).
- 조건문: `[[ ... ]]` (bash/zsh). `[ ... ]`은 POSIX 한정 시.
- 명령 결과: `$(...)`. 백틱 금지.
- 비교: 문자열 `=`, 정수 `-eq` `-lt` 등, 파일 `-f` `-d` `-L`.

## Idempotent 패턴 (dotfiles 스크립트)

"이미 설정되어 있나?" 검사 후 작업 — 본인 `scripts/agents.sh` 패턴:

```bash
if [[ -L "$DST" ]] && [[ "$(readlink "$DST")" == "$SRC" ]]; then
    log "already symlinked"
else
    [[ -e "$DST" ]] && mv "$DST" "$DST.backup.$(date +%s)"
    ln -sf "$SRC" "$DST"
fi
```

destructive 작업 전 timestamped 백업 필수.

## 금기

- `eval` — 보안 위험. 우회 가능하면 우회.
- unquoted `cd $foo` — `cd` 자체도 가능하면 회피, 절대경로 사용.
- 파이프 에러 무시: `set -o pipefail` 필수.
- subshell 안에서 변수 export 후 외부 사용 — 작동 안 함.

## 검증

```bash
shellcheck script.sh && shfmt -d script.sh
```
