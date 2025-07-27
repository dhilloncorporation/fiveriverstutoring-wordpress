-- Admin Login
mysql -u fiverriversadmin -p -h localhost


-- =====================================================
-- Detailed Verification Commands
-- =====================================================

-- Check activated plugins
mysql -u fiverriversadmin -pPassword@123 valueladder_db -e "SELECT option_value FROM wp_options WHERE option_name = 'active_plugins';"

-- Check total pages
mysql -u fiverriversadmin -pPassword@123 valueladder_db -e "SELECT COUNT(*) as total_pages FROM wp_posts WHERE post_type = 'page';"

-- Check total posts
mysql -u fiverriversadmin -pPassword@123 valueladder_db -e "SELECT COUNT(*) as total_posts FROM wp_posts WHERE post_type = 'post';"

-- Check site URL
mysql -u fiverriversadmin -pPassword@123 valueladder_db -e "SELECT option_name, option_value FROM wp_options WHERE option_name IN ('home', 'siteurl');"

-- Check theme
mysql -u fiverriversadmin -pPassword@123 valueladder_db -e "SELECT option_value FROM wp_options WHERE option_name = 'template';"

-- Check users
mysql -u fiverriversadmin -pPassword@123 valueladder_db -e "SELECT COUNT(*) as total_users FROM wp_users;"

-- Check comments
mysql -u fiverriversadmin -pPassword@123 valueladder_db -e "SELECT COUNT(*) as total_comments FROM wp_comments;"

-- Check categories
mysql -u fiverriversadmin -pPassword@123 valueladder_db -e "SELECT COUNT(*) as total_categories FROM wp_terms WHERE term_id IN (SELECT term_id FROM wp_term_taxonomy WHERE taxonomy = 'category');"

-- Check tags
mysql -u fiverriversadmin -pPassword@123 valueladder_db -e "SELECT COUNT(*) as total_tags FROM wp_terms WHERE term_id IN (SELECT term_id FROM wp_term_taxonomy WHERE taxonomy = 'post_tag');"

-- Check recent posts
mysql -u fiverriversadmin -pPassword@123 valueladder_db -e "SELECT ID, post_title, post_date, post_status FROM wp_posts WHERE post_type = 'post' ORDER BY post_date DESC LIMIT 5;"

-- Check recent pages
mysql -u fiverriversadmin -pPassword@123 valueladder_db -e "SELECT ID, post_title, post_date, post_status FROM wp_posts WHERE post_type = 'page' ORDER BY post_date DESC LIMIT 5;"