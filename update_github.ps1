#!/usr/bin/env powershell

# Script to quickly update the Kanban porting package on GitHub
# Workspace: tentar pegar o kanban
# Repository: https://github.com/Judson-isac/kanban-crm-judson.git

$commitMessage = $args[0]
if (-not $commitMessage) {
    $commitMessage = "Update Kanban porting package - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}

Write-Host "🚀 Updating Kanban Porting Package on GitHub..." -ForegroundColor Cyan

# Ensure we are in the correct directory
Set-Location "c:\Users\judso\Downloads\tentar pegar o kanban\kanban_porting_package"

# Check for changes
$status = git status --porcelain
if (-not $status) {
    Write-Host "✅ No changes detected. Everything is up to date." -ForegroundColor Green
    exit
}

# Add, Commit and Push
Write-Host "📦 Adding changes..."
git add .

Write-Host "💾 Committing: '$commitMessage'..."
git commit -m $commitMessage

Write-Host "📤 Pushing to GitHub (main branch)..."
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "🎉 Successfully updated GitHub!" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to push changes. Check your connection or permissions." -ForegroundColor Red
}
