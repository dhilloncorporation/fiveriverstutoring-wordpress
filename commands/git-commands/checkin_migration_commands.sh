#!/bin/bash

# ValueLadder Database Migration Check-in Commands
# Check in changes to both develop and master branches

echo "🚀 Starting Git check-in for database migration..."

# Step 1: Check current status
echo "📋 Checking current Git status..."
git status

# Step 2: Add all changes
echo "📦 Adding all changes..."
git add .

# Step 3: Commit to develop branch
echo "✅ Committing to develop branch..."
git commit -m "✅ Database Migration: Successfully migrated from fiverivers_db to valueladder_db

- Migrated WordPress database from fiverivers_db to valueladder_db
- Updated Docker Compose configuration to use valueladder_db
- Preserved all custom financial calculator plugins
- Added database migration scripts and commands
- Updated local development environment
- All custom plugins (EMI, loan, living expense calculators) working
- WordPress site running successfully on new database

Migration Status: ✅ SUCCESSFUL"

# Step 4: Push to develop
echo "📤 Pushing to develop branch..."
git push origin develop

# Step 5: Switch to master branch
echo "🔄 Switching to master branch..."
git checkout master

# Step 6: Merge develop into master
echo "🔀 Merging develop into master..."
git merge develop

# Step 7: Push to master
echo "📤 Pushing to master branch..."
git push origin master

# Step 8: Switch back to develop
echo "🔄 Switching back to develop branch..."
git checkout develop

echo "✅ Git check-in completed successfully!"
echo "📋 Summary:"
echo "   - Changes committed to develop branch"
echo "   - Changes merged to master branch"
echo "   - Database migration documented"
echo "   - All branches updated" 