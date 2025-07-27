# Five Rivers Tutoring WordPress Content

This directory contains only the custom WordPress content that gets mounted into the Docker container.

## Structure

```
fiverivertutoring_wordpress/
├── wp-content/           # WordPress content (themes, plugins, uploads)
│   ├── plugins/         # Custom plugins
│   ├── themes/          # WordPress themes
│   ├── uploads/         # Media uploads
│   └── mu-plugins/      # Must-use plugins
└── databasescripts/      # Database scripts
    └── fiveriverstutoring_db.sql
```

## Docker Deployment

The WordPress core files are provided by the `wordpress:latest` Docker image. Only the `wp-content` directory is mounted as a volume.

### Local Development
```bash
cd local-deploy
docker-compose -f docker-compose.local.yml up
```

### Environment Variables
Set these environment variables to connect to your external database:
- `WORDPRESS_DB_HOST` - Database host (default: localhost)
- `WORDPRESS_DB_USER` - Database user (default: fiverriversadmin)
- `WORDPRESS_DB_PASSWORD` - Database password (default: Password@123)
- `WORDPRESS_DB_NAME` - Database name (default: fiveriverstutoring_db)

## Custom Plugins
- `tutoring-scheduler/` - Scheduling functionality
- `progress-tracker/` - Student progress tracking
- `homework-assistant/` - Homework management
- `akismet/` - Spam protection
- `contact-form-7/` - Contact forms
- `elementor/` - Page builder
- `wordpress-seo/` - SEO optimization 