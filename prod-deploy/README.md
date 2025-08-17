# Five Rivers Tutoring - Production Deployment

Welcome to the production deployment infrastructure for Five Rivers Tutoring WordPress application on Google Cloud Platform.

## 📚 **Documentation**

**All documentation has been moved to the `docs/` directory for better organization:**

- **[📖 Complete Documentation](docs/README.md)** - Main documentation index and navigation
- **[🚀 Quick Start Guide](docs/EXECUTION_GUIDE.md)** - Step-by-step deployment guide
- **[🔒 HTTPS Setup](docs/HTTPS_SETUP_GUIDE.md)** - Complete HTTPS configuration guide
- **[🧹 Operations Guide](docs/DOCKER_CLEANUP_IMPROVEMENTS.md)** - Safe Docker cleanup and maintenance

## 🛠️ **Scripts**

### **Core Deployment**
- **`deploy.sh`** - Infrastructure deployment with Terraform
- **`operations.sh`** - Day-to-day operations and maintenance

### **Quick Commands**
```bash
# Deploy infrastructure
./deploy.sh apply

# Check status
./operations.sh status

# Safe Docker cleanup
./operations.sh preview-cleanup
./operations.sh cleanup-images
```

## 🏗️ **Architecture**

This deployment uses a **modular Terraform architecture** with:
- **Shared infrastructure** (monitoring, logging, security)
- **Database resources** (Cloud SQL, users, privileges)
- **Compute resources** (VM, disk, IP, monitoring)
- **WordPress application** (container, configuration, health checks)

## 🚀 **Getting Started**

1. **Read the documentation**: Start with [docs/README.md](docs/README.md)
2. **Follow the guide**: Use [docs/EXECUTION_GUIDE.md](docs/EXECUTION_GUIDE.md)
3. **Deploy**: Run `./deploy.sh apply`
4. **Operate**: Use `./operations.sh` for daily tasks

---

**For complete documentation and guides, see the [docs/](docs/) directory.**
