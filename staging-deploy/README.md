# Staging Deployment - Five Rivers Tutoring

## 🧪 **Staging Environment Overview**

The staging environment provides a **local testing ground** that mirrors production as closely as possible. It uses the same Docker image as production but runs locally for easy testing and validation.

## 🎯 **Purpose & Benefits**

### **What Staging Provides**
- **Production Parity**: Identical environment to production
- **Local Testing**: Test changes before production deployment
- **Content Validation**: Verify plugins, themes, and content work correctly
- **Database Testing**: Test with staging database
- **Performance Testing**: Validate image performance locally

### **Why Use Staging**
- **Reduce Risk**: Catch issues before production
- **Faster Iteration**: Local testing is faster than cloud deployment
- **Confidence**: What works in staging works in production
- **Team Collaboration**: Multiple developers can test simultaneously

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
        │  │  - Staging      │  │   - Local/External  │  │
        │  │  - Image-based  │  │   - Staging data    │  │
        │  │  - Port 8083    │  │   - Test content    │  │
        │  └─────────────────┘  └─────────────────────┘  │
        └─────────────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────────────┐
        │              Custom Docker Image                │
        │  ┌─────────────────┐  ┌─────────────────────┐  │
        │  │   Staging Tag   │  │   Development       │  │
        │  │  :staging       │  │   Tools Included    │  │
        │  │  - Dev tools    │  │   - Composer        │  │
        │  │  - Debug mode   │  │   - Git, WP-CLI     │  │
        │  │  - Full stack   │  │   - MySQL client    │  │
        │  └─────────────────┘  └─────────────────────┘  │
        └─────────────────────────────────────────────────┘
```

## 🚀 **Quick Start**

### **1. Build Staging Image**
```bash
cd docker
./dockerbuild-environments.sh staging
```

### **2. Start Staging Environment**
```bash
cd staging-deploy
./staging-commands.sh start
```

### **3. Access Staging**
- **URL**: `http://localhost:8083`
- **Admin**: `http://localhost:8083/wp-admin`
- **Database**: External staging database

## 📁 **Directory Structure**

```
staging-deploy/
├── docker-compose.staging.yml           # Staging Docker Compose
├── fiverivertutoring-wordpress-staging.properties # Staging config
├── staging-commands.sh                  # Staging management script
├── db-scripts/                          # Database management
│   ├── manage-staging-db-setup.sh      # Database setup script
│   ├── backups/                         # Database backups
│   └── fiverivertutoring_staging_db.sql # Staging database dump
└── README.md                            # This file
```

## 🔧 **Configuration**

### **Staging Properties**
```properties
# Database Configuration
WORDPRESS_DB_HOST=192.168.50.158
WORDPRESS_DB_NAME=fiverivertutoring_staging
WORDPRESS_DB_USER=fiverivertutoring_staging_user
WORDPRESS_DB_PASSWORD=your_staging_password

# WordPress Configuration
WORDPRESS_DEBUG=true
WORDPRESS_CONFIG_EXTRA=define('WP_DEBUG_LOG', true);
```

### **Docker Compose Configuration**
```yaml
services:
  fiverivers-wp:
    image: fiverivertutoring-wordpress:staging
    container_name: fiverivers-wp-staging
    restart: always
    env_file:
      - fiverivertutoring-wordpress-staging.properties
    ports:
      - "8083:80"
    volumes:
      - fiverivers_uploads:/var/www/html/wp-content/uploads
      - fiverivers_cache:/var/www/html/wp-content/cache
```

## 🗄️ **Database Management**

### **Database Setup Scripts**
The `db-scripts/` directory contains scripts for managing the staging database:

```bash
cd staging-deploy/db-scripts

# Copy development database to staging
./manage-staging-db-setup.sh copy-develop

# Verify staging database
./manage-staging-db-setup.sh verify

# Reset staging database
./manage-staging-db-setup.sh reset
```

### **Database Operations**
- **Copy from Development**: Sync latest development data
- **Verify Setup**: Check database connectivity and content
- **Reset Database**: Clean slate for testing
- **Backup Management**: Create and restore backups

## 🛠️ **Management Commands**

### **Staging Commands Script**
```bash
cd staging-deploy

# Start staging environment
./staging-commands.sh start

# Stop staging environment
./staging-commands.sh stop

# Check status
./staging-commands.sh status

# View logs
./staging-commands.sh logs

# Open shell in container
./staging-commands.sh shell
```

### **Available Commands**
- **`start`**: Start staging environment
- **`stop`**: Stop staging environment
- **`restart`**: Restart staging environment
- **`status`**: Check current status
- **`logs`**: View WordPress logs
- **`shell`**: Open shell in container

## 🔄 **Development Workflow**

### **Typical Workflow**
1. **Make Changes**: Develop in development environment
2. **Build Image**: Create new staging image with changes
3. **Test Staging**: Deploy and test in staging environment
4. **Validate**: Ensure everything works correctly
5. **Deploy Production**: Deploy to production when ready

### **Content Updates**
1. **Edit Content**: Make changes in development
2. **Build Staging**: `./dockerbuild-environments.sh staging`
3. **Test Changes**: Verify in staging environment
4. **Build Production**: `./dockerbuild-environments.sh production`
5. **Deploy Production**: Use production deployment script

## 🐳 **Docker Image Details**

### **Staging Image Features**
- **Tag**: `fiverivertutoring-wordpress:staging`
- **Base**: `wordpress:latest`
- **Development Tools**: Composer, Git, WP-CLI, MySQL client
- **Debug Mode**: WordPress debugging enabled
- **Full Stack**: All development packages included

### **Image Contents**
- WordPress core files
- Custom plugins and themes
- Upload images and media
- Composer dependencies
- Development tools and utilities

## 🔍 **Testing & Validation**

### **What to Test in Staging**
- **Plugin Functionality**: Ensure all plugins work correctly
- **Theme Display**: Verify theme renders properly
- **Content Display**: Check content appears correctly
- **Database Connectivity**: Verify database operations
- **Performance**: Test image loading and response times

### **Validation Checklist**
- [ ] WordPress loads without errors
- [ ] All plugins are active and functional
- [ ] Theme displays correctly
- [ ] Content is visible and properly formatted
- [ ] Database operations work
- [ ] No console errors in browser
- [ ] Performance is acceptable

## 🚨 **Troubleshooting**

### **Common Issues**

#### **Port Already in Use**
```bash
# Check what's using port 8083
netstat -tulpn | grep 8083

# Kill process or change port in docker-compose
```

#### **Database Connection Issues**
```bash
# Verify database credentials
cat fiverivertutoring-wordpress-staging.properties

# Check database connectivity
mysql -h 192.168.50.158 -u fiverivertutoring_staging_user -p
```

#### **Image Not Found**
```bash
# Check if staging image exists
docker images | grep fiverivertutoring-wordpress

# Build image if missing
cd docker && ./dockerbuild-environments.sh staging
```

### **Debug Commands**
```bash
# Check container status
docker ps -a

# View container logs
docker logs fiverivers-wp-staging

# Inspect container
docker inspect fiverivers-wp-staging

# Check WordPress files
docker exec -it fiverivers-wp-staging ls -la /var/www/html/wp-content
```

## 📊 **Performance Considerations**

### **Local vs Production**
- **Local Performance**: May be slower due to local resources
- **Production Parity**: Same image ensures consistent behavior
- **Testing Accuracy**: Local testing reflects production reality

### **Resource Requirements**
- **Memory**: Minimum 2GB RAM recommended
- **Storage**: At least 5GB free space
- **CPU**: Multi-core processor for better performance

## 🔄 **Synchronization**

### **Keeping Staging Current**
- **Regular Updates**: Sync with development database weekly
- **Image Rebuilds**: Rebuild image when content changes
- **Plugin Updates**: Test new plugins in staging first
- **Theme Changes**: Validate theme modifications

### **Sync Commands**
```bash
# Sync database from development
cd staging-deploy/db-scripts
./manage-staging-db-setup.sh copy-develop

# Rebuild staging image
cd docker
./dockerbuild-environments.sh staging

# Restart staging environment
cd staging-deploy
./staging-commands.sh restart
```

## 📚 **Related Documentation**

- [Main Project README](../README.md) - Project overview
- [Docker Architecture](../docker/README.md) - Image building strategy
- [Production Deployment](../prod-deploy/README.md) - Production deployment
- [Development Guide](../develop-deploy/README.md) - Local development

## 🎯 **Best Practices**

1. **Always test in staging** before production deployment
2. **Keep staging database current** with development data
3. **Validate all changes** in staging environment
4. **Use staging for plugin testing** before production
5. **Regular image rebuilds** to stay current
6. **Document staging issues** for team knowledge

## 🎉 **Summary**

The staging environment provides:
- **Production parity** for accurate testing
- **Local development** for fast iteration
- **Risk reduction** before production deployment
- **Team collaboration** for testing and validation
- **Confidence building** that changes will work in production

**Staging: Your safety net for production deployments!** 🧪✅ 