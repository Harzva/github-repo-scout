---
name: github-repo-scout
description: Search GitHub repositories and gists for task-relevant projects, compare candidates, fetch repository metadata with gh, and save useful repo cards into Harzva Knowledgebase. Use when the user asks to find GitHub repos, compare libraries/tools, collect implementation references, or avoid manually pasting GitHub links from a browser.
---

# GitHub Repo Scout

Use this skill to replace manual browser-based GitHub hunting with a repeatable agent workflow.

## Default Knowledgebase

Archive useful results in:

```text
D:\study\code\0ai\产品\09-wemedia\harzva-knowledgebase
```

## Workflow

1. Convert the user task into 2-4 concrete GitHub search queries.
2. Run `scripts/search_github_repos.ps1` for each query.
3. Shortlist candidates by task fit, freshness, license, examples, docs, and implementation usefulness.
4. For repos worth keeping, run `scripts/write_repo_card.ps1`.
5. Update the knowledgebase `index.md`, `log.md`, and any relevant `wiki/` page.

## Search Command

```powershell
powershell -ExecutionPolicy Bypass -File C:\Users\harzva\.codex\skills\github-repo-scout\scripts\search_github_repos.ps1 -Query "llm wiki" -Limit 10
```

Use `-OutJson <path>` when you need a durable search artifact.

## Save Repo Card

```powershell
powershell -ExecutionPolicy Bypass -File C:\Users\harzva\.codex\skills\github-repo-scout\scripts\write_repo_card.ps1 -OwnerRepo "nashsu/llm_wiki"
```

The card is written to `sources/github/<owner>-<repo>.md` in the knowledgebase.

## Evaluation Rules

Read `references/repo-evaluation.md` when comparing more than three candidates or when the choice will affect implementation direction.

Archive only shortlisted repositories. Do not save every search result.

## Fallbacks

If `gh` is unavailable or rate-limited, use web search for discovery and record the limitation in the final answer. If a repo has no license or unclear maintenance status, flag that risk instead of treating popularity as proof.
