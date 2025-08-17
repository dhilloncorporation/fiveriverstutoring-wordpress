# Docker Cleanup Improvements - Protecting Latest Tags

## Overview
We've improved the Docker image cleanup functionality to prevent accidental deletion of the `latest` tagged images, which was causing deployment issues.

## Problem Identified
The previous cleanup functions were accidentally deleting images with the `latest` tag, which are essential for:
- Production deployments
- Container orchestration
- Rolling back to known good versions
- Maintaining service continuity

## Improvements Made

### 1. Enhanced `cleanup_keep_latest_versions()` Function
- **Always preserves `latest` tag**: Never deletes images tagged as `latest`
- **Smart filtering**: Uses `grep -v "latest"` to exclude latest tags from deletion
- **Better logging**: Shows when `latest` tag is being preserved
- **Safer cleanup**: Only removes old version tags, never critical ones

### 2. Improved `cleanup_keep_current_only()` Function
- **Dynamic image detection**: No longer hardcoded to specific image names
- **Latest tag protection**: Automatically detects and preserves images with `latest` tag
- **Timestamp-based selection**: Keeps the most recent image by creation time
- **Project-aware**: Uses current GCP project instead of hardcoded values

### 3. New `preview_cleanup()` Function
- **Safe preview**: Shows what would be deleted without actually removing anything
- **Multiple preview modes**: Same options as actual cleanup
- **Clear warnings**: Highlights what will be removed
- **No risk**: Completely safe to run multiple times

## New Commands Available

### Preview Cleanup (Safe)
```bash
./deploy.sh preview-cleanup
```
This shows what would be deleted without actually removing anything.

### Enhanced Cleanup
```bash
./deploy.sh cleanup-images
```
Now much safer and always preserves `latest` tags.

## How It Works Now

### 1. Latest Tag Protection
```bash
# ALWAYS preserve the 'latest' tag if it exists
local has_latest=$(echo "$all_tags" | grep -q "latest" && echo "yes" || echo "no")
if [ "$has_latest" = "yes" ]; then
    print_status "  Preserving 'latest' tag (always kept)"
fi
```

### 2. Smart Tag Filtering
```bash
# Get tags to remove (all except the latest N, but NEVER remove 'latest')
local tags_to_remove=$(echo "$all_tags" | tail -n +$((keep_count + 1)) | grep -v "latest")
```

### 3. Dynamic Image Detection
```bash
# Check if this image has a 'latest' tag - if so, keep it
local has_latest_tag=$(gcloud container images list-tags $image --format="value(tags)" | grep -q "latest" && echo "yes" || echo "no")
```

## Safety Features

1. **Latest Tag Protection**: Images tagged as `latest` are never deleted
2. **Preview Mode**: See what would be deleted before running cleanup
3. **Better Logging**: Clear indication of what's being preserved vs. removed
4. **Error Handling**: Graceful handling of deletion failures
5. **Project Awareness**: Automatically detects current GCP project

## Usage Examples

### Safe Cleanup Workflow
```bash
# 1. Preview what would be deleted
./deploy.sh preview-cleanup

# 2. Choose cleanup option (1-4)
# 3. Review the preview output
# 4. If satisfied, run actual cleanup
./deploy.sh cleanup-images

# 5. Choose same cleanup option
```

### Cleanup Options
1. **Keep latest 2 versions** - Preserves 2 most recent versions + `latest`
2. **Keep only latest version** - Preserves most recent + `latest`
3. **Remove all except current** - Keeps `latest` + most recent by timestamp
4. **Custom cleanup** - Manual selection

## Verification Commands

After cleanup, verify that `latest` tags are preserved:

```bash
# List all images with their tags
gcloud container images list --repository=gcr.io/PROJECT_ID --format="table(name,tags)"

# Check specific image tags
gcloud container images list-tags gcr.io/PROJECT_ID/IMAGE_NAME --format="table(tags,timestamp)"

# Verify latest tag exists
gcloud container images list-tags gcr.io/PROJECT_ID/IMAGE_NAME --format="value(tags)" | grep "latest"
```

## Rollback Plan

If issues arise:
1. **Stop using cleanup**: Don't run cleanup commands
2. **Rebuild images**: Rebuild and tag with `latest` if needed
3. **Restore from backup**: Use previous image versions if available
4. **Contact support**: If critical images are lost

## Best Practices

1. **Always preview first**: Use `preview-cleanup` before running cleanup
2. **Keep multiple versions**: Use option 1 (keep latest 2 versions) for safety
3. **Monitor deployments**: Ensure new images are properly tagged
4. **Regular backups**: Keep image backups for critical services
5. **Test cleanup**: Test cleanup on non-production environments first

## Files Modified

- `deploy.sh` - Enhanced cleanup functions and added preview functionality
- `DOCKER_CLEANUP_IMPROVEMENTS.md` - This documentation file

## Next Steps

1. **Test the new functionality** on a non-production environment
2. **Use preview mode** before running any cleanup
3. **Monitor deployments** to ensure `latest` tags are preserved
4. **Update team documentation** about the new safe cleanup process
5. **Consider automation** of cleanup with proper safeguards

---

**Note**: These improvements ensure that your production deployments will never lose the `latest` tagged images, while still allowing you to clean up old versions to save storage costs.
