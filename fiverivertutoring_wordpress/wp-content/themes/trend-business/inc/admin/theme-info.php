<?php
$pro_purchase_url = "https://trendthemeswp.com/products/trend-business-pro";
$doc_url = "https://trendthemeswp.com/products/trend-business-pro";
$live_demo_url = "http://demos.trendthemeswp.com/trend-business-pro/";
$support_url = "https://trendthemeswp.com/contact-us/";

$theme_name = esc_html($theme->Name);
$free_theme_name = str_replace(' Pro', '', $theme_name);
?>
<div class="trend-business--about-page--wrapper">
    <div id="trend-business-admin-about-page">
        <div class="trend-business-admin-card-header">
            <div class="trend-business-header-left">
                <h2>
                    <?php echo esc_html($theme->Name); ?>
                </h2>
                <p>
                    <?php esc_html_e('Trend Business - A Multipurpose, browser & device-friendly Full Site Editing Theme for WordPress', 'trend-business'); ?>
                </p>

            </div>
            <div class="trend-business-header-right">
                <div class="trend-business-card-header-button-group">
                    <a href="<?php echo $live_demo_url; ?>" class="trend-business-admin-button premium-button" target="_blank"
                        rel="noreferrer"><span class="dashicons dashicons-book-alt"></span>
                        <?php esc_html_e('Pro Live Demo', 'trend-business'); ?>
                    </a>
                </div>
            </div>
        </div>

        <div class="feature-list">
            <div class="trend-business-about-container">
                <div class="trend-business-admin-card features">
                    <div class="trend-business-about-container trend-business-compare-table">
                        <div class="admin-grid-1">
                            <h3>
                                <?php echo esc_html($free_theme_name); ?>
                                <?php esc_html_e('Free Vs Pro', 'trend-business'); ?>
                            </h3>
                            <p class="trend-business-compare-table-subtitle"><a href="<?php echo $pro_purchase_url; ?>"
                                    target="__blank">
                                    <?php echo esc_html('Get Trend Business Pro', 'trend-business'); ?>
                                    <i class="dashicons dashicons-arrow-right-alt"></i>
                                </a></p>
                            <table>
                                <thead>
                                    <tr>
                                        <th>
                                            <?php echo esc_html($theme->Name); ?>
                                            <?php esc_html_e('Free', 'trend-business'); ?>
                                            <?php esc_html_e('( Limited blocks available )', 'trend-business'); ?>

                                        </th>
                                        <th>
                                            <?php esc_html_e('Features', 'trend-business'); ?>
                                        </th>
                                        <th>
                                            <?php esc_html_e('Trend Business Pro ( More Blocks & Settings available )', 'trend-business'); ?>
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td><span class="dashicons"><?php echo esc_html__('Limited', 'trend-business'); ?></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('All Pre-Built Template', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons"><?php echo esc_html__('Unlimited', 'trend-business'); ?></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Easy Setup', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Responsive Desgin', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons"><?php echo esc_html__('Good', 'trend-business'); ?></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Speed and Performance', 'trend-business'); ?>
                                        </td>
                                        <td><span class=""><?php echo esc_html__('Ultra fast and Lightweight', 'trend-business'); ?></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('SEO Friendly', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-no"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Animation', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-no"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Back to Top Button (Scrool to Top)', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-no"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Icon Picker', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-no"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Contact Form', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-no"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('24/7 premium support', 'trend-business'); ?>
                                        </td>
                                        <td><?php esc_html_e('High-Priority Dedicated Support', 'trend-business'); ?>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-no"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Different niches starter sites', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Secure transaction', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-no"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Lifetime Updates', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('No coding required', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <span class="dashicons dashicons-yes"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Better Customization Without Code', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Advanced Templates', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-no"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Multiple Header/Footer Layouts', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons ">Limited</span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Block Patterns', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons">Unlimited</span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons">Limited</span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Global Style Variations', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td><span class="dashicons dashicons-no"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Premium Support', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-no"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Frequent Updates', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Drag and Drop functionality', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td><span class="dashicons dashicons-no"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e(' Featured Slider', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><?php esc_html_e('Limited', 'trend-business'); ?>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Typography and color options', 'trend-business'); ?>
                                        </td>
                                        <td><?php esc_html_e('Unlimited', 'trend-business'); ?>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><?php esc_html_e('Limited', 'trend-business'); ?>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Import components/ templates', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-no"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('One Click Demo Import', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-no"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Gutenberg block editor', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-no"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Profile card (Block)', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><?php esc_html_e('Limited', 'trend-business'); ?>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Blog (block)', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span><?php esc_html_e('Unlimited', 'trend-business'); ?>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Testimonials(block)', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td><?php esc_html_e('Limited', 'trend-business'); ?>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Templates and block patterns', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><?php esc_html_e('Limited', 'trend-business'); ?>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Advanced Color Options', 'trend-business'); ?>
                                        </td>
                                        <td><?php esc_html_e('Unlimited', 'trend-business'); ?>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-no"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Enable Testimonial Slider', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-no"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Enable Sponsor Slider', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><span class="dashicons dashicons-no"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Enable Sticky Header', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Google Maps zoom level settings', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>

                                    <tr>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                        <td>
                                            <?php esc_html_e('Edit each areas of website(header, footer, sidebar)', 'trend-business'); ?>
                                        </td>
                                        <td><span class="dashicons dashicons-yes"></span>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <div class="trend-business-about-side">
                <div class="trend-business-admin-card cart-two">
                    <h3 class="trend-business-admin-card-title is-small">
                        <?php esc_html_e('Questions Welcome - We\'re here to help', 'trend-business'); ?>
                    </h3>
                    <p>
                        <?php esc_html_e('"Fearless Setup - Our Dedicated Team will have your website up in minutes', 'trend-business'); ?>
                    </p><a href="<?php echo $support_url; ?>" class="trend-business-admin-button primary large"
                        target="_blank">
                        <?php esc_html_e('Get Support', 'trend-business'); ?>
                    </a>
                    <a href="<?php echo $pro_purchase_url; ?>" class="trend-business-admin-button primary large"
                        target="_blank">
                        <?php esc_html_e('Get Premium Version', 'trend-business'); ?>
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>