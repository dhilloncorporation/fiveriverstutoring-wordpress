# Git Commands to Push EMI Calculator Changes to master Branch

# 1. Check current status
git status

# 2. Check which branch you're on
git branch

# 3. If you're not on master branch, switch to it
git checkout master

# 4. Pull latest changes from remote (if any)
git pull origin master

# 5. Add all changes
git add .

# 6. Commit the changes
git commit -m "Enhanced EMI Calculator with visual tabs, improved loan type buttons, and better formatting"

# 7. Push to remote master branch
git push origin master

# Alternative: If you're already on master and have committed, just run:
# git push origin master

# Summary of Changes Made:
# - Enhanced loan type buttons with better styling and Home Loan as default
# - Added visual tabs with Principal & Interest Summary and Breakdown charts
# - Improved currency formatting with comma separators
# - Reduced slider range to 5 million while keeping unlimited typing
# - Added responsive design for mobile devices
# - Changed Personal Loan icon to money bag
# - Added interactive charts using Chart.js