---
name: redmine-session
description: "Load a Redmine issue into the current conversation for questions, analysis, and incremental refreshes without creating a file. Use when the user asks to open, inspect, refresh, or discuss a Redmine issue by number or URL."
---

# Redmine Session Skill

Redmine 이슈를 불러와 현재 대화의 컨텍스트로 깔아두고, 그 이슈에 대한 질문·작업을 이어간다. 파일은 만들지 않는다 (요약 노트가 필요하면 `redmine-summary` 사용).

## Invocation

- Claude Code: `/redmine-session`
- Codex: `$redmine-session`

## Instructions

### 환경 변수

- `REDMINE_URL`: Redmine 베이스 URL (예: `https://redmine.example.com`)
- `REDMINE_API_KEY`: Redmine API 키

둘 중 하나라도 없으면 사용자에게 설정 안내 후 중단.

### 입력 처리

인자는 **이슈 식별자 + (선택) 질문**이 자유 형식으로 섞여 들어온다. 위치 인자로 가정하지 말 것.

1. **이슈 식별자 추출**: 입력에서 이슈 번호를 찾는다.
   - `#1234` 또는 `1234` → 그 번호
   - 전체 URL `https://redmine.example.com/issues/1234` → URL에서 번호 추출
   - 식별자가 없으면 사용자에게 이슈 번호/URL 요청 후 중단
2. **질문 추출**: 이슈 식별자를 뺀 나머지 텍스트가 있으면 그것을 "후속 질문"으로 본다.
   - 예: `1234 이거 왜 막혔지?` → 이슈 1234 로드 + "이거 왜 막혔지?"에 답
   - 예: `#1234` → 이슈 1234 로드만
   - 예: `https://.../issues/1234 마지막 논의 정리해줘` → 로드 + 정리 요청 수행

### 데이터 조회

Redmine REST API로 이슈 데이터를 가져온다. `redmine-summary`와 동일한 호출을 사용한다.

```bash
curl -s -H "X-Redmine-API-Key: $REDMINE_API_KEY" \
  "$REDMINE_URL/issues/{id}.json?include=journals,attachments,relations,children"
```

- **긴 본문/많은 저널**: 전부 읽어 컨텍스트에 유지. 후속 질문이 어느 부분을 가리킬지 모르므로 임의 생략 금지.
- **저널 100개 이상**: API 응답에 전부 포함됨. 누락 없이 읽되, 브리핑에는 핵심만 노출.
- `relations`/`children`은 번호·제목·상태만 파악해 둔다.
- 첨부파일은 목록(파일명·설명)만 파악. 다운로드 불필요.
- 비공개 노트(private_notes)도 읽어 컨텍스트에 포함하되, 인용 시 `(비공개)` 표시.

**로드 직후 두 값을 기억해 둔다** (refresh 델타 계산용):

- `last_journal_id` = 저널 중 `id` 최댓값 (저널 없으면 `0`)
- `updated_on` = 이슈 top-level `updated_on`

### 갱신 추적 — 증분 refresh

세션이 오래 떠 있는 동안 이슈에 새 저널/상태변경이 쌓인다. 사용자가 **"업데이트" / "새로고침" / "refresh"** 등 갱신 의도를 표하면 아래 절차로 **변경분만** 끌어온다.

Redmine API는 "이 시점 이후 저널만" 필터가 없어 `include=journals`는 항상 전체를 내려준다. 그러므로 **jq로 셸 단계에서 잘라** 대화 컨텍스트에는 델타만 들이는 것이 핵심 — 같은 내용을 처음부터 다시 컨텍스트에 쌓지 말 것.

1. **싼 변경 감지** — 저널 없이 `updated_on`만 확인:

   ```bash
   curl -s -H "X-Redmine-API-Key: $REDMINE_API_KEY" \
     "$REDMINE_URL/issues/{id}.json" | jq -r '.issue.updated_on'
   ```

   - 기억해 둔 `updated_on`과 같으면 → **"변경 없음"** 한 줄 출력하고 끝. 큰 페이로드 부르지 않음.
   - 다르면 2번으로.

2. **델타만 추출** — 전체 저널을 받되 jq로 `last_journal_id` 초과분과 바뀐 필드만 남겨 출력:

   ```bash
   curl -s -H "X-Redmine-API-Key: $REDMINE_API_KEY" \
     "$REDMINE_URL/issues/{id}.json?include=journals" \
   | jq --argjson last {last_journal_id} '{
       updated_on: .issue.updated_on,
       status: .issue.status.name,
       assigned_to: (.issue.assigned_to.name // null),
       done_ratio: .issue.done_ratio,
       new_journals: [.issue.journals[] | select(.id > $last)
         | {id, user: .user.name, created_on, private_notes, notes, details}]
     }'
   ```

3. **브리핑 + 저장값 갱신**:
   - 새 저널(노트/상태·담당자·완료율 변경 `details`)만 짧게 브리핑. 변화 없는 항목은 언급 안 함.
   - `last_journal_id`를 새 최댓값으로, `updated_on`을 새 값으로 갱신.
   - 사용자가 같이 질문을 던졌으면 델타를 근거로 답한다.

### 시작 동작 — 짧은 브리핑 후 대기

이슈 로드 후 **짧은 브리핑**만 출력한다. 전체 요약을 쏟아내지 말 것.

브리핑 형식 (한국어):

```
[{tracker} #{id}] {제목}
상태: {status} · 담당자: {assigned_to} · 우선순위: {priority} · 완료율: {done_ratio}%
{핵심을 한두 문장으로}
```

- 그다음:
  - 입력에 **후속 질문이 같이 왔으면** 브리핑 바로 아래에서 그 질문에 답한다.
  - 후속 질문이 **없으면** "무엇을 도와드릴까요?" 한 줄로 대기한다.
- 브리핑 이후의 대화는 로드한 이슈 컨텍스트를 근거로 답한다. 저널·본문에 근거가 있으면 해당 부분을 인용/지목하고, 근거가 없으면 추측하지 말고 모른다고 말한다.

### 중요 규칙

- **파일을 만들지 않는다** — 이 스킬은 대화 세션 준비 전용. 노트 산출은 `redmine-summary` 안내.
- 답변은 한국어로.
- 브리핑은 짧게. 사용자가 명시 요청하기 전엔 전체 요약을 풀지 말 것.
- 이슈 데이터에 근거 없는 단정 금지 — 근거 위치를 알 수 없으면 모른다고 답하거나 재조회 제안.
- API 호출 실패 시 에러 메시지를 사용자에게 명확히 전달.
- 같은 세션에서 다른 이슈를 다시 로드하면 새 이슈로 컨텍스트를 교체하되, 이전 이슈와의 관계가 있으면 짚어 준다.
