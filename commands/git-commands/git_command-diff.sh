# Git Diff Commands: Compare develop and master branches

# Show all differences between develop and master

git diff master..develop

# Show a summary of changed files

git diff --stat master..develop

# List only the filenames that are different

git diff --name-only master..develop

# To see what is in master that is not in develop

git diff develop..master