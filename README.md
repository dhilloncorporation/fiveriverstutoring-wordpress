# Five Rivers Tutoring - WordPress Website

A comprehensive educational services website with tutoring tools, course management, and responsive design optimized for Australian students and parents.

## 📁 Project Structure

```
fiverivertutoring/
├── 📁 wp-content/                              # WordPress Content Directory
│   ├── 📁 plugins/                             # WordPress Plugins
│   │   ├── 📁 akismet/                         # Spam protection
│   │   ├── 📁 contact-form-7/                  # Contact forms
│   │   ├── 📁 elementor/                       # Page builder
│   │   ├── 📁 tutoring-scheduler/              # Tutoring booking system
│   │   │   ├── 📁 frontend/
│   │   │   │   ├── 📁 assets/
│   │   │   │   │   ├── 📁 css/
│   │   │   │   │   └── 📁 js/
│   │   │   │   └── scheduler-frontend.php
│   │   │   └── tutoring-scheduler.php
│   │   ├── 📁 progress-tracker/                # Student progress tracking
│   │   ├── 📁 homework-assistant/              # Homework help tools
│   │   └── 📁 wordpress-seo/                   # SEO optimization
│   ├── 📁 themes/                             # WordPress Themes
│   ├── 📁 uploads/                             # Media uploads
│   ├── 📁 fonts/                               # Custom fonts
│   └── 📁 mu-plugins/                          # Must-use plugins
├── 📁 config/                                  # WordPress configuration
│   └── uploads.ini                             # Upload settings
├── 📁 databasescripts/                         # Database scripts
│   ├── fiveriversdb.sql                        # Database structure
│   ├── git_commands_develop.sh                 # Git commands for develop branch
│   ├── gitcommands-master.sh                   # Git commands for master branch
│   ├── git_command-diff.sh                     # Git diff commands
│   └── windowcommands.sh                       # Windows commands
├── 📁 gcp-deploy/                              # Google Cloud Platform Deployment
│   ├── 📁 terraform/                           # Infrastructure as Code
│   │   ├── 📁 network.tf                       # VPC, subnet, firewall
│   │   ├── 📁 storage.tf                       # Persistent disks
│   │   ├── 📁 compute.tf                       # VM instances
│   │   ├── 📁 security.tf                      # Enhanced security rules
│   │   ├── 📁 outputs.tf                       # Output values
│   │   ├── 📁 variables.tf                     # Variable definitions
│   │   ├── 📁 provider.tf                      # Google Cloud provider
│   │   └── 📁 production.tfvars                # Production variables
│   ├── 📁 docker-compose.prod.yml              # Production Docker setup
│   ├── 📁 deploy-on-vm.sh                      # VM deployment script
│   ├── 📁 copy-content-to-persistent-disk.sh   # Content migration script
│   ├── 📁 production-deploy.sh                 # Production deployment script
│   └── 📁 gcloudcommand.sh                     # Google Cloud commands
├── 📁 local-deploy/                            # Local Development
│   ├── 📁 docker-compose.local.yml             # Local Docker setup
│   └── 📁 fiverivers_wordpress/                # Local WordPress files
├── 📁 commands/                                # Development Commands
│   ├── 📁 docker-log-commands.sh               # Docker logging
│   ├── 📁 local.docker-build-commands.sh       # Local build commands
│   ├── 📁 prod.docker-build-commands.sh        # Production build commands
│   └── 📁 README.md                            # Command documentation
├── 📄 wp-config.php                            # WordPress configuration
├── 📄 index.php                                # Main WordPress entry point
├── 📄 wp-blog-header.php                       # WordPress blog header
├── 📄 wp-load.php                              # WordPress loader
├── 📄 wp-settings.php                          # WordPress settings
└── 📄 README.md                                # This file

```

## 🚀 Quick Start

### **Local Development**
```bash
# 1. Start local development
cd local-deploy
docker-compose -f docker-compose.local.yml up -d

# 2. Access website
http://localhost:8080

# 3. Access on mobile (same network)
http://192.168.50.158:8080
```

### **Production Deployment**
```bash
# 1. Deploy to GCP
cd gcp-deploy
./production-deploy.sh

# 2. Access production site
http://YOUR_GCP_IP:8081
```

## 🛠️ Technology Stack

### **Frontend**
- **WordPress** - Content Management System
- **Elementor** - Page builder
- **Chart.js** - Interactive progress charts
- **Responsive Design** - Mobile-optimized

### **Backend**
- **PHP** - Server-side scripting
- **MySQL** - Database (WordPress core only)
- **localStorage/sessionStorage** - Client-side data storage
- **Docker** - Containerization

### **Infrastructure**
- **Google Cloud Platform** - Cloud hosting
- **Terraform** - Infrastructure as Code
- **Docker Compose** - Container orchestration
- **Nginx** - Web server

## 📱 Mobile Optimization

### **iPhone/iOS Support**
- ✅ Responsive design
- ✅ Touch-friendly buttons (44px minimum)
- ✅ Safari-specific fixes
- ✅ Viewport meta tags
- ✅ Font size optimization (16px minimum)

### **Mobile Features**
- ✅ Tutoring scheduler
- ✅ Progress tracking
- ✅ Homework assistance
- ✅ Contact forms
- ✅ Mobile-optimized navigation

## 💰 Cost Optimization

### **Development (Local)**
- **Cost**: $0 (local development)
- **Performance**: Excellent
- **Features**: Full functionality

### **Production (GCP)**
- **Instance**: f1-micro (1 vCPU, 0.6GB RAM)
- **Storage**: 30GB total
- **Region**: australia-southeast1 (Sydney)
- **Monthly Cost**: ~$19-22 AUD
- **Annual Cost**: ~$228-264 AUD

## 🔧 Key Features

### **Educational Tools**
- **Tutoring Scheduler** - Booking system for sessions
- **Progress Tracker** - Student performance monitoring
- **Homework Assistant** - Assignment help tools
- **Interactive Charts** - Visual progress breakdowns
- **PDF Export** - Downloadable reports

### **Lead Generation**
- **Contact Forms** - Lead capture
- **Tutoring Tracking** - User engagement
- **Mobile Optimization** - Mobile-first design
- **SEO Ready** - Search engine optimized

### **Security & Performance**
- **HTTPS Ready** - SSL certificate support
- **Firewall Rules** - Network security
- **Caching** - Performance optimization
- **Mobile Optimized** - Fast loading on mobile

## 📊 Data Storage Strategy

### **Client-Side Storage (No Database)**
- ✅ **localStorage** - Persistent progress data
- ✅ **sessionStorage** - Session data
- ✅ **Privacy-focused** - No server-side data
- ✅ **Fast performance** - No database queries
- ✅ **Offline capable** - Works without internet

### **WordPress Core Only**
- ✅ **Posts & Pages** - Content management
- ✅ **Users & Roles** - Admin functionality
- ✅ **Settings** - Configuration
- ✅ **No custom tables** - Keep it simple

## 🎯 Development Workflow

### **1. Local Development**
```bash
# Start local environment
cd local-deploy
docker-compose up -d

# Make changes to WordPress files
# Test on localhost:8080
# Test on mobile: 192.168.50.158:8080
```

### **2. Git Workflow**
```bash
# Commit changes
git add .
git commit -m "Enhanced tutoring scheduler with mobile optimization"

# Push to develop
git push origin develop

# Merge to master
git checkout master
git merge develop
git push origin master
```

### **3. Production Deployment**
```bash
# Deploy to GCP
cd gcp-deploy
./production-deploy.sh

# Update DNS if needed
# Test production site
```

## 🔍 Troubleshooting

### **Mobile Display Issues**
1. **Clear browser cache** on iPhone
2. **Check mobile optimization CSS** is loaded
3. **Verify viewport meta tags** are present
4. **Test on different devices**

### **Local Network Access**
1. **Check Windows Firewall** settings
2. **Verify IP address** is correct
3. **Test with ngrok** if needed
4. **Check Docker container** is running

### **Production Issues**
1. **Check GCP instance** status
2. **Verify firewall rules** are correct
3. **Check WordPress configuration**
4. **Review Terraform logs**

## 📈 Performance Metrics

### **Target Performance**
- **Page Load**: < 3 seconds
- **Mobile Score**: > 90/100
- **Desktop Score**: > 95/100
- **First Contentful Paint**: < 1.5 seconds

### **Cost Targets**
- **Development**: $0/month
- **Production**: < $25 AUD/month
- **Scaling**: Easy upgrade path

## 🎨 Customization

### **Theme Customization**
- **Colors**: Edit `style.css`
- **Mobile**: Edit `mobile-optimization.css`
- **Functions**: Edit `functions.php`
- **Layout**: Use Elementor page builder

### **Tutoring Tools Customization**
- **Settings**: WordPress admin panel
- **Styling**: CSS customization
- **Logic**: JavaScript modifications
- **Charts**: Chart.js configuration

## 📞 Support

### **Development Issues**
- Check Docker logs: `docker-compose logs`
- Verify file permissions
- Test on different browsers
- Check mobile responsiveness

### **Production Issues**
- Check GCP console
- Review Terraform state
- Verify network connectivity
- Test SSL certificate

## 🎓 Educational Features

### **Tutoring Services**
- **High School Math** - Years 6-10 foundation
- **VCE Physics** - Advanced physics concepts
- **VCE General** - General mathematics
- **Personalized Learning** - Individual approach
- **Group Sessions** - Collaborative learning

### **6-Step Success Process**
1. **Evaluation** - Assessment of current skills
2. **Goal Setting** - SMART objectives
3. **Study Plan** - Personalized roadmap
4. **Execution** - Regular sessions
5. **Assessment** - Progress monitoring
6. **Realignment** - Plan adjustments

### **Student Support**
- **Progress Tracking** - Visual performance charts
- **Homework Help** - Assignment assistance
- **Exam Preparation** - Test readiness
- **Parent Communication** - Regular updates

---

**Five Rivers Tutoring** - Professional educational services platform optimized for Australian students with mobile-first design and cost-effective cloud hosting.

*Website by Dhillon Corporation, where ideas meet design. Contact us at dhilloncorporation@outlook.com.* 