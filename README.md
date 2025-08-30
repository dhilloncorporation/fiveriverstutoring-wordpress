# Five Rivers Tutoring - WordPress Development & Deployment

## 🏗️ **Project Architecture**

This project uses a **single Dockerfile approach** with environment-specific builds for both staging and production environments.

### **Docker Strategy**
- **One Dockerfile**: `docker/Dockerfile` handles both staging and production
- **Environment-specific builds**: Uses build arguments for conditional optimization
- **No separate Dockerfiles**: Maintains consistency and reduces maintenance overhead

### **Environment Builds**
```bash
# Build staging (with development tools)
cd docker
./dockerbuild-environments.sh staging

# Build production (optimized, minimal)
./dockerbuild-environments.sh production
```

## 🚀 **Deployment Environments**

### **Staging Environment**
- **Location**: Local Docker Compose
- **Purpose**: Development, testing, content updates
- **Access**: `http://localhost:8080`
- **Database**: Local MySQL

### **Production Environment**
- **Location**: Google Cloud Platform (GCP)
- **Purpose**: Live website
- **Access**: Production domain
- **Database**: Cloud SQL

## 📁 **Key Directories**

- `docker/` - Docker configuration and build scripts
- `develop-deploy/` - Local staging environment
- `staging-deploy/` - Staging deployment scripts
- `prod-deploy/` - Production deployment scripts
- `fiverivertutoring_wordpress/` - WordPress source code

## 🔧 **Quick Start**

1. **Build Docker Image**:
   ```bash
   cd docker
   ./dockerbuild-environments.sh staging
   ```

2. **Start Staging**:
   ```bash
   cd develop-deploy
   docker-compose up -d
   ```

3. **Deploy to Production**:
   ```bash
   cd prod-deploy/scripts
   ./wordpress-management.sh deploy
   ```

## 📖 **Detailed Documentation**

- [Docker Architecture](docker/README.md) - Docker build strategy and environment differences
- [Staging Deployment](staging-deploy/README.md) - Local development setup
- [Production Deployment](prod-deploy/README.md) - GCP production deployment
- [Development Guide](develop-deploy/README.md) - Local development workflow

## 🎯 **Key Principles**

1. **Single Source of Truth**: One Dockerfile for all environments
2. **Environment Parity**: Staging mirrors production as closely as possible
3. **Automated Deployment**: Scripts handle complex deployment tasks
4. **No Breaking Changes**: Maintain working systems without unnecessary modifications 