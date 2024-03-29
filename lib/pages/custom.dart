import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A material design CustomCheckbox.
///
/// The CustomCheckbox itself does not maintain any state. Instead, when the state of
/// the CustomCheckbox changes, the widget calls the [onChanged] callback. Most
/// widgets that use a CustomCheckbox will listen for the [onChanged] callback and
/// rebuild the CustomCheckbox with a new [value] to update the visual appearance of
/// the CustomCheckbox.
///
/// The CustomCheckbox can optionally display three values - true, false, and null -
/// if [tristate] is true. When [value] is null a dash is displayed. By default
/// [tristate] is false and the CustomCheckbox's [value] must be true or false.
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// See also:
///
///  * [CustomCheckboxListTile], which combines this widget with a [ListTile] so that
///    you can give the CustomCheckbox a label.
///  * [Switch], a widget with semantics similar to [CustomCheckbox].
///  * [Radio], for selecting among a set of explicit values.
///  * [Slider], for selecting a value in a range.
///  * <https://material.io/design/components/selection-controls.html#CustomCheckboxes>
///  * <https://material.io/design/components/lists.html#types>
class CustomCheckbox extends StatefulWidget {
  /// Creates a material design CustomCheckbox.
  ///
  /// The CustomCheckbox itself does not maintain any state. Instead, when the state of
  /// the CustomCheckbox changes, the widget calls the [onChanged] callback. Most
  /// widgets that use a CustomCheckbox will listen for the [onChanged] callback and
  /// rebuild the CustomCheckbox with a new [value] to update the visual appearance of
  /// the CustomCheckbox.
  ///
  /// The following arguments are required:
  ///
  /// * [value], which determines whether the CustomCheckbox is checked. The [value]
  ///   can only be null if [tristate] is true.
  /// * [onChanged], which is called when the value of the CustomCheckbox should
  ///   change. It can be set to null to disable the CustomCheckbox.
  ///
  /// The value of [tristate] must not be null.
  const CustomCheckbox(
      {Key key,
      @required this.value,
      this.tristate = false,
      @required this.onChanged,
      this.activeColor,
      this.checkColor,
      this.materialTapTargetSize,
      this.useTapTarget = true})
      : assert(tristate != null),
        assert(tristate || value != null),
        super(key: key);

  /// Whether this CustomCheckbox is checked.
  ///
  /// This property must not be null.
  final bool value;
  final bool useTapTarget;

  /// Called when the value of the CustomCheckbox should change.
  ///
  /// The CustomCheckbox passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the CustomCheckbox with the new
  /// value.
  ///
  /// If this callback is null, the CustomCheckbox will be displayed as disabled
  /// and will not respond to input gestures.
  ///
  /// When the CustomCheckbox is tapped, if [tristate] is false (the default) then
  /// the [onChanged] callback will be applied to `!value`. If [tristate] is
  /// true this callback cycle from false to true to null.
  ///
  /// The callback provided to [onChanged] should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt; for example:
  ///
  /// ```dart
  /// CustomCheckbox(
  ///   value: _throwShotAway,
  ///   onChanged: (bool newValue) {
  ///     setState(() {
  ///       _throwShotAway = newValue;
  ///     });
  ///   },
  /// )
  /// ```
  final ValueChanged<bool> onChanged;

  /// The color to use when this CustomCheckbox is checked.
  ///
  /// Defaults to [ThemeData.toggleableActiveColor].
  final Color activeColor;

  /// The color to use for the check icon when this CustomCheckbox is checked
  ///
  /// Defaults to Color(0xFFFFFFFF)
  final Color checkColor;

  /// If true the CustomCheckbox's [value] can be true, false, or null.
  ///
  /// CustomCheckbox displays a dash when its value is null.
  ///
  /// When a tri-state CustomCheckbox is tapped its [onChanged] callback will be
  /// applied to true if the current value is null or false, false otherwise.
  /// Typically tri-state CustomCheckboxes are disabled (the onChanged callback is
  /// null) so they don't respond to taps.
  ///
  /// If tristate is false (the default), [value] must not be null.
  final bool tristate;

  /// Configures the minimum size of the tap target.
  ///
  /// Defaults to [ThemeData.materialTapTargetSize].
  ///
  /// See also:
  ///
  ///  * [MaterialTapTargetSize], for a description of how this affects tap targets.
  final MaterialTapTargetSize materialTapTargetSize;

  /// The width of a CustomCheckbox widget.
  static const double width = 18.0;

  @override
  _CustomCheckboxState createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final ThemeData themeData = Theme.of(context);
    Size size;
    switch (widget.materialTapTargetSize ?? themeData.materialTapTargetSize) {
      case MaterialTapTargetSize.padded:
        size = const Size(
            2 * kRadialReactionRadius + 8.0, 2 * kRadialReactionRadius + 8.0);
        break;
      case MaterialTapTargetSize.shrinkWrap:
        size = const Size(2 * kRadialReactionRadius, 2 * kRadialReactionRadius);
        break;
    }
    Size noTapTargetSize = Size(CustomCheckbox.width, CustomCheckbox.width);
    final BoxConstraints additionalConstraints =
        BoxConstraints.tight(widget.useTapTarget ? size : noTapTargetSize);
    return _CustomCheckboxRenderObjectWidget(
      value: widget.value,
      tristate: widget.tristate,
      activeColor: widget.activeColor ?? themeData.toggleableActiveColor,
      checkColor: widget.checkColor ?? const Color(0xFFFFFFFF),
      inactiveColor: widget.onChanged != null
          ? themeData.unselectedWidgetColor
          : themeData.disabledColor,
      onChanged: widget.onChanged,
      additionalConstraints: additionalConstraints,
      vsync: this,
    );
  }
}

class _CustomCheckboxRenderObjectWidget extends LeafRenderObjectWidget {
  const _CustomCheckboxRenderObjectWidget({
    Key key,
    @required this.value,
    @required this.tristate,
    @required this.activeColor,
    @required this.checkColor,
    @required this.inactiveColor,
    @required this.onChanged,
    @required this.vsync,
    @required this.additionalConstraints,
  })  : assert(tristate != null),
        assert(tristate || value != null),
        assert(activeColor != null),
        assert(inactiveColor != null),
        assert(vsync != null),
        super(key: key);

  final bool value;
  final bool tristate;
  final Color activeColor;
  final Color checkColor;
  final Color inactiveColor;
  final ValueChanged<bool> onChanged;
  final TickerProvider vsync;
  final BoxConstraints additionalConstraints;

  @override
  _RenderCustomCheckbox createRenderObject(BuildContext context) =>
      _RenderCustomCheckbox(
        value: value,
        tristate: tristate,
        activeColor: activeColor,
        checkColor: checkColor,
        inactiveColor: inactiveColor,
        onChanged: onChanged,
        vsync: vsync,
        additionalConstraints: additionalConstraints,
      );

  @override
  void updateRenderObject(
      BuildContext context, _RenderCustomCheckbox renderObject) {
    renderObject
      ..value = value
      ..tristate = tristate
      ..activeColor = activeColor
      ..checkColor = checkColor
      ..inactiveColor = inactiveColor
      ..onChanged = onChanged
      ..additionalConstraints = additionalConstraints
      ..vsync = vsync;
  }
}

const double _kEdgeSize = CustomCheckbox.width;
const Radius _kEdgeRadius = Radius.circular(1.0);
const double _kStrokeWidth = 2.0;

class _RenderCustomCheckbox extends RenderToggleable {
  _RenderCustomCheckbox({
    bool value,
    bool tristate,
    Color activeColor,
    this.checkColor,
    Color inactiveColor,
    BoxConstraints additionalConstraints,
    ValueChanged<bool> onChanged,
    @required TickerProvider vsync,
  })  : _oldValue = value,
        super(
          value: value,
          tristate: tristate,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          onChanged: onChanged,
          additionalConstraints: additionalConstraints,
          vsync: vsync,
        );

  bool _oldValue;
  Color checkColor;

  @override
  set value(bool newValue) {
    if (newValue == value) return;
    _oldValue = value;
    super.value = newValue;
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isChecked = value == true;
  }

  // The square outer bounds of the CustomCheckbox at t, with the specified origin.
  // At t == 0.0, the outer rect's size is _kEdgeSize (CustomCheckbox.width)
  // At t == 0.5, .. is _kEdgeSize - _kStrokeWidth
  // At t == 1.0, .. is _kEdgeSize
  RRect _outerRectAt(Offset origin, double t) {
    final double inset = 1.0 - (t - 0.5).abs() * 2.0;
    final double size = _kEdgeSize - inset * _kStrokeWidth;
    final Rect rect =
        Rect.fromLTWH(origin.dx + inset, origin.dy + inset, size, size);
    return RRect.fromRectAndRadius(rect, _kEdgeRadius);
  }

  // The CustomCheckbox's border color if value == false, or its fill color when
  // value == true or null.
  Color _colorAt(double t) {
    // As t goes from 0.0 to 0.25, animate from the inactiveColor to activeColor.
    return onChanged == null
        ? inactiveColor
        : (t >= 0.25
            ? activeColor
            : Color.lerp(inactiveColor, activeColor, t * 4.0));
  }

  // White stroke used to paint the check and dash.
  void _initStrokePaint(Paint paint) {
    paint
      ..color = checkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kStrokeWidth;
  }

  void _drawBorder(Canvas canvas, RRect outer, double t, Paint paint) {
    assert(t >= 0.0 && t <= 0.5);
    final double size = outer.width;
    // As t goes from 0.0 to 1.0, gradually fill the outer RRect.
    final RRect inner =
        outer.deflate(math.min(size / 2.0, _kStrokeWidth + size * t));
    canvas.drawDRRect(outer, inner, paint);
  }

  void _drawCheck(Canvas canvas, Offset origin, double t, Paint paint) {
    assert(t >= 0.0 && t <= 1.0);
    // As t goes from 0.0 to 1.0, animate the two check mark strokes from the
    // short side to the long side.
    final Path path = Path();
    const Offset start = Offset(_kEdgeSize * 0.15, _kEdgeSize * 0.45);
    const Offset mid = Offset(_kEdgeSize * 0.4, _kEdgeSize * 0.7);
    const Offset end = Offset(_kEdgeSize * 0.85, _kEdgeSize * 0.25);
    if (t < 0.5) {
      final double strokeT = t * 2.0;
      final Offset drawMid = Offset.lerp(start, mid, strokeT);
      path.moveTo(origin.dx + start.dx, origin.dy + start.dy);
      path.lineTo(origin.dx + drawMid.dx, origin.dy + drawMid.dy);
    } else {
      final double strokeT = (t - 0.5) * 2.0;
      final Offset drawEnd = Offset.lerp(mid, end, strokeT);
      path.moveTo(origin.dx + start.dx, origin.dy + start.dy);
      path.lineTo(origin.dx + mid.dx, origin.dy + mid.dy);
      path.lineTo(origin.dx + drawEnd.dx, origin.dy + drawEnd.dy);
    }
    canvas.drawPath(path, paint);
  }

  void _drawDash(Canvas canvas, Offset origin, double t, Paint paint) {
    assert(t >= 0.0 && t <= 1.0);
    // As t goes from 0.0 to 1.0, animate the horizontal line from the
    // mid point outwards.
    const Offset start = Offset(_kEdgeSize * 0.2, _kEdgeSize * 0.5);
    const Offset mid = Offset(_kEdgeSize * 0.5, _kEdgeSize * 0.5);
    const Offset end = Offset(_kEdgeSize * 0.8, _kEdgeSize * 0.5);
    final Offset drawStart = Offset.lerp(start, mid, 1.0 - t);
    final Offset drawEnd = Offset.lerp(mid, end, t);
    canvas.drawLine(origin + drawStart, origin + drawEnd, paint);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    paintRadialReaction(canvas, offset, size.center(Offset.zero));

    final Offset origin =
        offset + (size / 2.0 - const Size.square(_kEdgeSize) / 2.0);
    final AnimationStatus status = position.status;
    final double tNormalized =
        status == AnimationStatus.forward || status == AnimationStatus.completed
            ? position.value
            : 1.0 - position.value;

    // Four cases: false to null, false to true, null to false, true to false
    if (_oldValue == false || value == false) {
      final double t = value == false ? 1.0 - tNormalized : tNormalized;
      final RRect outer = _outerRectAt(origin, t);
      final Paint paint = Paint()..color = _colorAt(t);

      if (t <= 0.5) {
        _drawBorder(canvas, outer, t, paint);
      } else {
        canvas.drawRRect(outer, paint);

        _initStrokePaint(paint);
        final double tShrink = (t - 0.5) * 2.0;
        if (_oldValue == null || value == null)
          _drawDash(canvas, origin, tShrink, paint);
        else
          _drawCheck(canvas, origin, tShrink, paint);
      }
    } else {
      // Two cases: null to true, true to null
      final RRect outer = _outerRectAt(origin, 1.0);
      final Paint paint = Paint()..color = _colorAt(1.0);
      canvas.drawRRect(outer, paint);

      _initStrokePaint(paint);
      if (tNormalized <= 0.5) {
        final double tShrink = 1.0 - tNormalized * 2.0;
        if (_oldValue == true)
          _drawCheck(canvas, origin, tShrink, paint);
        else
          _drawDash(canvas, origin, tShrink, paint);
      } else {
        final double tExpand = (tNormalized - 0.5) * 2.0;
        if (value == true)
          _drawCheck(canvas, origin, tExpand, paint);
        else
          _drawDash(canvas, origin, tExpand, paint);
      }
    }
  }
}
