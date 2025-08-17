<?php
// WordPress Database Configuration
define('DB_NAME', 'fiverivertutoring_production_db');
define('DB_USER', 'fiverivertutoring_app');
define('DB_PASSWORD', 'FiveRivers_App_Secure_2024!');
define('DB_HOST', '34.116.96.136');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', 'utf8mb4_unicode_ci');

// WordPress URLs
define('WP_HOME', 'http://fiverivertutoring.com');
define('WP_SITEURL', 'http://fiverivertutoring.com');

// Security
define('AUTH_KEY', '0@&W]@)ffy}F-w{O]Xs:eaT{G93XSEd=KCgqDi:n)Gja091QCHu6sy}8)(&5m7I7');
define('SECURE_AUTH_KEY', 'Q=E-N?%<lL52Ef9m79D0=uy{Hw@ow#0Tk5Vxc2E#=T_I$oe6N]HJ)R9+Q8nYW}Ou');
define('LOGGED_IN_KEY', '8{Z+wCENABn#EZ7eH)64xhV<aEpGyH#!9dg=3#-D::]b5YOMlJ>hCPIQ7Fe{H+2+');
define('NONCE_KEY', '[{LVza=Y#&QCrT>T5eq8PoDI_b1>9RHU%dk@$-4}Sm4#dwSJ?>7aL8fz*hf$(C9+');
define('AUTH_SALT', 'Aeuop]PFV>f8m?1L70A(fe3B%ipIcGUcLSQ>tQeZFgZuwM31z_Wb$&YN8&h:EG5H');
define('SECURE_AUTH_SALT', 'SF4$0eZep&bD[ATR4V?a-J0S:$DLDJ4Bm1k=MChxoGCGp)ZUlpM8feu@utraB?FD');
define('LOGGED_IN_SALT', '5u}D1t![:{a?qs9ZL7*9!@$u>O35>2tT+JS-0??YUaiN_Y0XJc6csW&WzJikL:aR');
define('NONCE_SALT', '&Qija3kwVCw&}mrDwZf=P8Cg$cysd)lz1:+ajzLng}o7d71L[O>3_+hq_T]V9?Ph');

// Performance
define('WP_CACHE', true);
define('WP_DEBUG', false);
define('WP_DEBUG_LOG', false);
define('WP_DEBUG_DISPLAY', false);

// File permissions
define('FS_METHOD', 'direct');
define('WP_TEMP_DIR', '/tmp');

// Memory limits
define('WP_MEMORY_LIMIT', '256M');
define('WP_MAX_MEMORY_LIMIT', '512M');
