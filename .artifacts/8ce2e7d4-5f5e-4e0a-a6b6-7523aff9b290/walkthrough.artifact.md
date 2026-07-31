# Walkthrough - Fixed "Install New Engine" Widget Height

I have updated the `InstallNewEngineItem` widget to ensure its height and alignment perfectly match the existing engine cards.

## Changes Made

### [Widgets]

#### [installed_engines_view.dart](file:///E:/Flutter/Projects/UELauncher/lib/widgets/installed_engines_view.dart)
- Wrapped `InstallNewEngineItem` in a `Stack` to match the hierarchy of `UnrealEngineDisplayItem`.
- Redesigned the internal layout of the "Install New" button to match the desired UI:
    - Replaced the large icon and multi-line text with a centered `Row` containing a smaller icon (size 32) and "Install New" text.
    - Simplified the widget tree by removing unnecessary `Padding` and using `Center` for content alignment within the dashed border.
- Verified that `height` (106), `margin` (8.0), and `strokeWidth` (2.0) are synchronized with `UnrealEngineDisplayItem`.

## Verification Results

### Manual Verification
- The "Install New" dashed card now sits at the same vertical position and has the same height as the engine version cards.
- The UI matches the provided screenshot's design for the installation placeholder.
