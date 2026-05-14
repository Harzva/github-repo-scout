param(
    [Parameter(Mandatory = $true)]
    [string]$Query,

    [int]$Limit = 10,

    [ValidateSet("stars", "forks", "updated")]
    [string]$Sort = "stars",

    [ValidateSet("desc", "asc")]
    [string]$Order = "desc",

    [int]$MinStars = 0,

    [string]$OutJson
)

$ErrorActionPreference = "Stop"
$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI 'gh' is not installed or not on PATH."
}

$fields = "fullName,description,stargazersCount,forksCount,updatedAt,pushedAt,url,language,license,isArchived,isFork,openIssuesCount,homepage"
$raw = & gh search repos $Query --limit $Limit --sort $Sort --order $Order --json $fields

if ($LASTEXITCODE -ne 0) {
    throw "gh search failed for query: $Query"
}

$converted = $raw | ConvertFrom-Json
$repos = @()
foreach ($item in $converted) {
    $repos += $item
}
$now = (Get-Date).ToUniversalTime()

$results = foreach ($repo in $repos) {
    if ([int]$repo.stargazersCount -lt $MinStars) {
        continue
    }

    $updated = $null
    $daysSinceUpdate = $null
    if ($repo.updatedAt) {
        $updated = [datetime]::Parse($repo.updatedAt).ToUniversalTime()
        $daysSinceUpdate = [math]::Round(($now - $updated).TotalDays, 1)
    }

    [pscustomobject]@{
        fullName = $repo.fullName
        url = $repo.url
        description = $repo.description
        language = $repo.language
        stars = [int]$repo.stargazersCount
        forks = [int]$repo.forksCount
        openIssues = [int]$repo.openIssuesCount
        license = if ($repo.license) { $repo.license.name } else { $null }
        updatedAt = $repo.updatedAt
        pushedAt = $repo.pushedAt
        daysSinceUpdate = $daysSinceUpdate
        homepage = $repo.homepage
        isArchived = [bool]$repo.isArchived
        isFork = [bool]$repo.isFork
    }
}

$json = @($results) | Sort-Object `
    @{ Expression = "isArchived"; Ascending = $true }, `
    @{ Expression = "stars"; Descending = $true } |
    ConvertTo-Json -Depth 5

if ($OutJson) {
    $parent = Split-Path -Parent $OutJson
    if ($parent) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    Set-Content -LiteralPath $OutJson -Value $json -Encoding UTF8
}

$json
