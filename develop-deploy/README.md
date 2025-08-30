# Development Guide - Five Rivers Tutoring

## 🏠 **Local Development Environment**

The development environment provides a **local WordPress development setup** with volume mounts for live editing, instant file changes, and easy plugin management. This is where you'll do most of your active development work.

## 🎯 **Purpose & Benefits**

### **What Development Provides**
- **Live Editing**: Instant file changes with volume mounts
- **Plugin Development**: Easy plugin installation and testing
- **Theme Development**: Real-time theme modifications
- **Content Creation**: Build and test content locally
- **Database Development**: Local database for development data

### **Why Use Development Environment**
- **Fast Iteration**: No rebuilds needed for file changes
- **Easy Debugging**: Full WordPress debugging enabled
- **Plugin Management**: Install plugins via WordPress Admin or WP-CLI
- **Local Database**: Fast database operations
- **Volume Mounts**: Direct access to source files

## 🏗️ **Architecture**

```
┌─────────────────────────────────────────────────────────────┐
│                    Local Development Machine                │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────────────┐
        │              Docker Compose                     │
        │  ┌─────────────────┐  ┌─────────────────────┐  │
        │  │  WordPress      │  │   MySQL Database    │  │
        │  │  - Development  │  │   - Local/External  │  │
        │  │  - Volume       │  │   - Development     │  │
        │  │  - Port 8082    │  │   - Data            │  │
        │  └─────────────────┘  └─────────────────────┘  │
        └─────────────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────────────┐
        │              Volume Mounts                     │
        │  ┌─────────────────┐  ┌─────────────────────┐  │
        │  │   Source Code   │  │   Configuration     │  │
        │  │  - Live editing │  │   - Environment     │  │
        │  │  - Instant      │  │   - Variables       │  │
        │  │  - Changes      │  │   - Settings        │  │
        │  └─────────────────┘  └─────────────────────┘  │
        └─────────────────────────────────────────────────┘
```

## 🚀 **Quick Start**

### **1. Start Development Environment**
```bash
cd develop-deploy
./develop-commands.bat start
```

### **2. Access WordPress**
- **URL**: `http://localhost:8082`
- **Admin**: `http://localhost:8082/wp-admin`
- **Database**: External database (192.168.50.158)

### **3. Start Developing**
- Edit files in `fiverivertutoring_wordpress/`
- Changes appear instantly in browser
- Install plugins via WordPress Admin
- Use WP-CLI for advanced operations

## 📁 **Directory Structure**

```
develop-deploy/
├── docker-compose.develop.yml          # Development Docker Compose
├── develop-commands.bat                # Windows development commands
├── develop-commands.sh                 # Linux/Mac development commands
├── env.example                         # Environment variables example
├── fiveriverstutoring_db.sql           # Development database dump
└── README.md                           # This file
```

## 🔧 **Configuration**

### **Environment Variables**
```bash
# Copy example file
cp env.example .env

# Edit with your values
nano .env
```

**Example Configuration:**
```properties
WORDPRESS_DB_HOST=192.168.50.158
WORDPRESS_DB_USER=fiverriversadmin
WORDPRESS_DB_PASSWORD=Password@123
WORDPRESS_DB_NAME=fiverivertutoring_db
WORDPRESS_HOME=http://localhost:8082
WORDPRESS_SITEURL=http://localhost:8082
WP_ENVIRONMENT_TYPE=local
WORDPRESS_DEBUG=1
```

### **Docker Compose Configuration**
```yaml
services:
  fiverivers-wp:
    image: wordpress:latest
    container_name: fiverivers-wp-local
    restart: always
    env_file:
      - .env
    ports:
      - "8082:80"
    volumes:
      - ../fiverivertutoring_wordpress:/var/www/html
      - fiverivers_uploads:/var/www/html/wp-content/uploads
      - fiverivers_cache:/var/www/html/wp-content/cache
```

## 🛠️ **Management Commands**

### **Windows Commands**
```bash
cd develop-deploy

# Start development environment
./develop-commands.bat start

# Stop development environment
./develop-commands.bat stop

# View logs
./develop-commands.bat logs

# Open shell in container
./develop-commands.bat shell

# Install plugins via WP-CLI
./develop-commands.bat wp-cli "plugin install contact-form-7 --activate"
```

### **Linux/Mac Commands**
```bash
cd develop-deploy

# Start development environment
./develop-commands.sh start

# Stop development environment
./develop-commands.sh stop

# View logs
./develop-commands.sh logs

# Open shell in container
./develop-commands.sh shell
```

### **Available Commands**
- **`start`**: Start development environment
- **`stop`**: Stop development environment
- **`restart`**: Restart development environment
- **`logs`**: View WordPress logs
- **`shell`**: Open shell in container
- **`wp-cli`**: Execute WP-CLI commands
- **`db-backup`**: Create database backup

## 🔌 **Plugin Management**

### **Method 1: WordPress Admin (GUI)**
1. Access WordPress Admin: `http://localhost:8082/wp-admin`
2. Navigate to: Plugins → Add New
3. Search for desired plugin
4. Click Install → Activate

### **Method 2: WP-CLI (Command Line)**
```bash
# Install and activate plugin
./develop-commands.bat wp-cli "plugin install plugin-slug --activate"

# Examples:
./develop-commands.bat wp-cli "plugin install contact-form-7 --activate"
./develop-commands.bat wp-cli "plugin install yoast-seo --activate"
./develop-commands.bat wp-cli "plugin install elementor --activate"

# List all plugins
./develop-commands.bat wp-cli "plugin list"

# Update all plugins
./develop-commands.bat wp-cli "plugin update --all"

# Deactivate plugin
./develop-commands.bat wp-cli "plugin deactivate plugin-slug"
```

### **Plugin Development Workflow**
1. **Install Plugin**: Via WordPress Admin or WP-CLI
2. **Test Functionality**: Verify plugin works correctly
3. **Make Changes**: Edit plugin files in `fiverivertutoring_wordpress/wp-content/plugins/`
4. **Test Changes**: Changes appear instantly in browser
5. **Build Image**: When ready, build Docker image with changes
6. **Deploy to Staging**: Test in staging environment
7. **Deploy to Production**: Deploy to production when validated

## 🎨 **Theme Development**

### **Theme Management**
```bash
# Install theme
./develop-commands.bat wp-cli "theme install twentytwentyfour --activate"

# List themes
./develop-commands.bat wp-cli "theme list"

# Update theme
./develop-commands.bat wp-cli "theme update twentytwentyfour"
```

### **Custom Theme Development**
1. **Create Theme Directory**: `fiverivertutoring_wordpress/wp-content/themes/your-theme/`
2. **Add Theme Files**: `style.css`, `index.php`, `functions.php`
3. **Activate Theme**: Via WordPress Admin or WP-CLI
4. **Live Development**: Edit files and see changes instantly
5. **Test Functionality**: Ensure theme works correctly
6. **Build Image**: Package theme into Docker image

## 📝 **Content Development**

### **Content Creation**
- **Posts & Pages**: Create via WordPress Admin
- **Media Uploads**: Upload images and files
- **Menus**: Build navigation menus
- **Widgets**: Configure sidebar and footer widgets

### **Content Management**
- **Live Editing**: Changes appear instantly
- **Version Control**: Track content changes in Git
- **Backup**: Regular database backups
- **Sync**: Copy content to staging when ready

## 🗄️ **Database Management**

### **Database Operations**
```bash
# Create backup
./develop-commands.bat db-backup

# Restore from backup
mysql -h 192.168.50.158 -u fiverriversadmin -p fiverivertutoring_db < backup.sql

# Check database connection
./develop-commands.bat wp-cli "db check"
```

### **Database Features**
- **External Database**: Connected to 192.168.50.158
- **Fast Operations**: Local network connection
- **Development Data**: Separate from staging/production
- **Easy Backup**: Simple backup and restore process

## 🔍 **Development Workflow**

### **Typical Development Cycle**
1. **Start Environment**: `./develop-commands.bat start`
2. **Make Changes**: Edit files in `fiverivertutoring_wordpress/`
3. **Test Changes**: View in browser at `http://localhost:8082`
4. **Iterate**: Make adjustments as needed
5. **Validate**: Ensure everything works correctly
6. **Build Image**: Create Docker image with changes
7. **Test Staging**: Deploy to staging environment
8. **Deploy Production**: Deploy to production when ready

### **File Change Workflow**
1. **Edit Source**: Modify files in `fiverivertutoring_wordpress/`
2. **Instant Preview**: Changes appear immediately in browser
3. **Test Functionality**: Verify changes work correctly
4. **Commit Changes**: Save to version control
5. **Build Image**: Package changes into Docker image
6. **Deploy**: Move to staging/production environments

## 🚨 **Troubleshooting**

### **Common Issues**

#### **Port Already in Use**
```bash
# Check what's using port 8082
netstat -tulpn | grep 8082

# Kill process or change port in docker-compose
```

#### **Database Connection Issues**
```bash
# Verify database credentials
cat .env

# Check database connectivity
mysql -h 192.168.50.158 -u fiverriversadmin -p

# Test WordPress database connection
./develop-commands.bat wp-cli "db check"
```

#### **File Changes Not Visible**
```bash
# Check volume mounts
docker inspect fiverivers-wp-local

# Verify source directory
ls -la ../fiverivertutoring_wordpress/

# Restart container
./develop-commands.bat restart
```

### **Debug Commands**
```bash
# Check container status
docker ps -a

# View container logs
docker logs fiverivers-wp-local

# Inspect container
docker inspect fiverivers-wp-local

# Check WordPress files
docker exec -it fiverivers-wp-local ls -la /var/www/html/wp-content
```

## 📊 **Performance Considerations**

### **Development vs Production**
- **Development**: Optimized for development speed
- **Volume Mounts**: Direct file access for instant changes
- **Debug Mode**: Full WordPress debugging enabled
- **Local Database**: Fast database operations

### **Resource Requirements**
- **Memory**: Minimum 2GB RAM recommended
- **Storage**: At least 5GB free space
- **CPU**: Multi-core processor for better performance

## 🔄 **Integration with Other Environments**

### **Development → Staging**
1. **Make Changes**: Develop in local environment
2. **Test Changes**: Verify functionality locally
3. **Build Staging Image**: `docker/dockerbuild-environments.sh staging`
4. **Deploy to Staging**: Use staging deployment script
5. **Validate in Staging**: Test with staging database

### **Development → Production**
1. **Make Changes**: Develop in local environment
2. **Test Changes**: Verify functionality locally
3. **Build Production Image**: `docker/dockerbuild-environments.sh production`
4. **Deploy to Production**: Use production deployment script
5. **Monitor Production**: Ensure deployment success

## 📚 **Related Documentation**

- [Main Project README](../README.md) - Project overview
- [Docker Architecture](../docker/README.md) - Image building strategy
- [Staging Deployment](../staging-deploy/README.md) - Staging environment
- [Production Deployment](../prod-deploy/README.md) - Production deployment

## 🎯 **Best Practices**

1. **Always test locally** before building images
2. **Use version control** for all code changes
3. **Regular backups** of development database
4. **Test thoroughly** before moving to staging
5. **Document changes** for team knowledge
6. **Keep environment variables** secure and updated

## 🎉 **Summary**

The development environment provides:
- **Fast iteration** with live file editing
- **Easy plugin management** via WordPress Admin or WP-CLI
- **Local database** for fast development
- **Volume mounts** for instant changes
- **Full debugging** capabilities
- **Integration** with staging and production workflows

**Development: Your fast, flexible WordPress development playground!** 🏠⚡
