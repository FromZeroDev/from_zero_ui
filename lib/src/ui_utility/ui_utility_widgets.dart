import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart' as bitsdojo;
import 'package:bitsdojo_window_platform_interface/window.dart' as bitsdojo_window;
import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:from_zero_ui/from_zero_ui.dart';
import 'package:path_provider/path_provider.dart' as path_provider;


// TODO 2 break this up into individual files

class ResponsiveHorizontalInsetsSliver extends StatelessWidget {

  final Widget sliver;
  final double padding;
  /// Screen width required to add padding
  final double breakpoint;

  const ResponsiveHorizontalInsetsSliver({
    required this.sliver,
    this.padding = 12,
    this.breakpoint = ScaffoldFromZero.screenSizeMedium,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.sizeOf(context).width < breakpoint ? 0 : padding),
      sliver: sliver,
    );
  }

}


class ResponsiveHorizontalInsets extends StatelessWidget {

  final Widget child;
  final double bigPadding;
  final double smallPadding;
  /// Screen width required to add padding
  final double breakpoint;
  final bool asSliver;

  const ResponsiveHorizontalInsets({
    required this.child,
    this.smallPadding = 0,
    this.bigPadding = 12,
    this.breakpoint = ScaffoldFromZero.screenSizeMedium,
    this.asSliver = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final insets = EdgeInsets.symmetric(horizontal: MediaQuery.sizeOf(context).width < breakpoint ? smallPadding : bigPadding);
    if (asSliver) {
      return SliverPadding(
        padding: insets,
        sliver: child,
      );
    } else {
      return Padding(
        padding: insets,
        child: child,
      );
    }
  }

}

class ResponsiveInsetsDialog extends StatelessWidget {

  final Widget child;
  final EdgeInsets bigInsets;
  final EdgeInsets smallInsets;
  /// Screen width required to add padding
  final double breakpoint;

  final Color? backgroundColor;
  final double? elevation;
  final Duration insetAnimationDuration;
  final Curve insetAnimationCurve;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final Clip clipBehavior;
  final ShapeBorder? shape;
  final AlignmentGeometry? alignment;


  const ResponsiveInsetsDialog({
    required this.child,
    this.bigInsets = const EdgeInsets.all(24),
    this.smallInsets = EdgeInsets.zero,
    this.breakpoint = ScaffoldFromZero.screenSizeMedium,
    this.backgroundColor,
    this.elevation,
    this.insetAnimationDuration = const Duration(milliseconds: 100),
    this.insetAnimationCurve = Curves.decelerate,
    this.shadowColor,
    this.surfaceTintColor,
    this.clipBehavior = Clip.none,
    this.shape,
    this.alignment = goldenRatioVerticalAlignment,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    EdgeInsets insets = bigInsets;
    if (size.width < breakpoint) {
      insets = insets.copyWith(
        left: smallInsets.left,
        right: smallInsets.right,
      );
    }
    if (size.height < breakpoint) {
      insets = insets.copyWith(
        top: smallInsets.top,
        bottom: smallInsets.bottom,
      );
    }
    return Dialog (
      insetPadding: insets,
      backgroundColor: backgroundColor,
      elevation: elevation,
      insetAnimationDuration: insetAnimationDuration,
      insetAnimationCurve: insetAnimationCurve,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      clipBehavior: clipBehavior,
      shape: shape,
      alignment: alignment,
      child: child,
    );
  }

}


class LoadingCheckbox extends StatelessWidget{

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final MouseCursor? mouseCursor;
  final Color? activeColor;
  final Color? checkColor;
  final MaterialTapTargetSize? materialTapTargetSize;
  final VisualDensity? visualDensity;
  final Color? focusColor;
  final Color? hoverColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final Widget loadingWidget;
  final Duration transitionDuration;
  final PageTransitionSwitcherTransitionBuilder? pageTransitionBuilder;
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  const LoadingCheckbox({
    required this.value,
    required this.onChanged,
    this.mouseCursor,
    this.activeColor, this.checkColor, this.materialTapTargetSize,
    this.visualDensity, this.focusColor, this.hoverColor, this.focusNode,
    this.autofocus = false,
    this.loadingWidget = const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3,),),
    this.transitionDuration = const Duration(milliseconds: 300),
    this.pageTransitionBuilder,
    AnimatedSwitcherTransitionBuilder? transitionBuilder,
    super.key,
  }) : transitionBuilder = transitionBuilder ?? (pageTransitionBuilder==null ? _defaultTransitionBuilder : null);

  @override
  Widget build(BuildContext context) {
    Widget result;
    if (value==null){
      result = Container(
        height: 40,
        width: 40,
        alignment: Alignment.center,
        child: loadingWidget,
      );
    } else{
      result = Checkbox(
        value: value,
        onChanged: onChanged,
        mouseCursor: mouseCursor,
        activeColor: activeColor,
        checkColor: checkColor,
        focusColor: focusColor,
        hoverColor: hoverColor,
        materialTapTargetSize: materialTapTargetSize,
        visualDensity: visualDensity,
        focusNode: focusNode,
        autofocus: autofocus,
      );
    }
    if (pageTransitionBuilder!=null) {
      return PageTransitionSwitcher(
        transitionBuilder: pageTransitionBuilder!,
        duration: transitionDuration,
        child: result,
      );
    } else {
      return AnimatedSwitcher(
        transitionBuilder: transitionBuilder!,
        duration: transitionDuration,
        child: result,
      );
    }
  }

  static Widget _defaultTransitionBuilder (Widget child, Animation<double> animation) {
    return ScaleTransition(scale: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic), child: child,);
  }

  // PageTransitionSwitcherTransitionBuilder _defaultPageTransitionBuilder = (child, primaryAnimation, secondaryAnimation) {
  //   return FadeThroughTransition(
  //     animation: primaryAnimation,
  //     secondaryAnimation: secondaryAnimation,
  //     fillColor: Colors.transparent,
  //     child: child,
  //   );
  // };

}


class MaterialKeyValuePair extends StatelessWidget {

  final String? title;
  final String? value;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;
  final bool frame;
  final double padding;
  final int? titleMaxLines;
  final int? valueMaxLines;

  const MaterialKeyValuePair({
    required this.title,
    required this.value,
    this.frame=false,
    this.titleStyle,
    this.valueStyle,
    this.padding = 0,
    this.titleMaxLines,
    this.valueMaxLines,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (frame) {
      return Stack(
        fit: StackFit.passthrough,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title!=null)
                Text(title!,
                  maxLines: titleMaxLines,
                  softWrap: titleMaxLines==1 ? false : null,
                  overflow: titleMaxLines==1 ? TextOverflow.fade : null,
                  style: titleStyle ?? Theme.of(context).textTheme.bodySmall,
                ),
              Stack(
                fit: StackFit.passthrough,
                children: [
                  if (value!=null)
                    Padding(
                      padding: const EdgeInsets.only(left: 3, bottom: 1),
                      child: Text(value!,
                        maxLines: valueMaxLines,
                        softWrap: valueMaxLines==1 ? false : null,
                        overflow: valueMaxLines==1 ? TextOverflow.fade : null,
                        style: valueStyle,
                      ),
                    ),
                  const Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(left: 1),
                        child: Divider(
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: VerticalDivider(
                        width: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title!=null)
          Text(title!,
            maxLines: titleMaxLines,
            softWrap: titleMaxLines==1 ? false : null,
            overflow: titleMaxLines==1 ? TextOverflow.fade : null,
            style: titleStyle ?? Theme.of(context).textTheme.bodySmall,
          ),
        SizedBox(height: padding,),
        if (value!=null)
          Text(value!,
            maxLines: valueMaxLines,
            softWrap: valueMaxLines==1 ? false : null,
            overflow: valueMaxLines==1 ? TextOverflow.fade : null,
            style: valueStyle,
          ),
      ],
    );
  }

}


class AppbarFiller extends ConsumerWidget {

  final Widget? child;
  final bool useCurrentHeight;
  final bool keepSafeSpace;

  const AppbarFiller({super.key, 
    this.child,
    this.useCurrentHeight = false,
    this.keepSafeSpace = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = 0;
    // final scaffoldState = context.findAncestorStateOfType<ScaffoldFromZeroState>();
    final scaffold = context.findAncestorWidgetOfExactType<ScaffoldFromZero>();
    if (scaffold!=null && scaffold.bodyFloatsBelowAppbar) {
      final appbarNotifier = ref.watch(fromZeroAppbarChangeNotifierProvider);
      height = useCurrentHeight
          ? appbarNotifier.currentAppbarHeight
          : appbarNotifier.appbarHeight + appbarNotifier.safeAreaOffset;
      height = height.clamp(appbarNotifier.safeAreaOffset, double.infinity);
    }
    return AnimatedPadding(
      padding: EdgeInsets.only(top: height),
      duration: scaffold?.appbarAnimationDuration??const Duration(milliseconds: 300),
      curve: scaffold?.appbarAnimationCurve??Curves.easeOutCubic,
      child: child ?? const SizedBox.shrink(),
    );
  }

}


class OpacityGradient extends StatelessWidget {

  static const left = 0;
  static const right = 1;
  static const top = 2;
  static const bottom = 3;
  static const horizontal = 4;
  static const vertical = 5;

  final Widget child;
  final int direction;
  final double? size;
  final double? percentage;

  const OpacityGradient({
    required this.child,
    this.direction = vertical,
    double? size,
    this.percentage,
    super.key,
  }) :
    assert(size==null || percentage==null, "Can't set both a hard size and a percentage."),
    size = size==null&&percentage==null ? 16 : size
  ;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return child;
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: direction==top || direction==bottom || direction==vertical
            ? Alignment.topCenter : Alignment.centerLeft,
        end: direction==top || direction==bottom || direction==vertical
            ? Alignment.bottomCenter : Alignment.centerRight,
        stops: [
          0,
          direction==bottom || direction==right ? 0
              : size==null ? percentage!
              : size!/(direction==top || direction==bottom || direction==vertical ? bounds.height : bounds.width),
          direction==top || direction==left ? 1
              : size==null ? 1-percentage!
              : 1-size!/(direction==top || direction==bottom || direction==vertical ? bounds.height : bounds.width),
          1,
        ],
        colors: const [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
      ).createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height)),
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}


class ScrollOpacityGradient extends StatefulWidget {

  final ScrollController scrollController;
  final Widget child;
  final double maxSize;
  final int direction;
  final bool applyAtStart;
  final bool applyAtEnd;

  const ScrollOpacityGradient({
    required this.scrollController,
    required this.child,
    this.maxSize = 16,
    this.direction = OpacityGradient.vertical,
    this.applyAtEnd = true,
    this.applyAtStart = true,
    super.key,
  });

  @override
  ScrollOpacityGradientState createState() => ScrollOpacityGradientState();

}
class ScrollOpacityGradientState extends State<ScrollOpacityGradient> {

  double size1 = 0;
  double size2 = 0;

  @override
  void initState() {
    super.initState();
    _addListener(widget.scrollController);
    _updateScroll();
  }

  @override
  void didUpdateWidget(ScrollOpacityGradient oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController!=widget.scrollController) {
      _removeListener(oldWidget.scrollController);
      _addListener(widget.scrollController);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _removeListener(widget.scrollController);
  }

  void _addListener(ScrollController scrollController) {
    scrollController.addListener(_updateScroll);
  }

  void _removeListener(ScrollController scrollController) {
    scrollController.removeListener(_updateScroll);
  }

  void _updateScroll(){
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted){
        double newSize1, newSize2;
        try{
          newSize1 = widget.scrollController.position.pixels.clamp(0, widget.maxSize);
          newSize2 = (widget.scrollController.position.maxScrollExtent-widget.scrollController.position.pixels).clamp(0, widget.maxSize);
        } catch (e){
          newSize1 = 0;
          newSize2 = 0;
        }
        if (newSize1!=size1 || newSize2!=size2) {
          setState(() {
            size1 = newSize1;
            size2 = newSize2;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = NotificationListener(
      child: widget.child,
      onNotification: (notification) {
        if (notification is ScrollMetricsNotification
            || notification is ScrollNotification) {
          _updateScroll();
        }
        return false;
      },
    );
    if (widget.direction==OpacityGradient.horizontal || widget.direction==OpacityGradient.vertical) {
      return OpacityGradient(
        size: widget.applyAtStart ? size1 : 0,
        direction: widget.direction==OpacityGradient.horizontal ? OpacityGradient.left : OpacityGradient.top,
        child: OpacityGradient(
          size: widget.applyAtEnd ? size2 : 0,
          direction: widget.direction==OpacityGradient.horizontal ? OpacityGradient.right : OpacityGradient.bottom,
          child: child,
        ),
      );
    } else {
      return OpacityGradient(
        size: widget.direction==OpacityGradient.left || widget.direction==OpacityGradient.top
            ? size1 : size2,
        direction: widget.direction,
        child: child,
      );
    }
  }

}


class OverflowScroll extends StatefulWidget {

  final ScrollController? scrollController;
  /// Autoscroll speed in pixels per second if null, disable autoscroll
  final double? autoscrollSpeed;
  final double opacityGradientSize;
  final Duration autoscrollWaitTime;
  final Duration initialAutoscrollWaitTime;
  final Axis scrollDirection;
  final Widget child;
  final bool consumeScrollNotifications;

  const OverflowScroll({
    required this.child,
    this.scrollController,
    this.autoscrollSpeed = 64,
    this.opacityGradientSize = 16,
    this.autoscrollWaitTime = const Duration(seconds: 5),
    this.initialAutoscrollWaitTime = const Duration(seconds: 3),
    this.scrollDirection = Axis.horizontal,
    this.consumeScrollNotifications = true,
    super.key,
  });

  @override
  OverflowScrollState createState() => OverflowScrollState();

}

class OverflowScrollState extends State<OverflowScroll> {

  late ScrollController scrollController;

  @override
  void initState() {
    scrollController = widget.scrollController ?? ScrollController();
    if (widget.autoscrollSpeed!=null && widget.autoscrollSpeed!>0){
      _scroll(true, widget.initialAutoscrollWaitTime);
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant OverflowScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController!=null) {
      scrollController = widget.scrollController!;
    }
  }

  Future<void> _scroll([bool forward=true, Duration? waitDuration]) async{
    if (!mounted) return;
    await Future.delayed(waitDuration ?? widget.autoscrollWaitTime);
    if (!mounted) return;
    try {
      Duration duration = (1000*scrollController.position.maxScrollExtent/widget.autoscrollSpeed!).milliseconds;
      if (forward){
        await scrollController.animateTo(scrollController.position.maxScrollExtent, duration: duration, curve: Curves.linear);
      } else{
        await scrollController.animateTo(0, duration: duration, curve: Curves.linear);
      }
      _scroll(!forward);
    } catch(_){}
  }

  @override
  Widget build(BuildContext context) {
    Widget result;
    result = SingleChildScrollView(
      controller: scrollController,
      scrollDirection: widget.scrollDirection,
      child: widget.child,
    );
    if (widget.opacityGradientSize>0) {
      result = ScrollOpacityGradient(
        scrollController: scrollController,
        direction: widget.scrollDirection==Axis.horizontal ? OpacityGradient.horizontal : OpacityGradient.vertical,
        maxSize: widget.opacityGradientSize,
        child: result,
      );
    }
    result = NotificationListener(
      onNotification: (notification) => widget.consumeScrollNotifications,
      child: result,
    );
    return result;
  }

}


class ExpandIconButton extends StatefulWidget {

  final bool value;
  final void Function(bool value)? onPressed;
  final EdgeInsetsGeometry padding;

  const ExpandIconButton({
    required this.value,
    required this.onPressed,
    this.padding = const EdgeInsets.all(8),
    super.key,
  });

  @override
  ExpandIconButtonState createState() => ExpandIconButtonState();

}

class ExpandIconButtonState extends State<ExpandIconButton> with SingleTickerProviderStateMixin {

  late final AnimationController controlPanelAnimationController;
  late final Animatable<double> _halfTween;
  late final Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _halfTween = Tween<double>(begin: 0.0, end: 0.5);
    controlPanelAnimationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    controlPanelAnimationController.value = widget.value ? 1 : 0;
    _iconTurns = controlPanelAnimationController.drive(_halfTween.chain(CurveTween(curve: Curves.easeIn)));
  }

  @override
  void didUpdateWidget(covariant ExpandIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value) {
      controlPanelAnimationController.forward();
    } else {
      controlPanelAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 32,
      padding: widget.padding,
      onPressed: widget.onPressed==null ? null : () {
        widget.onPressed!(!widget.value);
      },
      icon: RotationTransition(
        turns: _iconTurns,
        child: AnimatedBuilder(
          animation: controlPanelAnimationController,
          builder: (context, child) {
            return Icon(Icons.expand_more,
              color: ColorTween(
                end: Theme.of(context).colorScheme.secondary,
                begin: Theme.of(context).textTheme.bodyLarge!.color,
              ).evaluate(controlPanelAnimationController),
              size: 32,
            );
          },
        ),
      ),
    );
  }

}



class ReturnToTopButton extends ConsumerStatefulWidget {

  final ScrollController scrollController;
  final Widget child;
  final Widget? icon;
  final Duration? duration;
  final VoidCallback? onTap;
  final double minThresholdFromTop;
  final bool showOnlyWhenScrollingUp;

  const ReturnToTopButton({
    required this.scrollController,
    required this.child,
    this.onTap,
    this.icon,
    this.minThresholdFromTop = 256,
    this.showOnlyWhenScrollingUp = true,
    this.duration = const Duration(milliseconds: 300),
    super.key,
  });

  @override
  ReturnToTopButtonState createState() => ReturnToTopButtonState();

}
class ReturnToTopButtonState extends ConsumerState<ReturnToTopButton> {

  double? lastScrollControllerOffset;
  double currentScrollingAmount = 0;
  bool isScrollingUp = false;
  ValueNotifier<bool> showButton = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(update);
  }

  @override
  void didUpdateWidget(ReturnToTopButton oldWidget) {
    oldWidget.scrollController.removeListener(update);
    widget.scrollController.addListener(update);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(update);
    super.dispose();
  }

  void update(){
    if (mounted) {
      bool show = false;
      try {
        final offset = widget.scrollController.position.pixels;
        show = offset > widget.minThresholdFromTop;
        if (widget.showOnlyWhenScrollingUp) {
          if (lastScrollControllerOffset!=null) {
            final diff = offset - lastScrollControllerOffset!;
            if (diff!=0) {
              if (currentScrollingAmount.isNegative != diff.isNegative) {
                currentScrollingAmount = 0; // reset scroll direction
              }
              currentScrollingAmount += diff;
              if (!isScrollingUp) {
                isScrollingUp = currentScrollingAmount < -48;
              } else {
                isScrollingUp = currentScrollingAmount <= 48;
              }
            }
          }
          show = show && isScrollingUp;
          lastScrollControllerOffset = offset;
        }
      } catch(_){}
      showButton.value = show;
    }
  }

  @override
  Widget build(BuildContext context) {
    double space = 16;
    try{
      space = ref.watch(fromZeroScreenProvider.select((value) => value.isMobileLayout)) ? 16 : 32;
    } catch(_){}
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned(
          bottom: space, right: space,
          child: ValueListenableBuilder(
            valueListenable: showButton,
            builder: (context, showButton, child) {
              Widget result;
              if (!showButton) {
                result = const SizedBox.shrink();
              } else {
                result = TooltipFromZero(
                  message: FromZeroLocalizations.of(context).translate('return_to_top'),
                  child: FloatingActionButton(
                    heroTag: null,
                    backgroundColor: Theme.of(context).cardColor,
                    onPressed: widget.onTap ?? () {
                      if (widget.duration==null){
                        widget.scrollController.jumpTo(0);
                      } else{
                        widget.scrollController.animateTo(0, duration: widget.duration!, curve: Curves.easeOutCubic);
                      }
                    },
                    child: widget.icon ?? Icon(Icons.arrow_upward,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                );
                }
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween(begin: const Offset(0, 1), end: Offset.zero,).animate(animation),
                  child: ZoomedFadeInTransition(animation: animation, child: child,),
                ),
                child: result,
              );
            },
          ),
        ),
      ],
    );
  }

}


class TextIcon extends StatelessWidget {

  final String text;
  final double width;
  final double height;

  const TextIcon(
      this.text,
      {super.key, this.width = 24,
      this.height = 24,}
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width, height: height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).brightness==Brightness.light ? Colors.black45 : Colors.white,
        ),
        child: Center(
          child: Text(
            text.toUpperCase(),
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).cardColor),
          ),
        ),
      ),
    );
  }

}


class TitleTextBackground extends StatelessWidget {

  final double paddingTop;
  final double paddingBottom;
  final double paddingLeft;
  final double paddingRight;
  final Widget? child;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const TitleTextBackground({super.key, 
    double paddingVertical = 8,
    double paddingHorizontal = 24,
    double? paddingTop,
    double? paddingBottom,
    double? paddingLeft,
    double? paddingRight,
    this.child,
    this.backgroundColor,
    this.onTap,
  })  : paddingTop = paddingTop ?? paddingVertical,
        paddingBottom = paddingBottom ?? paddingVertical,
        paddingLeft = paddingLeft ?? paddingHorizontal,
        paddingRight = paddingRight ?? paddingHorizontal;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = this.backgroundColor ?? Theme.of(context).canvasColor;
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double stopPercentageLeft = (paddingLeft/constraints.maxWidth).clamp(0, 1);
              double stopPercentageRight = 1 - (paddingRight/constraints.maxWidth).clamp(0, 1);
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      backgroundColor.withOpacity(0),
                      backgroundColor.withOpacity(0.8),
                      backgroundColor.withOpacity(0.8),
                      backgroundColor.withOpacity(0),
                    ],
                    stops: [0, stopPercentageLeft, stopPercentageRight, 1,],
                  ),
                ),
              );
            },
          ),
        ),
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.fromLTRB(paddingLeft, paddingTop, paddingRight, paddingBottom),
              child: child,
            ),
          ),
        ),
      ],
    );
  }

}


class IconButtonBackground extends StatelessWidget {

  final Widget child;

  const IconButtonBackground({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(666)),
        gradient: RadialGradient(
          colors: [
            (Theme.of(context).brightness==Brightness.light
                ? Colors.grey.shade100 : const Color.fromRGBO(55, 55, 55, 1)).withOpacity(0.8),
            (Theme.of(context).brightness==Brightness.light
                ? Colors.grey.shade100 : const Color.fromRGBO(55, 55, 55, 1)).withOpacity(0),
          ],
          stops: const [
            0.5,
            1,
          ],
        ),
      ),
      child: child,
    );
  }

}



class AnimatedIconFromZero extends StatefulWidget {

  final AnimatedIconData icon;
  final bool value;
  final Duration duration;
  final Curve curve;
  final Curve reverseCurve;
  final Color? color;
  final double? size;


  const AnimatedIconFromZero({
    required this.icon,
    required this.value,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOutCubic,
    this.reverseCurve = Curves.easeInCubic,
    this.color,
    this.size,
    super.key,
  });

  @override
  State<AnimatedIconFromZero> createState() => _AnimatedIconFromZeroState();

}
class _AnimatedIconFromZeroState extends State<AnimatedIconFromZero> with SingleTickerProviderStateMixin {

  late final controller = AnimationController(
    vsync: this,
    value: widget.value ? 0 : 1,
    duration: widget.duration,
  );
  late final animation = CurvedAnimation(
    parent: controller,
    curve: widget.curve,
    reverseCurve: widget.reverseCurve,
  );

  @override
  void didUpdateWidget(covariant AnimatedIconFromZero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (mounted) {
      if (widget.value) {
        controller.reverse();
      } else {
        controller.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedIcon(
      icon: widget.icon,
      progress: animation,
      color: widget.color,
      size: widget.size,
    );
  }

}



class FrameThrottleWidget extends StatefulWidget {

  /// if skipCount==1, the widget will only wait a frame if maxWidgetsBuiltPerFrame
  /// were already built in the current frame, otherwise it will build normally
  /// to always skip at least a frame, set frameSkipCount = 2
  final int frameSkipCount;
  final WidgetBuilder paceholderBuilder;
  final WidgetBuilder childBuilder;
  final InitiallyAnimatedWidgetBuilder? transitionBuilder;
  final Duration transitionDuration;
  final Curve curve;
  /// maxWidgetsBuiltPerFrame assumes it is the same for all widgets, if we want
  /// widgets of different values to coexist, this code would be more complicated
  /// also consider providing a "skipGroupKey" to separate into different queues
  final int maxWidgetsBuiltPerFrame;

  const FrameThrottleWidget({
    required this.paceholderBuilder,
    required this.childBuilder,
    this.frameSkipCount = 1,
    this.transitionBuilder,
    this.transitionDuration = const Duration(milliseconds: 250,),
    this.curve = Curves.easeOutCubic,
    this.maxWidgetsBuiltPerFrame = 1,
    super.key,
  });

  @override
  FrameThrottleWidgetState createState() => FrameThrottleWidgetState();

}

class FrameThrottleWidgetState extends State<FrameThrottleWidget> {

  // global queue ftw
  static int widgetsBuildThisFrame = 0;
  static final statesWantingToBuild = <FrameThrottleWidgetState>[];
  late int skipFramesLeft;
  bool builtPlaceHolder = false;

  @override
  void initState() {
    super.initState();
    skipFramesLeft = widget.frameSkipCount;
    if (widgetsBuildThisFrame < widget.maxWidgetsBuiltPerFrame) {
      widgetsBuildThisFrame++;
      skipFramesLeft--;
    }
    if (skipFramesLeft > 0) {
      statesWantingToBuild.add(this);
    }
    if (!_queueInitialized) {
      _queueInitialized = true;
      _processQueueAfterFrame();
    }
  }

  @override
  void dispose() {
    super.dispose();
    statesWantingToBuild.remove(this);
  }

  static bool _queueInitialized = false;
  static void _processQueueAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widgetsBuildThisFrame = 0;
      for (int i=0; i<statesWantingToBuild.length; i++) {
        final e = statesWantingToBuild[i];
        e.skipFramesLeft--;
        if (widgetsBuildThisFrame < e.widget.maxWidgetsBuiltPerFrame
            && e.skipFramesLeft <= 0) {
          statesWantingToBuild.first.setState(() {});
          statesWantingToBuild.removeAt(i);
          i--;
          widgetsBuildThisFrame++;
        }
      }
      _processQueueAfterFrame();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (skipFramesLeft > 0) {
      builtPlaceHolder = true;
      return widget.paceholderBuilder(context);
    }
    if (builtPlaceHolder) {
      return InitiallyAnimatedWidget(
        builder: widget.transitionBuilder ?? (animation, child) {
          return FadeTransition(opacity: animation, child: child,);
        },
        duration: widget.transitionDuration,
        curve: widget.curve,
        child: widget.childBuilder(context),
      );
    }
    return widget.childBuilder(context);
  }

}



typedef InitiallyAnimatedWidgetBuilder = Widget Function(Animation<double> animation, Widget? child);
class InitiallyAnimatedWidget extends StatefulWidget {

  final InitiallyAnimatedWidgetBuilder? builder;
  final Duration duration;
  final Curve curve;
  final Widget? child;
  final bool? repeat; /// false: don't repeat, null: repeat once, true: repeate forever
  final bool reverse;
  final VoidCallback? onFinish;

  const InitiallyAnimatedWidget({
    super.key,
    this.builder,
    this.duration = const Duration(milliseconds: 300,),
    this.curve = Curves.easeOutCubic,
    this.child,
    this.repeat = false,
    this.reverse = true,
    this.onFinish,
  })  : assert(!(repeat==true && onFinish!=null), "Can't specify onFinish callbacks for an infinite loop");

  @override
  InitiallyAnimatedWidgetState createState() => InitiallyAnimatedWidgetState();

}

class InitiallyAnimatedWidgetState extends State<InitiallyAnimatedWidget> with SingleTickerProviderStateMixin {

  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    animation = CurvedAnimation(
      parent: animationController,
      curve: widget.curve,
    );
    startAnimation();
  }
  Future<void> startAnimation() async {
    if (widget.repeat==null) {
      await animationController.forward();
      await animationController.reverse();
    } else if (widget.repeat!) {
      await animationController.repeat(
        reverse: widget.reverse,
      );
    } else {
      await animationController.forward();
    }
    widget.onFinish?.call();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      child: widget.child,
      builder: (context, child) {
        if (widget.builder!=null) {
          return widget.builder!(animation, widget.child);
        } else {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        }
      },
    );
  }

}


class KeepAliveMixinWidget extends StatefulWidget {
  final Widget child;
  const KeepAliveMixinWidget({required this.child, super.key});
  @override
  KeepAliveMixinWidgetState createState() => KeepAliveMixinWidgetState();
}

class KeepAliveMixinWidgetState extends State<KeepAliveMixinWidget> with
                          AutomaticKeepAliveClientMixin<KeepAliveMixinWidget> {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}



// class ScrollRelayer extends StatelessWidget {
//
//   final TrackingScrollControllerFomZero controller;
//   final Widget child;
//
//   ScrollRelayer({
//     required this.controller,
//     required this.child,
//     Key? key,
//   }) : super(key: key);
//
//   final GlobalKey<ScrollableState> scrollableGlobalKey = GlobalKey();
//
//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       final position = scrollableGlobalKey.currentState!.position;
//       final controllerPositions = (controller.positions as List<ScrollPosition>);
//       // controllerPositions.remove(position);
//       // controllerPositions.add(position);
//     });
//     return Scrollable(
//       controller: controller,
//       key: scrollableGlobalKey,
//       viewportBuilder: (context, position) {
//         return AnimatedBuilder(
//           animation: controller,
//           child: child,
//           builder: (context, child) {
//             double? height;
//             try {
//               final position = controller.position;
//               height = position.viewportDimension + position.maxScrollExtent;
//             } catch(_) {}
//             return Stack(
//               children: [
//                 child!,
//                 Viewport(
//                   offset: position,
//                   slivers: [
//                     SliverToBoxAdapter(
//                       child: SizedBox(height: height,),
//                     ),
//                   ],
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }



class FlexibleLayoutFromZero extends StatelessWidget {

  final Axis axis;
  /// if relevantAxisMaxSize is provided, there is no need for a LayoutBuilder,
  /// min(relevantAxisMaxSize, MediaQuery.maxWidth) will be used instead
  /// if the layout can span the entire screen, set relevantAxisMaxSize=double.infinity
  final double? relevantAxisMaxSize;
  final List<FlexibleLayoutItemFromZero> children;
  final CrossAxisAlignment crossAxisAlignment;
  final bool applyIntrinsicCrossAxis;

  const FlexibleLayoutFromZero({
    required this.children,
    this.axis = Axis.horizontal,
    this.relevantAxisMaxSize,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.applyIntrinsicCrossAxis = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (relevantAxisMaxSize!=null) {
      final size = MediaQuery.sizeOf(context);
      final relevantScreenSize = axis==Axis.horizontal
          ? size.width
          : size.height;
      return buildInternal(context, min(relevantAxisMaxSize!, relevantScreenSize));
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          return buildInternal(context, axis==Axis.horizontal ? constraints.maxWidth : constraints.maxHeight);
        },
      );
    }
  }

  Widget buildInternal(BuildContext context, double relevantAxisSize) {
    double minTotalSize = children.sumBy((e) => e.minSize); // TODO 3 these calculations should probably be done in a render object
    Map<int, FlexibleLayoutItemFromZero> expandableItems = {};
    Map<int, double> itemSizes = {};
    for (int i=0; i<children.length; i++) {
      itemSizes[i] = children[i].minSize;
      if (children[i].maxSize > children[i].minSize) {
        expandableItems[i] = children[i];
      }
    }
    double extraSize = relevantAxisSize-minTotalSize;
    bool addScroll = extraSize < 0;
    extraSize = extraSize.clamp(0, double.infinity);
    while (extraSize!=0 && expandableItems.isNotEmpty) {
      double totalFlex = expandableItems.values.sumBy((e) => e.flex);
      for (final key in expandableItems.keys) {
        final percentage = totalFlex==0
            ? 1 / expandableItems.length
            : expandableItems[key]!.flex / totalFlex;
        itemSizes[key] = itemSizes[key]! + (extraSize * percentage);
      }
      extraSize = 0;
      List<int> keysToRemove = [];
      for (final key in expandableItems.keys) {
        if (expandableItems[key]!.maxSize <= itemSizes[key]!) {
          final difference = itemSizes[key]! - expandableItems[key]!.maxSize;
          itemSizes[key] = expandableItems[key]!.maxSize;
          extraSize += difference;
          keysToRemove.add(key);
        }
      }
      for (final key in keysToRemove) {
        expandableItems.remove(key);
      }
    }
    List<Widget> sizedChildren = children.mapIndexed((index, e) {
      return SizedBox(
        height: axis==Axis.vertical ? itemSizes[index] : null,
        width: axis==Axis.horizontal ? itemSizes[index] : null,
        child: e,
      );
    }).toList();
    Widget result;
    if (axis==Axis.horizontal) {
      result = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: crossAxisAlignment,
        children: sizedChildren,
      );
      if (applyIntrinsicCrossAxis) {
        result = IntrinsicHeight(child: result,);
      }
    } else {
      result = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: sizedChildren,
      );
      if (applyIntrinsicCrossAxis) {
        result = IntrinsicWidth(child: result,);
      }
    }
    if (addScroll) {
      final scrollController = ScrollController();
      result = ScrollbarFromZero(
        controller: scrollController,
        opacityGradientDirection: axis==Axis.horizontal ? OpacityGradient.horizontal
            : OpacityGradient.vertical,
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: axis,
          child: result,
        ),
      );
    }
    return result;
  }

}
class FlexibleLayoutItemFromZero extends StatelessWidget {

  final double minSize;
  final double maxSize;
  /// defines the priority with which space remaining after al minWidth is filled
  /// is distributed among items
  final double flex;
  final Widget child;

  const FlexibleLayoutItemFromZero({
    required this.child,
    this.maxSize = double.infinity,
    this.minSize = 0,
    this.flex = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }

}



typedef TimedOverlayBuilder = Widget Function(BuildContext context, Duration elapsed, Duration remaining);
class TimedOverlay extends StatefulWidget {

  final Duration duration;
  final Duration rebuildInterval;
  final TimedOverlayBuilder builder;
  final TimedOverlayBuilder overlayBuilder;

  const TimedOverlay({
    required this.duration,
    required this.builder,
    this.rebuildInterval = const Duration(seconds: 1),
    this.overlayBuilder = defaultOverlayBuilder,
    super.key,
  });

  @override
  State<TimedOverlay> createState() => _TimedOverlayState();

  static Widget defaultOverlayBuilder(BuildContext context, Duration elapsed, Duration remaining) {
    final remainingSeconds = (remaining.inMicroseconds / Duration.microsecondsPerSecond).ceil();
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Text(remainingSeconds.toString(),
          key: ValueKey(remainingSeconds),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

}

class _TimedOverlayState extends State<TimedOverlay> {

  Duration elapsed = Duration.zero;
  late int lastRemainingCount;

  @override
  void initState() {
    super.initState();
    lastRemainingCount = (widget.duration.inMicroseconds/widget.rebuildInterval.inMicroseconds).ceil();
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (mounted) {
        elapsed += const Duration(milliseconds: 10);
        final remaining = widget.duration - elapsed;
        final remainingCount = (remaining.inMicroseconds/widget.rebuildInterval.inMicroseconds).ceil();
        if (remainingCount < lastRemainingCount || elapsed >= widget.duration) {
          setState(() {
            lastRemainingCount = remainingCount;
            if (elapsed >= widget.duration) {
              timer.cancel();
            }
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Duration remaining = widget.duration - elapsed;
    if (remaining.isNegative) remaining = Duration.zero;
    return Stack(
      children: [
        widget.builder(context, elapsed, remaining),
        if (remaining > Duration.zero)
          Positioned.fill(
            child: widget.overlayBuilder(context, elapsed, remaining),
          ),
      ],
    );
  }

}






class PlatformExtended {

  static final _appWindow = kIsWeb || isMobile ? null : bitsdojo.appWindow;
  static bitsdojo_window.DesktopWindow? get appWindow => !windowsDesktopBitsdojoWorking ? null : _appWindow;

  static bool get isWindows{
    if (kIsWeb){
      return defaultTargetPlatform==TargetPlatform.windows;
    } else{
      return Platform.isWindows;
    }
  }

  static bool get isAndroid{
    if (kIsWeb){
      return defaultTargetPlatform==TargetPlatform.android;
    } else{
      return Platform.isAndroid;
    }
  }

  static bool get isIOS{
    if (kIsWeb){
      return defaultTargetPlatform==TargetPlatform.iOS;
    } else{
      return Platform.isIOS;
    }
  }

  static bool get isLinux{
    if (kIsWeb){
      return defaultTargetPlatform==TargetPlatform.linux;
    } else{
      return Platform.isLinux;
    }
  }

  static bool get isMacOS{
    if (kIsWeb){
      return defaultTargetPlatform==TargetPlatform.macOS;
    } else{
      return Platform.isMacOS;
    }
  }

  static bool get isFuchsia{
    if (kIsWeb){
      return defaultTargetPlatform==TargetPlatform.fuchsia;
    } else{
      return Platform.isFuchsia;
    }
  }

  static bool get isMobile{
    return PlatformExtended.isAndroid||PlatformExtended.isIOS;
  }

  static bool get isDesktop{
    return !PlatformExtended.isMobile;
  }

  static String? customDownloadsDirectory;
  static Future<Directory> getDownloadsDirectory() async {
    if (customDownloadsDirectory!=null) return Directory(customDownloadsDirectory!);
    if (kIsWeb) {
      throw UnimplementedError('Web needs to download through the browser');
    }

    Directory? result;
    if (Platform.isWindows) {

      result = await path_provider.getApplicationDocumentsDirectory();
      if (!(await result.exists())) {
        result = await getDownloadsDirectory();
      }

    } else if (Platform.isAndroid) {

      result = Directory('/storage/emulated/0/Download');
      if (!(await result.exists())) {
        result = await path_provider.getExternalStorageDirectory();
      }

    }

    if (result==null || !(await result.exists())) {
      result = await path_provider.getApplicationDocumentsDirectory();
    }
    return result;
  }

}


extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true, bool includeAlpha=true}) => '${leadingHashSign ? '#' : ''}'
      '${includeAlpha ? alpha.toRadixString(16).padLeft(2, '0') : ''}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}


extension InverseBrigtenes on Brightness {
  Brightness get inverse => this==Brightness.light
      ? Brightness.dark : Brightness.light;
}


class SideClipper extends CustomClipper<Path> {
  bool clipLeft;
  bool clipRight;
  bool clipTop;
  bool clipBottom;
  SideClipper({
    this.clipLeft = false,
    this.clipRight = false,
    this.clipTop = false,
    this.clipBottom = false,
  });
  SideClipper.vertical()
      : clipLeft = false,
        clipRight = false,
        clipTop = true,
        clipBottom = true;
  SideClipper.horizontal()
      : clipLeft = true,
        clipRight = true,
        clipTop = false,
        clipBottom = false;

  @override
  Path getClip(Size size) {
    final path = Path();
    final right = clipRight ? size.width : 999999999.0;
    final left = clipLeft ? 0.0 : -999999999.0;
    final top = clipTop ? 0.0 : -999999999.0;
    final bottom = clipBottom ? size.height : 999999999.0;
    // path starts at (0,0)
    path.lineTo(right, top);
    path.lineTo(right, bottom);
    path.lineTo(left, bottom);
    path.lineTo(left, top);
    return path;
  }

  @override
  bool shouldReclip(SideClipper oldClipper) {
    return oldClipper.clipLeft != clipLeft
        || oldClipper.clipRight != clipRight
        || oldClipper.clipTop != clipTop
        || oldClipper.clipBottom != clipBottom;
  }

}



class ComposedIcon extends StatelessWidget {
  final Widget icon;
  final Widget subicon;
  final double subIconSize; /// percentage
  final double clipSize; /// percentage
  final double horizontalOffset; /// percentage
  final double verticalOffset; /// percentage
  const ComposedIcon({
    required this.icon,
    required this.subicon,
    this.subIconSize = 0.65,
    this.clipSize = 0.8,
    this.horizontalOffset = 0.6,
    this.verticalOffset = 0.6,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        ClipPath(
          clipper: IconBottomRightClipper(
            percentage: subIconSize * clipSize,
          ),
          child: icon,
        ),
        Positioned.fill(
          child: Center(
            child: FractionalTranslation(
              translation: Offset(
                subIconSize * horizontalOffset,
                subIconSize * verticalOffset,
              ),
              child: Transform.scale(
                scale: subIconSize,
                child: subicon,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class IconBottomRightClipper extends CustomClipper<Path> {
  final double percentage;
  IconBottomRightClipper({
    this.percentage = 0.5,
  });
  @override
  Path getClip(Size size) {
    final result = Path();
    final offset = size.width*percentage;
    final toOffset = size.width*(1-percentage);
    result.moveTo(toOffset, size.height);
    result.arcToPoint(Offset(size.width, toOffset),
      radius: Radius.circular(offset),
    );
    result.lineTo(size.width, 0);
    result.lineTo(0, 0);
    result.lineTo(0, size.height);
    result.moveTo(toOffset, size.height);
    return result;
  }
  @override
  bool shouldReclip(IconBottomRightClipper oldClipper) {
    return oldClipper.percentage!=percentage;
  }
}