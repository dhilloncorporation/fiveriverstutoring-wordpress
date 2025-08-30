# Docker Architecture - Five Rivers Tutoring

## 🎯 **Single Dockerfile Strategy**

This project uses **one Dockerfile** (`Dockerfile`) to build both staging and production environments. This approach ensures consistency, reduces maintenance overhead, and prevents environment drift.

## 🏗️ **Architecture Overview**

```
┌─────────────────────────────────────────────────────────────┐
│                    Single Dockerfile                        │
│                (docker/Dockerfile)                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ Build Arguments │
                    │  - ENVIRONMENT  │
                    │  - INCLUDE_DEBUG│
                    │  - OPTIMIZE_FOR_│
                    │    PRODUCTION   │
                    └─────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────────────┐
        │           Conditional Logic                     │
        │  ┌─────────────────┐  ┌─────────────────────┐  │
        │  │   Staging       │  │    Production       │  │
        │  │  - Dev tools    │  │  - Minimal packages │  │
        │  │  - Debug mode   │  │  - PHP optimized    │  │
        │  │  - WP-CLI       │  │  - Security hardened│  │
        │  │  - MySQL client │  │  - OPcache enabled  │  │
        │  └─────────────────┘  └─────────────────────┘  │
        └─────────────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────────────┐
        │              Image Tags                         │
        │  ┌─────────────────┐  ┌─────────────────────┐  │
        │  │ :staging        │  │    :production      │  │
        │  │ (larger, dev)   │  │  (smaller, optimized)│  │
        │  └─────────────────┘  └─────────────────────┘  │
        └─────────────────────────────────────────────────┘
```

## 🔧 **Build Arguments**

### **ENVIRONMENT**
- **`staging`**: Development environment with full tooling
- **`production`**: Production environment with minimal packages

### **INCLUDE_DEBUG**
- **`true`**: Enables WordPress debugging and development features
- **`false`**: Disables debugging for production performance

### **OPTIMIZE_FOR_PRODUCTION**
- **`true`**: Enables PHP optimizations (OPcache, realpath cache)
- **`false`**: Standard PHP settings for development

## 🚀 **Build Commands**

### **Build Staging Image**
```bash
cd docker
./dockerbuild-environments.sh staging
```

**What this builds:**
- WordPress core + custom wp-content
- Development tools (Composer, Git, WP-CLI, MySQL client)
- Debug capabilities enabled
- All plugins and themes included
- Upload images built-in

### **Build Production Image**
```bash
cd docker
./dockerbuild-environments.sh production
```

**What this builds:**
- WordPress core + custom wp-content
- Minimal packages (ca-certificates only)
- PHP optimizations (OPcache enabled)
- Security hardened
- All plugins and themes included
- Upload images built-in

### **Build Both Images**
```bash
cd docker
./dockerbuild-environments.sh all
```

### **Show Image Differences**
```bash
cd docker
./dockerbuild-environments.sh diff
```

## 📊 **Image Size Comparison**

| Environment | Size | Packages | Tools | Optimizations |
|-------------|------|----------|-------|---------------|
| **Staging** | ~1.2GB | Full dev stack | Composer, Git, WP-CLI | Standard PHP |
| **Production** | ~800MB | Minimal | Essential only | OPcache, realpath cache |

## 🔍 **How Conditional Logic Works**

### **Package Installation**
```dockerfile
RUN if [ "$ENVIRONMENT" = "production" ]; then \
        echo "Production build: Installing minimal packages..." && \
        apt-get update && apt-get install -y ca-certificates && \
        rm -rf /var/lib/apt/lists/* && apt-get clean; \
    else \
        echo "Staging build: Installing development packages..." && \
        apt-get update && apt-get install -y unzip wget curl gnupg lsb-release git ca-certificates && \
        rm -rf /var/lib/apt/lists/*; \
    fi
```

### **Development Tools**
```dockerfile
RUN if [ "$ENVIRONMENT" != "production" ]; then \
        echo "Installing development tools for staging..." && \
        apt-get update && apt-get install -y default-mysql-client && \
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
        chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp && \
        rm -rf /var/lib/apt/lists/*; \
    else \
        echo "Skipping development tools for production..."; \
    fi
```

### **PHP Optimizations**
```dockerfile
RUN if [ "$ENVIRONMENT" = "production" ]; then \
        echo "Production: Enabling PHP optimizations..." && \
        echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/opcache.ini && \
        # ... more optimizations
    else \
        echo "Staging: Development PHP settings..."; \
    fi
```

## 🎯 **Benefits of This Approach**

### **✅ Consistency**
- Same base image for both environments
- Identical WordPress core and wp-content
- Consistent PHP extensions and configurations

### **✅ Maintainability**
- One Dockerfile to maintain
- No duplicate code or configurations
- Easy to update both environments

### **✅ Environment Parity**
- Staging mirrors production exactly
- Same plugins, themes, and configurations
- Reduces "works on my machine" issues

### **✅ Flexibility**
- Easy to add new environment types
- Simple to modify build logic
- Clear separation of concerns

## 🚫 **What We DON'T Do**

- ❌ **Separate Dockerfiles** - No `Dockerfile.staging` or `Dockerfile.production`
- ❌ **Different base images** - Same `wordpress:latest` base
- ❌ **Duplicate configurations** - Single source of truth
- ❌ **Environment-specific source code** - Same wp-content for both

## 🔄 **Build Process Flow**

1. **Base Image**: Start with `wordpress:latest`
2. **Conditional Packages**: Install based on `ENVIRONMENT` argument
3. **WordPress Setup**: Copy core files and custom wp-content
4. **Dependencies**: Install Composer dependencies
5. **Configuration**: Apply environment-specific PHP settings
6. **Permissions**: Set proper file ownership and permissions
7. **Finalization**: Create volume mount points and expose ports

## 🛠️ **Customization**

### **Adding New Environment Types**
To add a new environment (e.g., `testing`):

1. **Add build argument**:
   ```dockerfile
   ARG ENVIRONMENT=staging
   ```

2. **Add conditional logic**:
   ```dockerfile
   RUN if [ "$ENVIRONMENT" = "testing" ]; then \
           echo "Testing environment setup..."; \
       elif [ "$ENVIRONMENT" = "production" ]; then \
           echo "Production setup..."; \
       else \
           echo "Staging setup..."; \
       fi
   ```

3. **Update build script**:
   ```bash
   build_testing() {
       docker build \
           --build-arg ENVIRONMENT=testing \
           -t fiverivertutoring-wordpress:testing \
           -f docker/Dockerfile .
   }
   ```

### **Adding New Build Arguments**
To add a new build argument (e.g., `INCLUDE_ANALYTICS`):

1. **Declare argument**:
   ```dockerfile
   ARG INCLUDE_ANALYTICS=false
   ```

2. **Use in conditional logic**:
   ```dockerfile
   RUN if [ "$INCLUDE_ANALYTICS" = "true" ]; then \
           echo "Installing analytics tools..."; \
       fi
   ```

3. **Pass in build command**:
   ```bash
   docker build \
       --build-arg ENVIRONMENT=production \
       --build-arg INCLUDE_ANALYTICS=true \
       -t fiverivertutoring-wordpress:production \
       -f docker/Dockerfile .
   ```

## 📚 **Related Documentation**

- [Main Project README](../README.md) - Project overview and quick start
- [Staging Deployment](../staging-deploy/README.md) - Staging environment setup
- [Production Deployment](../prod-deploy/README.md) - Production deployment guide
- [Development Guide](../develop-deploy/README.md) - Local development workflow

## 🎉 **Summary**

This single Dockerfile approach provides:
- **Consistency** across environments
- **Maintainability** with one source of truth
- **Flexibility** for environment-specific builds
- **Reliability** through identical configurations
- **Efficiency** in development and deployment workflows

**One Dockerfile, multiple environments, consistent results!** 🚀
