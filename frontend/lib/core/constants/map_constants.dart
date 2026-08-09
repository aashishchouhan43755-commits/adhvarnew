/// Matches the SCALE/PAD used to generate `assets/maps/floor_*.svg` from
/// the seeded node coordinates (see backend `core/seed_data.py` and the
/// generator that produced the SVGs). Keeping these in sync means a
/// node's raw (x, y) maps directly onto its pixel position in the SVG
/// artwork with a single linear transform - no per-floor calibration.
class MapConstants {
  MapConstants._();

  static const double svgScale = 3.0;
  static const double svgPad = 60.0;

  /// Fixed canvas size shared by all 3 generated floor_*.svg files.
  static const double canvasWidth = 1410;
  static const double canvasHeight = 910;

  static double toCanvasX(double x) => x * svgScale + svgPad;
  static double toCanvasY(double y) => y * svgScale + svgPad;
}
