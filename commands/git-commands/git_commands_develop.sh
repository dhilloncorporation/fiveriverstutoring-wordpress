# Git Commands to Push EMI Calculator Changes to Develop Branch

# 1. Check current status
git status

# 2. Check which branch you're on
git branch

# 3. If you're not on develop branch, switch to it
git checkout develop

# 4. Pull latest changes from remote develop (if any)
git pull origin develop

# 5. Add all changes
git add .

# 6. Commit the changes
git commit -m "Enhanced EMI Calculator with visual tabs, improved loan type buttons, and better formatting"

# 7. Push to remote develop branch
git push origin develop

# Alternative: If you're already on develop and have committed, just run:
# git push origin develop

# If develop branch doesn't exist, create it first:
# git checkout -b develop
# git push -u origin develop

# Summary of Changes Made:
# - Enhanced loan type buttons with better styling and Home Loan as default
# - Added visual tabs with Principal & Interest Summary and Breakdown charts
# - Improved currency formatting with comma separators
# - Reduced slider range to 5 million while keeping unlimited typing
# - Added responsive design for mobile devices
# - Changed Personal Loan icon to money bag
# - Added interactive charts using Chart.js 

############### Pushing to Master #############
# 5. Switch to the master branch
git checkout master

# 6. Pull the latest changes from the remote master branch
git pull origin master

# 7. Merge the develop branch into master
git merge develop

# 8. Push the updated master branch to the remote repository
git push origin master

## 🌳 **Git Worktree Setup Commands:**

### **Step 1: Check current status**
```bash
git status
```

### **Step 2: Create worktree for develop branch**
```bash
git worktree add ../valueladder-financial-wordpress-develop develop
```

### **Step 3: Create worktree for main branch**
```bash
git worktree add ../valueladder-financial-wordpress-main main
```

### **Step 4: List all worktrees**
```bash
git worktree list
```

## 📁 **Resulting Structure:**
```
<code_block_to_apply_changes_from>
```

## 🚀 **Usage:**
- **Current work**: `./valueladder-financial-wordpress/`
- **Development**: `../valueladder-financial-wordpress-develop/`
- **Production**: `../valueladder-financial-wordpress-main/`

Now all the worktree directories have consistent naming with your project! Run these commands to create your Git worktrees.








