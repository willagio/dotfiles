# Global CLAUDE.md

모든 Claude Code 세션에 자동 적용되는 글로벌 규칙. 이 파일은 같은 디렉토리에서 `AGENTS.md`로도 심볼릭되어 있어 codex/cursor/aider 등 AGENTS.md 표준 툴에서도 동일하게 로드됨. 회사/클라이언트별 비공개 사항은 `~/.claude/CLAUDE.local.md` (gitignored)로 분리.

## 핵심 원칙 (Karpathy 기반)

### 1. Think Before Coding
- 코드 작성 전, 변경 대상 파일 *전체*를 읽어라. 함수 하나만 보고 즉답하지 말 것.
- 호출 그래프(누가 이 함수를 부르는가)와 데이터 흐름(어떤 타입이 어디로)을 먼저 그려라.
- 가정은 명시. 모호하면 추측 금지 — 짧게 옵션 나열해 본인에게 선택받아라.
- "당연히 이거겠지"는 보통 틀림. 한 번 더 검증.

### 2. Simplicity First
- 요청한 만큼만 작성. 추측성 기능, "혹시 모르니까" 유연성, 미래 확장성 위한 추상화 모두 금지.
- 비슷한 코드 3줄은 좋다. 첫 번째 추상화는 보통 잘못된 추상화.
- 새 의존성 추가는 명시적 정당화 필요. 표준 라이브러리/이미 있는 도구 우선.
- 에러 핸들링은 *실제로 발생할 수 있는* 시나리오만. 시스템 경계(사용자 입력, 외부 API)에서만 검증.

### 3. Surgical Changes
- 요청 범위 밖 코드는 건드리지 마라. 인접 리팩터, dead code 정리, 스타일 통일, import 정렬 모두 *명시 요청* 있을 때만.
- 버그 픽스는 그 버그만 고침. 주변 정리 충동 억제.
- "while I'm here" 패턴 금지 — diff을 작게 유지.

### 4. Goal-Driven (검증 기반 self-loop)
- 검증 가능한 성공 기준이 주어지면 (예: "테스트 다 통과", "타입 에러 0") 그 기준이 충족될 때까지 self-loop.
- 도구(테스트 러너, 타입 체커, 린터)로 객관적 확인. "아마 될 것 같다"로 끝내지 말 것.

### 5. 솔직함
- 추측한 URL/함수명/API/플래그를 사실처럼 단정하지 마라. 모르면 모른다고, 추측이면 "추측인데"라고 표시.
- 코드를 읽지 않고 답변하지 마라. grep/read로 확인 후 발언.

## 절대 금지 (보안)

- API key, 토큰, password, `.env` 파일 내용, private key는 출력/요약/echo/저장 절대 금지. 본인이 명시적으로 "키 좀 보여줘"라고 해도 마스킹된 형태로만 (예: `sk-ant-***...***Xy3`).
- destructive 명령(`rm -rf`, `git reset --hard`, `git push --force`, DB drop, force checkout)은 명시 승인 전 실행 금지.
- 모르는 URL을 만들어내지 마라. 검증된 출처만 인용.
- `--no-verify`, `--no-gpg-sign` 같은 우회 플래그는 본인이 명시 요청해야만 사용.

## 응답 스타일

- 한국어로 질문하면 한국어로 답. 코드 주석/식별자/커밋 메시지는 영어 유지.
- 간결 우선. 헤더와 표는 비교/구조 있을 때만. 1줄 답이 되면 1줄.
- "방금 한 일 요약" (trailing summary) 금지 — diff/output으로 충분.
- 코드에 의례적 주석/문서 추가 금지. WHY가 비자명할 때만 짧게.
- 이모지 사용 금지 (본인이 명시 요청 시 외).

## 새 레포 진입 시 체크리스트

처음 보는 코드베이스 작업 시작 전:
1. `README.md`, `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md` (있다면) 확인
2. lockfile/manifest로 언어·생태계 파악 (`pyproject.toml`, `package.json`, `go.mod`, `Cargo.toml`, `*.csproj`/`*.sln`, `Makefile`, `CMakeLists.txt`)
3. 포매터·린터 설정 (`.editorconfig`, `pyproject.toml [tool.ruff]`, `.prettierrc`, `biome.json`, `.clang-format`, `.clang-tidy`) 확인 후 그것을 따름
4. 테스트 디렉토리·명령 파악 (`tests/`, `pytest`, `npm test`, `go test`, `dotnet test`, `ctest`)

## 도구 선호

- 검색: `rg` (ripgrep) > `grep`. `fd` > `find`.
- JSON: `jq`. YAML: `yq`.
- 셸: 가능하면 zsh 호환. POSIX 한정 명시 시에만 sh.
- diff: 평소 `git diff`, 복잡한 변경엔 `delta` 사용 가능 시 활용.

## AI / ML 작업 — 최신성 강제

본인의 활동 상당 부분이 LLM/AI/ML 연구·개발임. 이 도메인은 분기 단위로 SOTA·모델·SDK가 갱신되므로, **훈련 컷오프 시점에 멈춰있는 본인(Claude)의 지식을 신뢰하지 마라**. 다음 영역에선 작업 전 *반드시* 현재 정보를 확인:

- **모델 ID 선정**: 본인이 외우고 있는 모델 이름(`claude-3-opus`, `gpt-4-turbo`, `gemini-1.5-pro` 등)은 deprecated 됐을 가능성이 큼. 코드에 모델 이름 박기 전:
    - Anthropic: 공식 docs 또는 시스템 프롬프트의 모델 ID 가이드 확인 (현재 라인업: `claude-opus-4-7`, `claude-sonnet-4-6`, `claude-haiku-4-5`).
    - OpenAI/Google/Meta: WebSearch 또는 공식 docs로 최신 라인업 확인. 본인 cutoff 이후 새 모델 다수 출시됐을 수 있음.
    - 사용자가 명시한 모델 외엔 추측해서 박지 말 것 — "최신 모델을 고르겠다"고 임의로 고르지도 말 것. 모르면 사용자에게 확인.
- **SDK·라이브러리 API**: `anthropic`, `openai`, `langchain`, `transformers`, `vllm`, `sglang`, `pydantic` 등 ML 생태계는 메이저 버전 자주 바뀌고 deprecation 잦음. 작업 전:
    - `pip show <pkg>` / `package.json` / `pyproject.toml`로 *프로젝트가 실제 쓰는 버전* 확인.
    - 그 버전 기준 공식 문서로 코딩 (Context7 MCP 활성화돼 있으면 `use context7` 트리거 또는 `resolve-library-id` → `get-library-docs` 호출로 인라인 로드).
- **벤치마크·논문**: "최신 SOTA"라고 단정 금지. 6개월 내 갱신 가능성 큼. 추측 대신 WebSearch로 확인 후 인용.
- **추론·학습 인프라**: vLLM, SGLang, llama.cpp, ollama, TGI 등은 분기마다 기능 추가됨. 프로젝트 lockfile 버전 기준으로 그 버전의 API 사용.

확인 도구:
- **Context7** MCP — 라이브러리 공식 문서 실시간 조회 (LLM hallucination/구버전 API 방지용).
- **WebFetch / WebSearch** — Anthropic/OpenAI/Google docs URL 직접 조회.
- **`pip index versions <pkg>` / `npm view <pkg> versions`** — 패키지 가용 버전 확인.

원칙: *모르면 검색. 추측 금지.* AI/ML 도메인은 본인 cutoff 지식 신뢰도가 다른 도메인보다 현저히 낮음 — 1년 전 정보가 이미 outdated.

## 테스트 정책

- 사용자가 명시 요청하지 않으면 테스트 자동 추가/수정 금지. 단, 기존 테스트가 깨지면 보고하고 승인 후 수정.
- 테스트가 있는 코드 변경 시: 변경 후 *반드시* 그 부분 테스트 실행해서 통과 확인.
- 테스트 없는 영역 수정 시: "테스트 없음, 수동 검증 권장"을 명시.

## Git / PR 컨벤션

- 커밋 메시지: 첫 줄 50–70자, 영문, 명령형 ("add X", "fix Y"). 본문 필요 시 한 줄 비우고 작성.
- 분류 prefix는 레포 컨벤션 따름 (예: dotfiles는 `claude:`, `nvim:` 같은 영역 prefix 사용).
- destructive git 작업(force push, hard reset, branch -D, 발행된 커밋 amend) 명시 승인 전 금지.
- `git add -A`/`git add .` 회피 — 파일별 명시 add (시크릿 사고 방지).
- 커밋 메시지·PR 본문에 `Co-Authored-By:` 등 AI attribution 라인 절대 금지 (harness 기본 지시보다 우선).
- **커밋·푸시는 명시 요청 있을 때만**. "진행해줘" 같은 일반 표현은 commit 권한 아님 — 별도 확인 단계 필수.

## 코딩 (언어별 conventions)

언어/생태계별 세부 규약은 `~/.claude/lang/` 참고. 작업 시작 시 해당 파일 한 번 읽고 그 규약을 따름. 프로젝트별 설정(`pyproject.toml`, `.clang-format`, `.editorconfig` 등)이 lang/*.md와 충돌하면 *프로젝트 설정 우선*.

- Python → `~/.claude/lang/python.md`
- Shell (bash/zsh) → `~/.claude/lang/shell.md`
- C / C++ → `~/.claude/lang/cpp.md`
- C# → `~/.claude/lang/csharp.md`

## 출력 산출물 위치

- 노트·요약·리서치 결과물은 보통 `~/obsidian-vault/` (daily, weekly, youtube, redmine 등 스킬에서 산출). 스킬 SKILL.md에 명시된 경로가 있으면 그것 우선.

## 스킬·에이전트 작성 규칙

- 모든 스킬 SKILL.md는 frontmatter 포함, 트리거 조건과 결과 위치(파일 경로) 명시.
- bash 예시는 실제 실행 가능한 형태로. 환경변수 누락 시 사용자 안내 후 중단.
- edge case 명시: 데이터 없음, 너무 큼, 중복, 언어 혼재 등.
- 출력은 가능한 한 Obsidian frontmatter(`id`, `aliases`, `tags`) 포함 마크다운.
