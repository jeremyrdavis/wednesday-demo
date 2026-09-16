# Docker Brand Style Guide (demo excerpt)

## Palette
| Role | Name | Hex |
|---|---|---|
| Primary action, links | Moby blue | #1D63ED |
| Header / footer background, headings | Dark blue | #00084D |
| Card & section tint | Light blue | #E5F2FC |
| Body text | Off black | #17191E |
| Page background | White | #FFFFFF |
| Accents (borders, hover, tags) | Blue 700 / 400 / 200 | #00308D / #1C90ED / #C0E0FA |

Use white or light-blue text on dark-blue backgrounds. Never place
Moby blue text on dark blue. Body text is off-black on white.

## Typography
Load "Roboto" from Google Fonts (weights 400, 500, 700), with fallback
stack: Roboto, -apple-system, "Segoe UI", Helvetica, Arial, sans-serif.
Headings 600–700 weight. Body 16px, line-height 1.6.

## Components
- **Header:** dark blue (#00084D) full-width bar, white title, subtle
  light-blue tagline.
- **FAQ items:** cards on white — light-blue (#E5F2FC) background,
  8px rounded corners, 24px padding, 16px gaps. Question in dark blue,
  600 weight; answer in off-black. Category shown as a small pill:
  Blue 200 background, Blue 700 text, fully rounded.
- **Empty state:** centered card, light-blue tint, friendly one-liner.
- Max content width 900px, centered. Generous whitespace.

## Rules
- No CSS frameworks, no build tooling — hand-written CSS only.
- Do not fetch docker.com or screenshot any site for reference.
- Maintain WCAG AA contrast throughout.
