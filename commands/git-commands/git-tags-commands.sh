#!/bin/bash

# =============================================================================
# Five Rivers Tutoring - Git Tags Management Commands
# =============================================================================
# Author: Five Rivers Development Team
# Purpose: Git tag management and reference commands
# Usage: Source this file or run individual commands as needed
# =============================================================================

echo "🏷️ Five Rivers Tutoring - Git Tags Management"
echo "=============================================="

# =============================================================================
# TAG CREATION COMMANDS
# =============================================================================

# Create a lightweight tag (simple pointer to current commit)
create_lightweight_tag() {
    local tag_name="$1"
    if [ -z "$tag_name" ]; then
        echo "❌ Usage: create_lightweight_tag <tag-name>"
        return 1
    fi
    git tag "$tag_name"
    echo "✅ Lightweight tag '$tag_name' created"
}

# Create an annotated tag (recommended - includes metadata)
create_annotated_tag() {
    local tag_name="$1"
    local message="$2"
    if [ -z "$tag_name" ] || [ -z "$message" ]; then
        echo "❌ Usage: create_annotated_tag <tag-name> <message>"
        echo "   Example: create_annotated_tag 'v1.0-stable' 'Stable release with all features working'"
        return 1
    fi
    git tag -a "$tag_name" -m "$message"
    echo "✅ Annotated tag '$tag_name' created with message: $message"
}

# =============================================================================
# TAG LISTING COMMANDS
# =============================================================================

# List all tags
list_all_tags() {
    echo "📋 All tags in repository:"
    git tag -l
}

# List tags with details (annotated tags show more info)
list_tags_detailed() {
    echo "📋 Detailed tag information:"
    git tag -l -n
}

# Show specific tag information
show_tag_info() {
    local tag_name="$1"
    if [ -z "$tag_name" ]; then
        echo "❌ Usage: show_tag_info <tag-name>"
        return 1
    fi
    echo "📋 Information for tag '$tag_name':"
    git show "$tag_name"
}

# =============================================================================
# TAG PUSHING COMMANDS
# =============================================================================

# Push a specific tag to remote
push_tag() {
    local tag_name="$1"
    if [ -z "$tag_name" ]; then
        echo "❌ Usage: push_tag <tag-name>"
        return 1
    fi
    git push origin "$tag_name"
    echo "✅ Tag '$tag_name' pushed to remote"
}

# Push all tags to remote
push_all_tags() {
    git push origin --tags
    echo "✅ All tags pushed to remote"
}

# =============================================================================
# TAG DELETION COMMANDS
# =============================================================================

# Delete a local tag
delete_local_tag() {
    local tag_name="$1"
    if [ -z "$tag_name" ]; then
        echo "❌ Usage: delete_local_tag <tag-name>"
        return 1
    fi
    git tag -d "$tag_name"
    echo "✅ Local tag '$tag_name' deleted"
}

# Delete a remote tag
delete_remote_tag() {
    local tag_name="$1"
    if [ -z "$tag_name" ]; then
        echo "❌ Usage: delete_remote_tag <tag-name>"
        return 1
    fi
    git push origin --delete "$tag_name"
    echo "✅ Remote tag '$tag_name' deleted"
}

# Delete both local and remote tag
delete_tag_completely() {
    local tag_name="$1"
    if [ -z "$tag_name" ]; then
        echo "❌ Usage: delete_tag_completely <tag-name>"
        return 1
    fi
    git tag -d "$tag_name"
    git push origin --delete "$tag_name"
    echo "✅ Tag '$tag_name' deleted from both local and remote"
}

# =============================================================================
# TAG CHECKOUT COMMANDS
# =============================================================================

# Checkout a specific tag (creates detached HEAD)
checkout_tag() {
    local tag_name="$1"
    if [ -z "$tag_name" ]; then
        echo "❌ Usage: checkout_tag <tag-name>"
        return 1
    fi
    git checkout "$tag_name"
    echo "✅ Checked out tag '$tag_name' (detached HEAD state)"
    echo "⚠️  You are now in 'detached HEAD' state. To make changes:"
    echo "   1. Create a new branch: git checkout -b new-branch-name"
    echo "   2. Or return to main: git checkout main"
}

# Create a branch from a tag
create_branch_from_tag() {
    local tag_name="$1"
    local branch_name="$2"
    if [ -z "$tag_name" ] || [ -z "$branch_name" ]; then
        echo "❌ Usage: create_branch_from_tag <tag-name> <branch-name>"
        return 1
    fi
    git checkout -b "$branch_name" "$tag_name"
    echo "✅ Created branch '$branch_name' from tag '$tag_name'"
}

# =============================================================================
# FIVE RIVERS SPECIFIC TAGS
# =============================================================================

# Current stable tags in Five Rivers Tutoring project
show_fiverivers_tags() {
    echo "🎯 Five Rivers Tutoring Project Tags:"
    echo "======================================"
    echo "📌 Fiver-River-Tutoring-FullWork-Develop-n-Staging"
    echo "   - SSL database connections working"
    echo "   - Smart URL conversion (dev/staging/production)"
    echo "   - Gmail integration functional"
    echo "   - Complete staging environment"
    echo "   - Production ready configuration"
    echo ""
    echo "📋 To checkout this stable version:"
    echo "   git checkout Fiver-River-Tutoring-FullWork-Develop-n-Staging"
}

# Quick command to create Five Rivers release tag
create_fiverivers_release() {
    local version="$1"
    local description="$2"
    if [ -z "$version" ] || [ -z "$description" ]; then
        echo "❌ Usage: create_fiverivers_release <version> <description>"
        echo "   Example: create_fiverivers_release 'v1.1-production' 'Production deployment ready'"
        return 1
    fi
    local tag_name="FiveRivers-$version"
    git tag -a "$tag_name" -m "Five Rivers Tutoring - $description"
    echo "✅ Five Rivers release tag '$tag_name' created"
    echo "💡 To push: git push origin $tag_name"
}

# =============================================================================
# COMMON TAG WORKFLOWS
# =============================================================================

# Complete workflow: Create, push and list tag
tag_and_push() {
    local tag_name="$1"
    local message="$2"
    if [ -z "$tag_name" ] || [ -z "$message" ]; then
        echo "❌ Usage: tag_and_push <tag-name> <message>"
        return 1
    fi
    
    echo "🏷️ Creating annotated tag..."
    git tag -a "$tag_name" -m "$message"
    
    echo "🚀 Pushing tag to remote..."
    git push origin "$tag_name"
    
    echo "📋 Current tags:"
    git tag -l
    
    echo "✅ Tag '$tag_name' created and pushed successfully!"
}

# =============================================================================
# HELP AND USAGE
# =============================================================================

# Show available commands
show_tag_help() {
    echo "🏷️ Five Rivers Git Tags - Available Commands:"
    echo "=============================================="
    echo ""
    echo "📝 Creation:"
    echo "  create_lightweight_tag <name>              - Create simple tag"
    echo "  create_annotated_tag <name> <message>      - Create tag with metadata"
    echo "  create_fiverivers_release <ver> <desc>     - Create Five Rivers release"
    echo ""
    echo "📋 Listing:"
    echo "  list_all_tags                              - Show all tags"
    echo "  list_tags_detailed                         - Show tags with details"
    echo "  show_tag_info <name>                       - Show specific tag info"
    echo "  show_fiverivers_tags                       - Show Five Rivers project tags"
    echo ""
    echo "🚀 Remote Operations:"
    echo "  push_tag <name>                            - Push specific tag"
    echo "  push_all_tags                              - Push all tags"
    echo ""
    echo "🗑️ Deletion:"
    echo "  delete_local_tag <name>                    - Delete local tag"
    echo "  delete_remote_tag <name>                   - Delete remote tag"
    echo "  delete_tag_completely <name>               - Delete both local and remote"
    echo ""
    echo "🔄 Checkout:"
    echo "  checkout_tag <name>                        - Checkout specific tag"
    echo "  create_branch_from_tag <tag> <branch>      - Create branch from tag"
    echo ""
    echo "⚡ Workflows:"
    echo "  tag_and_push <name> <message>              - Create and push tag"
    echo ""
    echo "💡 Examples:"
    echo "  create_annotated_tag 'v1.0-stable' 'All features working'"
    echo "  push_tag 'v1.0-stable'"
    echo "  checkout_tag 'Fiver-River-Tutoring-FullWork-Develop-n-Staging'"
}

# =============================================================================
# AUTO-EXECUTION
# =============================================================================

# If script is run directly (not sourced), show help
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_tag_help
fi

# Display current project status
echo ""
echo "📊 Current Repository Status:"
echo "=============================="
echo "🌿 Current Branch: $(git branch --show-current)"
echo "🏷️ Total Tags: $(git tag -l | wc -l)"
echo "📍 Latest Commit: $(git log -1 --oneline)"
echo ""
echo "💡 Run 'show_tag_help' for available commands"
echo "🎯 Run 'show_fiverivers_tags' for project-specific tags"
