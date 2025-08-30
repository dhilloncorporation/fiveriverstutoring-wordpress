# 🚀 WordPress Production Deployment - Status & TODO

## 📍 **CURRENT STATUS: PARTIALLY WORKING**

### ✅ **What's Working:**
- ✅ Environment file generation (`generate-docker-env.sh`)
- ✅ Docker image transfer to VM
- ✅ VM connection and SSH access
- ✅ Basic script structure and flow

### ❌ **What's Broken:**
- ❌ **Directory creation**: Mix of `~/wordpress` and `/home/$VM_USER/wordpress` paths
- ❌ **File copying**: Inconsistent path usage causing permission errors
- ❌ **Docker run**: Still using hardcoded paths instead of `$VM_USER` variable

---

## 🔧 **IMMEDIATE FIXES NEEDED:**

### 1. **Fix Directory Creation (Line 235-239)**
**Current (BROKEN):**
```bash
gcloud compute ssh "$VM_NAME" --zone="$ZONE" --tunnel-through-iap --command="
    # Create wordpress directory in current user's home
    mkdir -p ~/wordpress && \
    chmod 755 ~/wordpress && \
    echo \"Deployment directory created: ~/wordpress\"
"
```

**Should Be (FIXED):**
```bash
gcloud compute ssh "$VM_NAME" --zone="$ZONE" --tunnel-through-iap --command="
    # Use detected VM user
    USER_HOME=\"/home/$VM_USER\"
    DEPLOY_DIR=\"\$USER_HOME/wordpress\"
    mkdir -p \"\$DEPLOY_DIR\" && \
    chmod 755 \"\$DEPLOY_DIR\" && \
    echo \"Deployment directory created: \$DEPLOY_DIR\"
"
```

### 2. **Fix File Copying (Line 275-280)**
**Current (BROKEN):**
```bash
gcloud compute ssh "$VM_NAME" --zone="$ZONE" --tunnel-through-iap --command="
    USER_HOME=\"/home/$VM_USER\"
    mkdir -p \"\$USER_HOME/wordpress\"
    mv /tmp/fiverivertutoring-wordpress-clean.properties \"\$USER_HOME/wordpress/fiverivertutoring-wordpress-clean.properties\"
    echo 'Clean properties file copied successfully'
"
```

**Should Be (FIXED):**
```bash
gcloud compute ssh "$VM_NAME" --zone="$ZONE" --tunnel-through-iap --command="
    # Use detected VM user
    USER_HOME=\"/home/$VM_USER\"
    DEPLOY_DIR=\"\$USER_HOME/wordpress\"
    mkdir -p \"\$DEPLOY_DIR\" && \
    mv /tmp/fiverivertutoring-wordpress-clean.properties \"\$DEPLOY_DIR/fiverivertutoring-wordpress-clean.properties\" && \
    echo 'Clean properties file copied successfully'
"
```

### 3. **Fix Docker Run Command (Line 295-305)**
**Current (BROKEN):**
```bash
docker run -d \
    --name fiverivers-wp-prod \
    --restart always \
        --env-file /home/$VM_USER/wordpress/fiverivertutoring-wordpress-clean.properties \
    -p 80:80 \
    -v fiverivers_uploads:/var/www/html/wp-content/uploads \
    -v fiverivers_cache:/var/www/html/wp-content/cache \
    fiverivertutoring-wordpress:production
```

**Should Be (FIXED):**
```bash
docker run -d \
    --name fiverivers-wp-prod \
    --restart always \
    --env-file \"\$DEPLOY_DIR/fiverivertutoring-wordpress-clean.properties\" \
    -p 80:80 \
    -v fiverivers_uploads:/var/www/html/wp-content/uploads \
    -v fiverivers_cache:/var/www/html/wp-content/cache \
    fiverivertutoring-wordpress:production
```

---

## 🎯 **EXECUTION PLAN:**

### **Phase 1: Fix Path Inconsistencies (IMMEDIATE)**
1. ✅ **Fix directory creation** - Use `$VM_USER` consistently
2. ✅ **Fix file copying** - Use `$DEPLOY_DIR` variable
3. ✅ **Fix Docker run** - Use `$DEPLOY_DIR` for env-file path

### **Phase 2: Test Deployment (AFTER FIXES)**
1. ✅ **Test directory creation** - Should create `/home/dhilloncorporations/wordpress`
2. ✅ **Test file copying** - Should copy to correct location
3. ✅ **Test Docker run** - Should start with proper env-file

### **Phase 3: Verify WordPress (AFTER DEPLOYMENT)**
1. ✅ **Check container status** - `docker ps`
2. ✅ **Check logs** - `docker logs fiverivers-wp-prod`
3. ✅ **Test website** - Access via IP address

---

## 🚨 **CRITICAL ISSUES TO ADDRESS:**

### **Issue 1: Mixed Path Approaches**
- **Problem**: Script uses both `~/wordpress` and `/home/$VM_USER/wordpress`
- **Impact**: Permission errors and file not found
- **Solution**: Use `$VM_USER` consistently throughout

### **Issue 2: Hardcoded User Detection**
- **Problem**: `VM_USER="dhilloncorporations"` is hardcoded
- **Impact**: Not portable to other environments
- **Solution**: Either keep hardcoded OR implement proper detection

### **Issue 3: Environment File Path**
- **Problem**: Docker run uses absolute path instead of relative
- **Impact**: Container can't find env-file
- **Solution**: Use `$DEPLOY_DIR` variable consistently

### **Issue 4: ROOT CAUSE - User Context Mismatch** 🚨 **NEW DISCOVERY**
- **Problem**: Script is running as different user than `dhilloncorporations`
- **Impact**: Cannot create `/home/dhilloncorporations` directory (Permission denied)
- **Root Cause**: SSH connection context vs. target user mismatch
- **Evidence**: `mkdir: cannot create directory '/home/dhilloncorporations': Permission denied`
- **Solution**: Use current SSH user's home directory OR run as correct user

---

## 📋 **NEXT STEPS:**

1. **🔧 Fix the 3 path inconsistencies above**
2. **🚨 FIX ROOT CAUSE: User context mismatch** - Use current SSH user's home
3. **🧪 Test directory creation** - Should work without permission errors
4. **🧪 Test file copying** - Should copy to correct location
5. **🧪 Test Docker deployment** - Should start WordPress container
6. **🌐 Verify website access** - Should show WordPress site

## 🔧 **ROOT CAUSE SOLUTION:**

### **Option A: Use Current SSH User (RECOMMENDED)**
```bash
# Instead of hardcoded dhilloncorporations, use current SSH user
gcloud compute ssh "$VM_NAME" --zone="$ZONE" --tunnel-through-iap --command="
    # Use current SSH user's home directory
    CURRENT_USER=\$(whoami)
    USER_HOME=\"/home/\$CURRENT_USER\"
    DEPLOY_DIR=\"\$USER_HOME/wordpress\"
    mkdir -p \"\$DEPLOY_DIR\" && \
    chmod 755 \"\$DEPLOY_DIR\" && \
    echo \"Deployment directory created: \$DEPLOY_DIR\"
"
```

### **Option B: Run as Specific User**
```bash
# SSH as dhilloncorporations user specifically
gcloud compute ssh dhilloncorporations@"$VM_NAME" --zone="$ZONE" --tunnel-through-iap --command="..."
```

**Recommendation**: Use Option A (current SSH user) for portability and reliability.

---

## 💡 **RECOMMENDATION:**

**Use the `$VM_USER` approach consistently** - it was working before and provides:
- ✅ **Consistent paths** throughout the script
- ✅ **Portable deployment** to different VMs
- ✅ **Clear variable usage** for debugging
- ✅ **Reliable file operations**

**Avoid mixing `~/wordpress` and `/home/$VM_USER/wordpress`** - this causes the current permission issues.

---

## 📝 **COMMANDS TO TEST AFTER FIXES:**

```bash
# Test deployment
./deploy.sh wp-deploy

# Check VM directory
gcloud compute ssh jamr-websites-prod-wordpress --zone=australia-southeast1-a --tunnel-through-iap --command="ls -la ~/wordpress"

# Check container status
gcloud compute ssh jamr-websites-prod-wordpress --zone=australia-southeast1-a --tunnel-through-iap --command="docker ps"

# Check container logs
gcloud compute ssh jamr-websites-prod-wordpress --zone=australia-southeast1-a --tunnel-through-iap --command="docker logs fiverivers-wp-prod"
```

---

**Status**: 🔴 **ROOT CAUSE IDENTIFIED - NEEDS USER CONTEXT FIX**  
**Priority**: 🚨 **CRITICAL** - Script failing due to user permission mismatch  
**Next Action**: Fix user context mismatch using current SSH user approach
