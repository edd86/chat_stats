---
name: Chats Stats
colors:
  surface: '#0b141b'
  surface-dim: '#0b141b'
  surface-bright: '#313a42'
  surface-container-lowest: '#060f16'
  surface-container-low: '#141d24'
  surface-container: '#182128'
  surface-container-high: '#222b33'
  surface-container-highest: '#2d363e'
  on-surface: '#dae3ee'
  on-surface-variant: '#bbcbb9'
  inverse-surface: '#dae3ee'
  inverse-on-surface: '#293139'
  outline: '#869584'
  outline-variant: '#3c4a3d'
  surface-tint: '#3de273'
  primary: '#4ff07f'
  on-primary: '#003915'
  primary-container: '#25d366'
  on-primary-container: '#005523'
  inverse-primary: '#006d2f'
  secondary: '#7cd0ff'
  on-secondary: '#00344a'
  secondary-container: '#00a4dc'
  on-secondary-container: '#00354a'
  tertiary: '#f8d100'
  on-tertiary: '#3a3000'
  tertiary-container: '#d8b600'
  on-tertiary-container: '#574800'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#66ff8e'
  primary-fixed-dim: '#3de273'
  on-primary-fixed: '#002109'
  on-primary-fixed-variant: '#005322'
  secondary-fixed: '#c4e7ff'
  secondary-fixed-dim: '#7cd0ff'
  on-secondary-fixed: '#001e2c'
  on-secondary-fixed-variant: '#004c69'
  tertiary-fixed: '#ffe16d'
  tertiary-fixed-dim: '#e9c400'
  on-tertiary-fixed: '#221b00'
  on-tertiary-fixed-variant: '#544600'
  background: '#0b141b'
  on-background: '#dae3ee'
  surface-variant: '#2d363e'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Geist
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  stat-display:
    fontFamily: Geist
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  margin-mobile: 20px
  gutter-mobile: 12px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

The design system is engineered for deep social data visualization, targeting power users who want to uncover patterns in their digital communication. The personality is **Professional, Insightful, and Energetic**, balancing the utility of a data tool with the vibrancy of a social platform.

The aesthetic follows a **Modern Dark Mode** approach with elements of **Glassmorphism**. It utilizes high-contrast surfaces and glowing accents to create a sense of depth and focus. The interface should feel technical yet accessible, using subtle background blurs and vibrant data markers to evoke a "command center" feel for personal chat history.

## Colors

The palette centers on a high-energy **Emerald Green** (#25D366), paying homage to the source platform while signaling growth and activity. 

- **Primary**: Emerald Green (#25D366) is used for calls-to-action, success states, and primary data trends.
- **Secondary**: Sky Blue (#34B7F1) is used for interactive elements and secondary data categories (e.g., distinguishing between different participants).
- **Tertiary**: Amber Gold (#FFD700) is reserved for peak activity markers and high-impact insights.
- **Neutral/Background**: The foundation is a deep Charcoal-Navy (#0B141B), providing a sophisticated, low-strain environment that makes the vibrant primary colors and chart data "pop."

## Typography

This design system utilizes **Inter** for its neutral, highly legible character, ensuring that dense statistical information remains easy to scan. To add a technical, data-centric edge, **Geist** is used for labels and large numerical displays (stats), providing a monospaced-adjacent feel that emphasizes precision.

Key stats should always use the `stat-display` role to create a clear information hierarchy. `label-caps` should be used for chart axes and metadata categories to provide structure without overwhelming the primary content.

## Layout & Spacing

The system follows a **Fluid Grid** model optimized for mobile-first consumption. It uses a 4px baseline rhythm to ensure consistency across dense data tables and sparse insight screens.

- **Margins**: A standard 20px side margin provides breathing room on mobile devices.
- **Vertical Rhythm**: Content is grouped into "Data Blocks" using a 32px stack (stack-lg). Internal card elements use 8px or 16px spacing to maintain a tight, organized relationship.
- **Touch Targets**: All interactive elements must maintain a minimum height of 48px to ensure accessibility in a mobile-centric environment.

## Elevation & Depth

Visual hierarchy is established through **Tonal Layering** and **Subtle Glows**.

1.  **Level 0 (Background)**: The deepest neutral color (#0B141B).
2.  **Level 1 (Cards)**: A slightly lighter surface (#16212B) with a subtle 1px border (#243441) to define boundaries without heavy shadows.
3.  **Level 2 (Active/Floating)**: Elements like floating action buttons or active metric cards use a subtle "Outer Glow" in the primary color (opacity 15-20%) to indicate focus and vitality.
4.  **Glass Layers**: Overlays (modals/tooltips) use a 70% opacity version of the card color with a 20px background blur (backdrop-filter) to maintain context of the underlying data.

## Shapes

The shape language is defined as **Rounded**, striking a balance between the friendliness of a social app and the structure of a professional tool. 

- **Cards & Sections**: Use 1rem (16px) corner radii to create a modern, contained look.
- **Buttons & Inputs**: Use 0.5rem (8px) for a more precise, actionable feel.
- **Status Indicators**: Small chips or "live" indicators use a full pill-shape (999px) to distinguish them from structural elements.

## Components

### Buttons
Primary buttons use a solid Emerald Green fill with dark text. Secondary buttons are "Ghost" style with a 1px border in Sky Blue. Buttons should have a slight "elevation glow" on hover/active states to reinforce the energetic style.

### Data Cards
The core of the system. Cards feature a subtle 1px top-border that is 10% lighter than the surface color. Key metrics inside cards are highlighted with the primary color and a minimal bottom-glow effect.

### File Upload Area
Designed as a large, dashed-border container with a 16px radius. The background should be a subtle gradient (Navy to dark Teal) to draw the eye. On "Drag Over," the border and icon transition to the primary Emerald Green.

### Chips & Tags
Used for filtering chat participants or timeframes. These use a dark background with a high-contrast border and 12px font size. Active chips use a full Emerald fill.

### Glow Accents
Use these sparingly for "Aha!" moments or peak stats (e.g., "Most Active Day"). The glow is a soft drop-shadow with a large blur (20px+) and low opacity (0.2) in the primary color.

### Charts & Visualizations
Lines and bars should use rounded caps. Gradients are encouraged for area charts, transitioning from the primary color at 40% opacity to 0% at the baseline.