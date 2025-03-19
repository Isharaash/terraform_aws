# Define Variables
$GIT_REPO = "https://github.com/Isharaash/demo.git"
$FILE_TO_PUSH = "C:\Users\ishar\Documents\test1\.github\workflows\deploy.yml"
$BRANCH = "main"
$REPO_DIR = "C:\Users\ishar\Documents\test1"

# Ensure Git is installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Output "❌ Git is not installed. Please install Git before proceeding."
    exit 1
}

# Ensure the repository directory exists
if (!(Test-Path $REPO_DIR)) {
    Write-Output "Repository directory does not exist. Cloning the repository..."
    git clone $GIT_REPO $REPO_DIR
} 

# Change to repository directory
Set-Location $REPO_DIR

# Check if the repository is initialized
if (!(Test-Path ".git")) {
    Write-Output "Initializing Git repository..."
    git init
    git remote add origin $GIT_REPO
    git fetch origin
}

# Ensure the correct branch exists
git fetch origin $BRANCH 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Output "Branch '$BRANCH' does not exist on remote. Creating it..."
    git checkout -b $BRANCH
} else {
    git checkout $BRANCH
    git pull origin $BRANCH --rebase
}

# Ensure the .github/workflows directory exists
$WORKFLOWS_DIR = "$REPO_DIR\.github\workflows"
if (!(Test-Path $WORKFLOWS_DIR)) {
    Write-Output "Creating .github/workflows directory..."
    New-Item -ItemType Directory -Path $WORKFLOWS_DIR -Force | Out-Null
}

# Ensure the deploy.yml file exists
if (!(Test-Path $FILE_TO_PUSH)) {
    Write-Output "File $FILE_TO_PUSH does not exist. Creating it..."
    New-Item -ItemType File -Path $FILE_TO_PUSH -Force | Out-Null
}

# Check if there are changes in the file
git add $FILE_TO_PUSH
$CHANGES = git status --porcelain

if ($CHANGES) {
    Write-Output "🔄 Changes detected in deploy.yml. Updating repository..."
    
    # Commit changes
    git commit -m "Updated deploy.yml for CI/CD pipeline"

    # Push changes to GitHub
    Write-Output "🚀 Pushing changes to GitHub..."
    git push origin $BRANCH

    # Check if push was successful
    if ($LASTEXITCODE -eq 0) {
        Write-Output "✅ Successfully pushed deploy.yml to GitHub!"
    } else {
        Write-Output "❌ Failed to push changes. Please check for conflicts."
        exit 1
    }
} else {
    Write-Output "✅ No changes detected in deploy.yml. Nothing to update."
}
