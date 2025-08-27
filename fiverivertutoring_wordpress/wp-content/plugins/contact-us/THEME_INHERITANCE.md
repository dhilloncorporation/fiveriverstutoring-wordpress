# Contact US Plugin - Theme Inheritance Feature

## Overview

The Contact US plugin now supports automatic theme inheritance, allowing the contact form to seamlessly integrate with your WordPress theme's design system. This feature uses CSS custom properties (CSS variables) to automatically adopt your theme's colors, fonts, spacing, and styling.

## How It Works

### Theme Inheritance (Default)
When `theme_inherit="true"` (default), the plugin automatically:

- **Colors**: Uses your theme's color palette (primary, secondary, base, contrast, etc.)
- **Typography**: Inherits font families, sizes, and weights from your theme
- **Spacing**: Adopts your theme's spacing units and layout patterns
- **Borders**: Uses theme-appropriate border colors and styles
- **Focus States**: Applies theme-aware focus indicators and hover effects

### Fallback Styling
When `theme_inherit="false"`, the plugin uses the original design with:
- Default color scheme (#20c997 green theme)
- Standard typography
- Original spacing and layout
- Classic form styling

## Usage

### Basic Usage (Theme Inheritance Enabled)
```php
[contact_us_form]
```

### Custom Title with Theme Inheritance
```php
[contact_us_form title="Get In Touch"]
```

### Disable Theme Inheritance
```php
[contact_us_form theme_inherit="false"]
```

### Combine Options
```php
[contact_us_form title="Contact Us" show_phone="false" theme_inherit="true"]
```

## Supported Theme Features

### Color Palette
- `--wp--preset--color--base` - Background colors
- `--wp--preset--color--primary` - Text and headings
- `--wp--preset--color--secondary` - Accent colors
- `--wp--preset--color--theme` - Primary brand color
- `--wp--preset--color--contrast` - Secondary text
- `--wp--preset--color--tertiary` - Light backgrounds
- `--wp--preset--color--table-line` - Borders and dividers

### Typography
- `--wp--preset--font-family--hind` - Primary font family
- `--wp--preset--font-size--small` - Small text
- `--wp--preset--font-size--medium` - Body text
- `--wp--preset--font-size--large` - Subheadings
- `--wp--preset--font-size--x-large` - Main headings

### Spacing
- `--wp--preset--spacing--4` - Button border radius
- `--wp--preset--spacing--20` - Form group margins
- `--wp--preset--spacing--30` - Container padding

## Benefits

### 1. **Seamless Integration**
- Form automatically matches your site's design
- No manual color or font adjustments needed
- Consistent with your brand identity

### 2. **Automatic Updates**
- Form styling updates when you change themes
- Inherits theme customizations automatically
- Maintains consistency across theme updates

### 3. **Professional Appearance**
- Looks like a native part of your website
- Maintains design language consistency
- Improves user experience and trust

### 4. **Flexibility**
- Easy to enable/disable per form instance
- Fallback to original design when needed
- Customizable while maintaining theme integration

## Technical Implementation

### CSS Custom Properties
The plugin uses CSS custom properties with fallback values:
```css
background: var(--wp--preset--color--base, #ffffff);
color: var(--wp--preset--color--primary, #111);
font-family: var(--wp--preset--font-family--hind, inherit);
```

### Theme Detection
- Automatically detects active theme
- Reads theme.json configuration
- Applies appropriate CSS variables
- Graceful fallback to default values

### Responsive Design
- Theme inheritance works across all screen sizes
- Mobile-optimized theme integration
- Touch device considerations
- Print-friendly theme-aware styling

## Browser Support

- **Modern Browsers**: Full theme inheritance support
- **Legacy Browsers**: Graceful fallback to default styling
- **CSS Custom Properties**: Supported in IE11+ with fallbacks

## Customization

### Override Theme Colors
```css
.contact-us-form-container.theme-inherit {
    --wp--preset--color--theme: #your-custom-color;
}
```

### Custom Font Sizes
```css
.contact-us-form-container.theme-inherit .form-group label {
    font-size: 18px !important;
}
```

### Theme-Specific Adjustments
```css
/* Adjust for specific themes */
.theme-trend-business .contact-us-form-container {
    border-radius: 8px;
}
```

## Troubleshooting

### Form Not Inheriting Theme
1. Check if `theme_inherit="true"` is set
2. Verify your theme supports CSS custom properties
3. Check browser console for CSS errors
4. Ensure theme.json is properly configured

### Styling Conflicts
1. Check for conflicting CSS rules
2. Verify CSS specificity
3. Use `!important` sparingly
4. Test with theme inheritance disabled

### Performance
1. CSS custom properties are lightweight
2. Minimal impact on page load
3. Efficient theme switching
4. Optimized for modern browsers

## Examples

### Theme Integration Success
- **Trend Business Theme**: Perfect integration with green accent colors
- **Twenty Twenty-Four**: Seamless adoption of modern design system
- **Custom Themes**: Automatic color and typography inheritance

### Use Cases
- **Business Websites**: Professional, branded contact forms
- **Portfolio Sites**: Consistent design language
- **E-commerce**: Integrated customer service forms
- **Blogs**: Seamless reader engagement

## Future Enhancements

- **Advanced Theme Detection**: Support for more theme systems
- **Custom Color Schemes**: User-defined color palettes
- **Style Presets**: Pre-built design variations
- **Theme Templates**: Ready-to-use form designs

## Support

For questions about theme inheritance:
1. Check this documentation
2. Review the admin panel help section
3. Test with different theme inheritance settings
4. Contact plugin support if issues persist

---

*Theme inheritance ensures your contact form looks like it was designed specifically for your website, not just added as a plugin.*
