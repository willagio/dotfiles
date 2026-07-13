---
name: yt-summary
description: "Extract or consume a YouTube transcript and create a concise Markdown summary under ~/obsidian-vault/youtube/. Use when the user asks to summarize a YouTube video, URL, or transcript."
---

# YouTube Summary Skill

YouTube 동영상의 트랜스크립트를 추출하여 간결한 마크다운 요약을 생성한다.

## Invocation

- Claude Code: `/yt-summary`
- Codex: `$yt-summary`

## Instructions

### 입력 처리

1. **URL이 제공된 경우**: yt-dlp로 트랜스크립트 자동 추출
2. **트랜스크립트가 직접 제공된 경우**: 바로 요약 진행
3. **아무것도 없는 경우**: 사용자에게 URL 또는 트랜스크립트 요청

### 트랜스크립트 추출 (yt-dlp)

Bash로 실행:
- yt-dlp 설치 확인 (`command -v yt-dlp`)
- 없으면 사용자에게 `brew install yt-dlp` 안내
- 자막 우선순위: 수동 한국어 → 수동 영어 → 자동생성 한국어 → 자동생성 영어
- VTT 파일에서 중복 제거하되, **타임스탬프 정보는 보존** (Quotes 섹션에서 사용)
- 자막 없으면 사용자에게 알리고 중단

#### 추출 절차

1. 영상 메타데이터 추출:
```bash
yt-dlp --print id --print title --print channel --print webpage_url --no-download "URL"
```

2. 사용 가능한 자막 확인:
```bash
yt-dlp --list-subs --no-download "URL"
```

3. 자막 다운로드 (우선순위에 따라 시도):
```bash
# 수동 자막 우선
yt-dlp --write-sub --sub-lang ko,en --sub-format vtt --skip-download -o "%(id)s" "URL"
# 수동 자막 없으면 자동생성
yt-dlp --write-auto-sub --sub-lang ko,en --sub-format vtt --skip-download -o "%(id)s" "URL"
```

4. VTT 파일에서 텍스트와 타임스탬프 추출:
   - 중복 라인 제거 (VTT는 같은 텍스트를 반복 출력함)
   - 각 텍스트 블록의 시작 타임스탬프는 보존
   - 임시 파일은 작업 완료 후 정리

### 출력 포맷

`~/obsidian-vault/youtube/YYYY-MM-DD-{video-title-slug}.md`에 저장:

```markdown
---
id: "{video-id}"
aliases: []
tags:
  - youtube-summary
source: "{video-url}"
channel: "{channel-name}"
date: YYYY-MM-DD
---

# {영상 제목}

## TL;DR
<!-- 한 문장으로 핵심 내용 요약 -->

## Key Points
<!-- 3-7개의 핵심 포인트를 bullet으로 정리 -->

## Summary
<!-- 섹션별 또는 토픽별 요약. 필요시 소제목 사용 -->

## Quotes
<!-- 인상적인 발언을 타임스탬프 링크와 함께 인용 -->
<!-- 형식: > "인용문" — [MM:SS](https://www.youtube.com/watch?v={id}&t={seconds}) -->

## Takeaways
<!-- 실행 가능한 인사이트나 적용할 점 -->
```

### 중요 규칙

- `youtube/` 디렉토리 없으면 생성
- 동일 파일 존재 시 덮어쓰기 전 사용자 확인
- 원문 언어 보존 (한국어 영상은 한국어로 요약)
- 영어 영상도 한국어로 번역하지 않음 (원문 유지)
- TL;DR은 반드시 한 문장
- Key Points는 최대 7개
- 코드 예제가 있으면 그대로 포함
- `video-title-slug`는 영상 제목을 소문자 + 하이픈으로 변환 (특수문자 제거)
