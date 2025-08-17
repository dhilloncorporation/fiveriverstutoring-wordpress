# 📊 Staging Data Extraction and Loading Documentation

## 🔍 **Data Source Files**

### **1. Production Configuration Source**
- **File**: `../terraform/wordpress.tfvars`
- **Purpose**: Contains GCP production database settings
- **Extracted by**: `load_wordpress_config()` function

### **2. Staging Configuration Source**  
- **File**: `../properties/fiverivertutoring-wordpress.properties`
- **Purpose**: Contains staging database and migration settings
- **Extracted by**: `load_wordpress_config()` function

---

## 📋 **Data Extraction Process**

### **Step 1: Load Production Config (from wordpress.tfvars)**
```bash
# Extract values using grep and sed
WORDPRESS_DB_HOST=$(grep "wordpress_db_host" "$WORDPRESS_TFVARS" | sed 's/.*= "\(.*\)".*/\1/')
WORDPRESS_DB_NAME=$(grep "wordpress_db_name" "$WORDPRESS_TFVARS" | sed 's/.*= "\(.*\)".*/\1/')
WORDPRESS_DB_USER=$(grep "wordpress_db_user" "$WORDPRESS_TFVARS" | sed 's/.*= "\(.*\)".*/\1/')
WORDPRESS_DB_PASSWORD=$(grep "wordpress_db_password" "$WORDPRESS_TFVARS" | sed 's/.*= "\(.*\)".*/\1/')
WORDPRESS_DB_ADMIN_USER=$(grep "wordpress_db_admin_user" "$WORDPRESS_TFVARS" | sed 's/.*= "\(.*\)".*/\1/')
WORDPRESS_DB_ADMIN_PASSWORD=$(grep "wordpress_db_admin_password" "$WORDPRESS_TFVARS" | sed 's/.*= "\(.*\)".*/\1/')
CLOUD_SQL_INSTANCE=$(grep "wordpress_db_instance" "$WORDPRESS_TFVARS" | sed 's/.*= "\(.*\)".*/\1/')
```

### **Step 2: Load Staging Config (from fiverivertutoring-wordpress.properties)**
```bash
# Extract staging database values using cut
STAGING_DB_HOST=$(grep "staging_db_host" "$STAGING_PROPERTIES" | cut -d'=' -f2)
STAGING_DB_PORT=$(grep "staging_db_port" "$STAGING_PROPERTIES" | cut -d'=' -f2)
STAGING_DB_NAME=$(grep "staging_db_name" "$STAGING_PROPERTIES" | cut -d'=' -f2)
STAGING_DB_USER=$(grep "staging_db_user" "$STAGING_PROPERTIES" | cut -d'=' -f2)
STAGING_DB_PASSWORD=$(grep "staging_db_password" "$STAGING_PROPERTIES" | cut -d'=' -f2)
STAGING_DB_ADMIN_USER=$(grep "staging_db_admin_user" "$STAGING_PROPERTIES" | cut -d'=' -f2)
STAGING_DB_ADMIN_PASSWORD=$(grep "staging_db_admin_password" "$STAGING_PROPERTIES" | cut -d'=' -f2)

# Extract migration settings
MIGRATION_BACKUP_ENABLED=$(grep "migration_backup_enabled" "$STAGING_PROPERTIES" | cut -d'=' -f2)
MIGRATION_URL_UPDATE_ENABLED=$(grep "migration_url_update_enabled" "$STAGING_PROPERTIES" | cut -d'=' -f2)
STAGING_URL=$(grep "staging_url" "$STAGING_PROPERTIES" | cut -d'=' -f2)
PRODUCTION_URL=$(grep "production_url" "$STAGING_PROPERTIES" | cut -d'=' -f2)
```

### **Step 3: Set Final Working Variables**
```bash
# Production database configuration
PRODUCTION_DB="$WORDPRESS_DB_NAME"
DB_HOST="$WORDPRESS_DB_HOST"
DB_USER="$WORDPRESS_DB_USER"
DB_PASSWORD="$WORDPRESS_DB_PASSWORD"
ADMIN_USER="$WORDPRESS_DB_ADMIN_USER"
ADMIN_PASSWORD="$WORDPRESS_DB_ADMIN_PASSWORD"
```

---

## 📊 **Expected Extracted Values**

### **From wordpress.tfvars (Production):**
| Variable | Expected Value | Source |
|----------|----------------|---------|
| `WORDPRESS_DB_HOST` | `34.116.96.136` | Public IP of Cloud SQL |
| `WORDPRESS_DB_NAME` | `fiverivertutoring_production_db` | Production database name |
| `WORDPRESS_DB_USER` | `fiverivertutoring_app` | Application user |
| `WORDPRESS_DB_PASSWORD` | `[from tfvars]` | App user password |
| `WORDPRESS_DB_ADMIN_USER` | `fiverivertutoring_admin` | Admin user |
| `WORDPRESS_DB_ADMIN_PASSWORD` | `[from tfvars]` | Admin password |
| `CLOUD_SQL_INSTANCE` | `jamr-websites-db-prod` | GCP instance name |

### **From fiverivertutoring-wordpress.properties (Staging):**
| Variable | Expected Value | Source |
|----------|----------------|---------|
| `STAGING_DB_HOST` | `localhost` | Staging database host |
| `STAGING_DB_PORT` | `3306` | Staging database port |
| `STAGING_DB_NAME` | `fiverivertutoring_staging_db` | Staging database name |
| `STAGING_DB_USER` | `fiverivertutoring_app` | Staging app user |
| `STAGING_DB_PASSWORD` | `FiveRivers_App_Secure_2024!` | Staging app password |
| `STAGING_DB_ADMIN_USER` | `fiverivertutoring_admin` | Staging admin user |
| `STAGING_DB_ADMIN_PASSWORD` | `FiveRivers_Admin_Secure_2024!` | Staging admin password |

### **Migration Settings:**
| Variable | Expected Value | Purpose |
|----------|----------------|---------|
| `MIGRATION_BACKUP_ENABLED` | `true` | Enable backup before migration |
| `MIGRATION_URL_UPDATE_ENABLED` | `true` | Update URLs during migration |
| `STAGING_URL` | `http://localhost:8083` | Source URL for replacement |
| `PRODUCTION_URL` | `http://34.116.96.136` | Target URL for replacement |

---

## 🔄 **Data Flow in Operations**

### **copy-staging Operation:**
```bash
# Uses staging variables for source
mysqldump -h "$STAGING_HOST" -u "$STAGING_USER" -p"$STAGING_PASSWORD" "$STAGING_DB"

# Uses production variables for target  
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$PRODUCTION_DB"
```

### **backup/restore Operations:**
```bash
# Uses production variables
mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$PRODUCTION_DB"
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$PRODUCTION_DB"
```

### **verify Operation:**
```bash
# Uses production variables for verification
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$PRODUCTION_DB"
```

---

## 🧪 **Testing Data Extraction**

### **Command to see all extracted data:**
```bash
./manage-production-db.sh debug-config
```

### **Command to see current configuration:**
```bash
./manage-production-db.sh show-config
```

### **Command to test database connection:**
```bash
./manage-production-db.sh test-connection
```

---

## ⚠️ **Troubleshooting**

### **If staging data is not loaded:**
1. Check if `../properties/fiverivertutoring-wordpress.properties` exists
2. Verify the file contains the expected `staging_*` variables
3. Check file permissions and syntax
4. Run `debug-config` to see detailed extraction status

### **If production data is not loaded:**
1. Check if `../terraform/wordpress.tfvars` exists
2. Verify the file contains the expected `wordpress_db_*` variables
3. Check file syntax and formatting
4. Run `debug-config` to see detailed extraction status

---

## 📝 **File Locations Summary**

```
prod-deploy/
├── databasemigration/
│   ├── manage-production-db.sh          # Main script
│   ├── extracted_data_staging.md        # This documentation
│   └── backups/                         # Backup directory (auto-created)
├── terraform/
│   └── wordpress.tfvars                 # Production config source
└── properties/
    └── fiverivertutoring-wordpress.properties  # Staging config source
```

---

*Last updated: $(date)*
*Script version: manage-production-db.sh*
