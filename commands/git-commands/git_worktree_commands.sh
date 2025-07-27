#!/bin/bash

# Git Worktree Commands for ValueLadder Project
# Create separate working directories for different branches

echo "🌳 Setting up Git worktrees for ValueLadder project..."

# Step 1: Check current status
echo "📋 Checking current Git status..."
git status

# Step 2: Create worktree for develop branch
echo "🌿 Creating worktree for develop branch..."
git worktree add ../valueladder-financial-wordpress-develop develop

# Step 3: Create worktree for main/master branch
echo "🌳 Creating worktree for main branch..."
git worktree add ../valueladder-financial-wordpress-main main

# Step 4: List all worktrees
echo "📋 Listing all worktrees..."
git worktree list

# Step 5: Show branch structure
echo "🌿 Git branch structure:"
echo "   main (production)     -> ../valueladder-financial-wordpress-main"
echo "   develop (development) -> ../valueladder-financial-wordpress-develop"
echo "   current               -> ./valueladder-financial-wordpress"

echo "✅ Git worktrees created successfully!"
echo ""
echo "📁 Worktree Structure:"
echo "   📂 valueladder-financial-wordpress/  (current branch)"
echo "   📂 ../valueladder-financial-wordpress-develop/  (develop branch)"
echo "   📂 ../valueladder-financial-wordpress-main/  (main branch)"
echo ""
echo "🚀 Usage:"
echo "   - Work on features in: ../valueladder-financial-wordpress-develop/"
echo "   - Production code in: ../valueladder-financial-wordpress-main/"
echo "   - Current work in: ./valueladder-financial-wordpress/" 