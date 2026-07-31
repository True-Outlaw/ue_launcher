# Fix "Install New Engine" Widget Height Inconsistency

The "Install New Engine" widget currently appears taller than the standard engine display items, as shown in the provided screenshot. This inconsistency is likely due to differences in layout structure, specifically how margins and borders are handled between `UnrealEngineDisplayItem` and `InstallNewEngineItem`.

## User Review Required

> [!IMPORTANT]
> The fix involves refactoring the `InstallNewEngineItem` to match the layout structure of `UnrealEngineDisplayItem`. This includes wrapping it in a `Stack` and using identical margin/padding constants to ensure perfect alignment.

## Proposed Changes

### [Widgets]

#### [MODIFY] [installed_engines_view.dart](file:///E:/Flutter/Projects/UELauncher/lib/widgets/installed_engines_view.dart)
- Refactor `InstallNewEngineItem` to use a `Stack` at its root, matching the structure of `UnrealEngineDisplayItem`.
- Ensure the `Container` within `InstallNewEngineItem` has the same `height` (106) and `margin` (8.0) as `UnrealEngineDisplayItem`.
- Update the internal layout of `InstallNewEngineItem` to match the style shown in the screenshot (centered icon and text on a single line).
- Synchronize `strokeWidth` and `borderRadius` constants between both widgets.

#### [MODIFY] [unreal_engine_display_item.dart](file:///E:/Flutter/Projects/UELauncher/lib/widgets/unreal_engine_display_item.dart)
- (Optional) Extract common dimensions (height, margin, padding) into a shared constant file if they are used in multiple places, to prevent future drift.

## Verification Plan

### Manual Verification
- Run the application and verify that the "Install New" dashed box is perfectly aligned with the engine cards.
- Check that the `-` button on engine cards still overlaps the border correctly while maintaining the overall height consistency.
- Verify that hover states still work as expected.
