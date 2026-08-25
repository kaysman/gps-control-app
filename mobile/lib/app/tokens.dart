import 'package:flutter/painting.dart';

// ── Palette ────────────────────────────────────────────────────────────────
// Deep forest ink, fresh green, and a lime pop, on a cool mist canvas.
// Deliberately *not* warm: the previous champagne paper (#F6F4EE) and orange
// accent are gone. Every hue here carries a green undertone so surfaces,
// dividers and greys read as one family instead of four unrelated greys.

/// Primary ink. Body copy, headings, and the dark "hero" card surfaces.
const kInk = Color(0xFF0F1A15);

/// Deepest ink. The floating nav bar and anything that must sit under [kInk].
const kInkDeep = Color(0xFF070E0B);

/// Softer ink for secondary headings and icons on light surfaces.
const kInkSoft = Color(0xFF2A3D34);

/// Bright brand green. Large fills that carry [kInk] text, chips, indicators.
/// Not for small white text — pair it with ink, or reach for [kGreenDeep].
const kGreen = Color(0xFF43C07A);

/// Deep green. Text and icons on light surfaces, and fills carrying white
/// text (5.6:1 against white, so it passes AA both ways).
const kGreenDeep = Color(0xFF12764A);

/// Faint green wash. Section fills and selected rows.
const kGreenWash = Color(0xFFE2F1E7);

/// The signature pop. Only legible on ink — use it on dark surfaces, never on
/// mist or white.
const kLime = Color(0xFFC9F571);

/// App canvas. Cool mist, the anti-champagne.
const kCanvas = Color(0xFFEDF2EE);

/// Tinted fill one step up from [kCanvas]: chips, date separators, inputs.
const kMist = Color(0xFFDFEBE2);

/// Card and sheet surface.
const kWhite = Color(0xFFFFFFFF);

/// Secondary text. 6.2:1 on [kCanvas].
const kMute = Color(0xFF5F7269);

/// Tertiary text, placeholder icons, inactive nav.
const kMute2 = Color(0xFF87998F);

/// Hairline divider — ink at 8%.
const kRule = Color(0x140F1A15);

/// Stronger hairline for borders that must survive on tinted fills — 14%.
const kRuleS = Color(0x240F1A15);

/// Success. Reads as a state, not as brand.
const kOk = Color(0xFF1F8A4C);

/// Caution — a cover left open, a pending write. Tuned for ink surfaces,
/// which is where the app raises cautions.
const kAmber = Color(0xFFF0B429);

/// Danger on light surfaces. Destructive commands and failures.
const kBad = Color(0xFFD0342C);

/// Danger on ink surfaces — [kBad] is too dark to read there.
const kBadOnInk = Color(0xFFFF8A7C);

/// Soft green-tinted elevation. One shadow value for every card in the app.
const kShadow = Color(0x140F1A15);

// ── Radii ───────────────────────────────────────────────────────────────
// Three steps only. Chips are pills; everything else picks one of these.
/// Chips, inputs, small controls.
const kR14 = 14.0;

/// Cards and sheets.
const kR22 = 22.0;

/// Hero cards and the floating nav bar.
const kR30 = 30.0;

// ── Typography ──────────────────────────────────────────────────────────
// Two families, bundled in assets/fonts (see pubspec.yaml) — no runtime font
// fetching. Licences ship beside them.

/// Prose: headings, labels, buttons, body. Manrope's semi-rounded geometry is
/// what gives the display sizes their friendly weight at -1.4 tracking.
const kSans = 'Manrope';

/// The technical voice: all-caps section labels, serials, phone numbers,
/// timestamps, and the raw SMS text under a bubble. Roboto rather than a
/// monospace, because what these have in common is digits, not code — pair it
/// with [kTabular] wherever a number changes in place.
const kTech = 'Roboto';

/// Fixed-width digits. Without this a ticking countdown or a right-aligned
/// clock column reflows on every change.
const kTabular = [FontFeature.tabularFigures()];
