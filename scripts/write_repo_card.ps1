param(
    [Parameter(Mandatory = $true)]
    [string]$OwnerRepo,

    [string]$KnowledgebasePath = "D:\study\code\0ai\产品\14-personal_knowledgebase\harzva-knowledgebase",

    [string]$Status = "candidate"
)

$ErrorActionPreference = "Stop"
$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI 'gh' is not installed or not on PATH."
}

$fields = "nameWithOwner,description,stargazerCount,forkCount,updatedAt,createdAt,licenseInfo,repositoryTopics,url,primaryLanguage,homepageUrl"
$raw = & gh repo view $OwnerRepo --json $fields

if ($LASTEXITCODE -ne 0) {
    throw "gh repo view failed for repository: $OwnerRepo"
}

$repo = $raw | ConvertFrom-Json
$captured = (Get-Date).ToString("yyyy-MM-dd")
$slug = $repo.nameWithOwner.ToLowerInvariant() -replace "[/_.]+", "-" -replace "[^a-z0-9-]", "-"
$targetDir = Join-Path $KnowledgebasePath "sources\github"
$target = Join-Path $targetDir "$slug.md"

New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

$language = if ($repo.primaryLanguage) { $repo.primaryLanguage.name } else { "" }
$license = if ($repo.licenseInfo) { $repo.licenseInfo.name } else { "" }
$topics = @()
if ($repo.repositoryTopics -and $repo.repositoryTopics.nodes) {
    $topics = @($repo.repositoryTopics.nodes | ForEach-Object { $_.topic.name })
}

$topicLine = if ($topics.Count -gt 0) { $topics -join ", " } else { "" }

$content = @"
---
type: github-repo
source: $($repo.url)
captured: $captured
status: $Status
---

# $($repo.nameWithOwner)

## Snapshot

- Repository: ``$($repo.nameWithOwner)``
- URL: $($repo.url)
- Homepage: $($repo.homepageUrl)
- Language: $language
- Stars at capture: $($repo.stargazerCount)
- Forks at capture: $($repo.forkCount)
- Created at: $($repo.createdAt)
- Updated at: $($repo.updatedAt)
- License: $license
- Topics: $topicLine

## Description

$($repo.description)

## Why It Matters

-

## Fit For Current Task

-

## Reuse Ideas

-

## Risks Or Questions

-
"@

Set-Content -LiteralPath $target -Value $content -Encoding UTF8
Write-Output $target
