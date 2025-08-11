# 🚀 Five Rivers Tutoring - Complete Development & Deployment

A comprehensive WordPress development and deployment setup with three environments: Development, Staging, and Production.

## 🎯 **Environment Strategy**

| Environment | Method | Purpose | Database | Port |
|-------------|--------|---------|----------|------|
| **🏠 Development** | Docker Compose | Local development | External DB (192.168.50.158) | 8082 |
| **🧪 Staging** | Docker Image | Testing & validation | External staging DB (192.168.50.158) | 8083 |
| **🚀 Production** | Docker Image | Live deployment | External production DB | 8081 |

## 📁 **Project Structure**

```
fiverivertutoring-develop/
├── 🐳 docker/                          # Centralized Docker files
│   ├── Dockerfile                      # Custom WordPress image
│   ├── entrypoint.sh                   # Custom startup script
│   └── build-image.sh                  # Build script
│
├── 🏠 develop-deploy/                    # Development environment
│   ├── docker-compose.develop.yml      # Development with volume mounts
│   ├── develop-commands.bat            # Development management commands
│   └── env.example                     # Environment variables example
│
├── 🧪 staging-deploy/                  # Staging environment
│   ├── docker-compose.staging.yml      # Staging with custom image
│   ├── env.staging                     # Staging environment variables
│   ├── staging-commands.sh             # Staging management
│   ├── staging-db-setup.sh             # Database management
│   └── README.md                       # Staging documentation
│
├── 🚀 gcp-deploy/                      # Production environment
│   ├── deployment/                     # Production deployment
│   │   ├── docker-compose.prod.yml     # Production with custom image
│   │   └── deploy-on-vm.sh             # GCP deployment script
│   ├── databasemigration/              # Database migration scripts
│   ├── terraform/                      # GCP infrastructure
│   ├── content-migration/              # Content migration scripts
│   ├── config/                         # Configuration templates
│   ├── docs/                           # Documentation
│   ├── FILE_ORGANIZATION.md            # File organization guide
│   └── EXECUTION_ORDER.md              # Complete deployment guide
│
├── 📦 fiverivertutoring_wordpress/     # WordPress source files
│   ├── wp-content/                     # Themes, plugins, etc.
│   ├── config/                         # Configuration files
│   │   └── uploads.ini                 # PHP upload configuration
│   └── databasescripts/                # Database scripts
│
├── 🛠️ commands/                        # Utility commands
│   ├── docker-commands/                # Docker management commands
│   ├── git-commands/                   # Git workflow commands
│   ├── terraform-commands/             # Infrastructure commands
│   ├── windows-commands/               # Windows-specific commands
│   └── databasescripts/                # Database utility commands
│
├── 📄 README.md                        # Main project documentation
└── 📄 .gitignore                       # Git ignore rules
```

## 🚀 **Quick Start**

### **1. Development Environment**
```bash
# Start development environment
cd develop-deploy
./develop-commands.bat start

# Access WordPress
# URL: http://localhost:8082
# Admin: http://localhost:8082/wp-admin
# Username: admin
# Password: admin123
```

### **2. Build Custom Docker Image**

#### **Option 1: WSL/Linux (Recommended)**
```bash
# Build image for staging and production
cd docker
./build-image.sh
```

#### **Option 2: Windows Batch File**
```cmd
# From project root
build-image.bat

# Or from docker directory
cd docker
build-image.bat
```

#### **Option 3: Cross-platform Script**
```bash
# Works on WSL, Linux, macOS
cd docker
./build-image-crossplatform.sh
```

### **3. Deploy to Staging**
```bash
# Set up staging database (first time only)
cd staging-deploy
./staging-db-setup.sh verify

# Copy develop database to staging
./staging-db-setup.sh copy-develop

# Deploy to staging environment
./staging-commands.sh start

# Access staging
# URL: http://localhost:8083
```

### **4. Deploy to Production**
```bash
# Deploy to GCP production
cd gcp-deploy/deployment
./deploy-on-vm.sh
```

## 🛠️ **Environment Details**

### **🏠 Development (Docker Compose)**
- **Purpose**: Active development, plugin installation, content creation
- **Method**: Volume mounts for live editing
- **Database**: External database (192.168.50.158)
- **Plugin Management**: Install via WordPress Admin or WP-CLI
- **File Changes**: Instant reflection, no rebuild needed
- **Configuration**: Uses `fiverivertutoring_wordpress/config/uploads.ini`

### **🧪 Staging (Docker Image)**
- **Purpose**: Testing exact production setup
- **Method**: Custom Docker image with external database
- **Database**: External staging database (192.168.50.158)
- **Plugin Management**: Auto-activated (WPForms Lite, Yoast SEO)
- **Theme Management**: Auto-activated (Trend Business)
- **File Changes**: Requires image rebuild
- **Database Source**: Copied from development database

### **🚀 Production (Docker Image)**
- **Purpose**: Live website deployment
- **Method**: Custom Docker image with external database
- **Database**: External production database
- **Plugin Management**: Auto-activated (WPForms Lite, Yoast SEO)
- **Theme Management**: Auto-activated (Trend Business)
- **File Changes**: Requires image rebuild and deployment
- **Infrastructure**: GCP VM with Terraform provisioning

## 🔄 **Development Workflow**

### **Plugin Development:**
1. **Install in Development** → Use WordPress Admin or WP-CLI
2. **Test Functionality** → Verify plugin works correctly
3. **Build Image** → Package plugins into Docker image
4. **Deploy to Staging** → Test with staging database
5. **Deploy to Production** → Deploy to live environment

### **Content Updates:**
1. **Edit in Development** → Make changes with volume mounts
2. **Test Changes** → Verify functionality
3. **Build Image** → Package changes into Docker image
4. **Deploy to Staging** → Test in staging environment
5. **Deploy to Production** → Deploy to live environment

## 📋 **Management Commands**

### **Development Commands:**
```bash
# Start development
cd develop-deploy
./develop-commands.bat start

# View logs
./develop-commands.bat logs

# Stop development
./develop-commands.bat stop

# Install plugins via WP-CLI
./develop-commands.bat wp-cli "plugin install contact-form-7 --activate"

# Open shell in container
./develop-commands.bat shell

# Database backup
./develop-commands.bat db-backup
```

### **Staging Commands:**
```bash
# Start staging
cd staging-deploy
./staging-commands.sh start

# Database management
./staging-db-setup.sh copy-develop
./staging-db-setup.sh verify

# Stop staging
./staging-commands.sh stop

# View logs
./staging-commands.sh logs
```

### **Production Commands:**
```bash
# Deploy to production
cd gcp-deploy/deployment
./deploy-on-vm.sh

# Database management
cd ../databasemigration
./production-deploy.sh staging-to-production
./production-deploy.sh verify-production
```

## 🎯 **Benefits of This Approach**

### **Development Flexibility:**
- ✅ **Easy Plugin Installation** - Use WordPress Admin or WP-CLI
- ✅ **Live Editing** - Instant file changes with volume mounts
- ✅ **Local Database** - Fast development with local MySQL
- ✅ **Debug Mode** - Full WordPress debugging enabled
- ✅ **Upload Configuration** - Optimized PHP settings for file uploads

### **Staging Validation:**
- ✅ **Exact Production Setup** - Same image as production
- ✅ **External Database** - Test with staging database
- ✅ **Immutable Content** - No accidental changes
- ✅ **Confidence** - What works in staging works in production
- ✅ **Database Sync** - Easy copy from development database

### **Production Reliability:**
- ✅ **Immutable Deployment** - Versioned, secure images
- ✅ **External Database** - Scalable, managed database
- ✅ **Consistent Environment** - Same image everywhere
- ✅ **Easy Scaling** - Deploy multiple instances
- ✅ **Infrastructure as Code** - Terraform-managed GCP resources

## 📚 **Documentation**

- **📖 Development**: `develop-deploy/env.example` (environment variables)
- **📖 Staging**: `staging-deploy/README.md`
- **📖 Production**: `gcp-deploy/EXECUTION_ORDER.md`
- **📖 Database Migration**: `gcp-deploy/databasemigration/README.md`
- **📖 File Organization**: `gcp-deploy/FILE_ORGANIZATION.md`
- **📖 Commands**: `commands/` directory with utility scripts

## 🚨 **Troubleshooting**

### **Common Issues:**
- **Port Conflicts**: Check if ports 8082, 8083, 8081 are available
- **Database Connection**: Verify database credentials and connectivity
- **Image Build Failures**: Check if wp-content directory exists
- **Permission Issues**: Ensure proper file permissions
- **Upload Issues**: Verify `uploads.ini` configuration

### **Getting Help:**
1. Check environment-specific documentation
2. Review logs: `docker-compose logs -f`
3. Verify database connectivity
4. Check file permissions and paths
5. Use utility commands in `commands/` directory

## 🔧 **Configuration Files**

### **PHP Upload Configuration** (`fiverivertutoring_wordpress/config/uploads.ini`):
- Maximum file upload size: 64MB
- Maximum POST data size: 64MB
- Memory limit: 256MB
- Execution time: 300 seconds
- Security settings optimized for WordPress

### **Environment Variables**:
- **Development**: `local-deploy/env.example`
- **Staging**: `staging-deploy/env.staging`
- **Production**: `gcp-deploy/databasemigration/env.production`

## 🛠️ **Plugin Management with WP-CLI**

### **What is WP-CLI?**
WP-CLI (WordPress Command Line Interface) is a command-line tool for managing WordPress installations. It allows you to:
- Install, activate, and manage plugins
- Create and manage users
- Import/export content
- Update WordPress core and plugins
- Manage themes
- Perform database operations

### **Plugin Installation Methods:**

#### **Method 1: WordPress Admin (GUI)**
```bash
# Access WordPress Admin
# URL: http://localhost:8082/wp-admin
# Navigate to: Plugins → Add New → Search → Install → Activate
```

#### **Method 2: WP-CLI (Command Line)**
```bash
# Install and activate a plugin
docker exec -it fiverivers-wp-local wp plugin install plugin-slug --activate

# Examples:
docker exec -it fiverivers-wp-local wp plugin install contact-form-7 --activate
docker exec -it fiverivers-wp-local wp plugin install yoast-seo --activate
docker exec -it fiverivers-wp-local wp plugin install wordfence --activate

# Install plugin without activating
docker exec -it fiverivers-wp-local wp plugin install plugin-slug

# Activate an already installed plugin
docker exec -it fiverivers-wp-local wp plugin activate plugin-slug

# Deactivate a plugin
docker exec -it fiverivers-wp-local wp plugin deactivate plugin-slug

# List all plugins
docker exec -it fiverivers-wp-local wp plugin list

# Update all plugins
docker exec -it fiverivers-wp-local wp plugin update --all
```

### **Plugin Development Workflow:**
1. **Install in Development** → Use WP-CLI or WordPress Admin
2. **Test Functionality** → Verify plugin works correctly
3. **Build Docker Image** → Package plugins into image
4. **Deploy to Staging** → Test with staging database
5. **Deploy to Production** → Deploy to live environment

### **Why Use WP-CLI?**
- ✅ **Automation** - Script plugin installations
- ✅ **Consistency** - Same plugins across environments
- ✅ **Speed** - Faster than GUI for multiple plugins
- ✅ **Version Control** - Track plugin installations in scripts
- ✅ **CI/CD Integration** - Automate plugin management in deployment

---

**🎉 Your WordPress development and deployment environment is now fully configured and ready for efficient development!** 