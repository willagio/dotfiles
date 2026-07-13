---
name: redmine-summary
description: "Fetch and summarize a Redmine issue as an Obsidian note at ~/obsidian-vault/redmine/ISSUE-{id}.md. Use when the user asks to summarize a Redmine issue or create a Redmine note from an issue number or URL."
---

# Redmine Summary Skill

Redmine 이슈를 요약하여 Obsidian 마크다운 노트로 생성한다.

## Invocation

- Claude Code: `/redmine-summary`
- Codex: `$redmine-summary`

## Instructions

### 환경 변수

- `REDMINE_URL`: Redmine 베이스 URL (예: `https://redmine.example.com`)
- `REDMINE_API_KEY`: Redmine API 키

둘 중 하나라도 없으면 사용자에게 설정 안내 후 중단.

### 입력 처리

1. **이슈 번호만 제공**: `#1234` 또는 `1234` → API로 조회
2. **전체 URL 제공**: `https://redmine.example.com/issues/1234` → URL에서 이슈 번호 추출 후 조회
3. **아무것도 없는 경우**: 사용자에게 이슈 번호 또는 URL 요청

### 데이터 조회

Redmine REST API를 사용하여 이슈 데이터를 가져온다.

#### 1단계: 이슈 기본 정보

```bash
curl -s -H "X-Redmine-API-Key: $REDMINE_API_KEY" \
  "$REDMINE_URL/issues/{id}.json?include=journals,attachments,relations,children"
```

#### 2단계: 대용량 이슈 처리

이슈 본문이나 저널이 매우 길 수 있다. 다음 전략을 사용한다:

- **긴 본문**: 전체를 읽되, 요약 시 핵심만 추출
- **많은 저널/노트**: 전체 저널 목록을 시간순으로 읽고, 각 저널에서 핵심 변경사항과 코멘트를 추출
- **저널이 100개 이상**: API 응답에 모든 저널이 포함된다. 누락 없이 전부 처리할 것

#### 3단계: 관련 데이터 보강

- `relations`에 관련 이슈가 있으면 번호와 제목 기록
- `children`에 하위 이슈가 있으면 번호, 제목, 상태 기록
- 첨부파일 목록은 파일명과 설명만 기록 (다운로드 불필요)

### 요약 생성 전략

저널/노트가 많은 이슈를 효과적으로 요약하기 위한 접근법:

1. **타임라인 파악**: 저널을 시간순으로 읽으며 이슈의 흐름을 파악
2. **상태 변경 추적**: 상태(status), 담당자(assigned_to), 우선순위(priority) 변경 이력 추출
3. **핵심 논의 식별**: 단순 상태 변경은 타임라인에만 기록하고, 실질적인 논의/결정사항은 별도 정리
4. **중복 제거**: 같은 내용이 반복되면 최종 결론만 유지

### 출력 포맷

`~/obsidian-vault/redmine/ISSUE-{id}.md`에 저장:

```markdown
---
id: "{id}"
aliases: []
tags:
  - redmine-summary
source: "{REDMINE_URL}/issues/{id}"
project: "{project-name}"
date: YYYY-MM-DD
---

# [{tracker} #{id}] {제목}

## 개요

| 항목 | 내용 |
|------|------|
| 프로젝트 | {project} |
| 트래커 | {tracker} |
| 상태 | {status} |
| 우선순위 | {priority} |
| 담당자 | {assigned_to} |
| 작성자 | {author} |
| 생성일 | {created_on} |
| 최종 수정일 | {updated_on} |
| 완료율 | {done_ratio}% |

## TL;DR
<!-- 이슈의 핵심을 한두 문장으로 요약 -->

## 본문 요약
<!-- 이슈 description의 핵심 내용 정리. 길더라도 빠뜨리지 말고 구조화하여 요약 -->

## 진행 타임라인
<!-- 주요 상태 변경과 마일스톤을 시간순으로 정리 -->
<!-- 형식: - **YYYY-MM-DD** {author}: {변경 내용 요약} -->

## 핵심 논의
<!-- 저널/노트에서 실질적인 논의, 결정사항, 중요 코멘트만 추출 -->
<!-- 단순 상태 변경은 제외, 의미 있는 대화만 포함 -->

## 관련 이슈
<!-- relations과 children 목록. 없으면 섹션 생략 -->

## 첨부파일
<!-- 파일명과 설명. 없으면 섹션 생략 -->
```

### 중요 규칙

- `redmine/` 디렉토리 없으면 생성
- 동일 파일 존재 시 덮어쓰기 전 사용자 확인
- 요약은 한국어로 작성
- TL;DR은 반드시 한두 문장
- 저널이 아무리 많아도 전부 읽고 요약할 것 — 생략 금지
- 관련 이슈, 첨부파일 섹션은 데이터가 없으면 생략
- API 호출 실패 시 에러 메시지를 사용자에게 명확히 전달
- 비공개 노트(private_notes)는 포함하되 `(비공개)` 표시
