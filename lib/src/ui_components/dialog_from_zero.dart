import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:animations/animations.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:from_zero_ui/from_zero_ui.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';


Future<T?> showModalFromZero<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  ModalConfiguration? configuration,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  ui.ImageFilter? filter,
  bool? showWindowBarOnDesktop,
}) {
  return showModal<T?>(
    context: context,
    builder: builder,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    filter: filter,
    configuration: configuration ?? FromZeroModalConfiguration(
      showWindowBarOnDesktop: showWindowBarOnDesktop ?? useRootNavigator,
    ),
  );
}
class FromZeroModalConfiguration extends FadeScaleTransitionConfiguration {
  final bool showWindowBarOnDesktop;
  final Color _myBarrierColor; /// hack to handle coloring barrier myself
  const FromZeroModalConfiguration({
    Color barrierColor = Colors.black54,
    super.barrierDismissible = true,
    super.transitionDuration = const Duration(milliseconds: 150),
    super.reverseTransitionDuration = const Duration(milliseconds: 75),
    super.barrierLabel = 'Dismiss',
    this.showWindowBarOnDesktop = true,
  })  : _myBarrierColor = barrierColor,
        super(barrierColor: Colors.transparent);
  @override
  Widget transitionBuilder(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    Widget result = Stack(
      alignment: Alignment.bottomCenter, // Alignment.center
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: ColoredBox(
            color: _myBarrierColor,
            child: const SizedBox.expand(),
          ),
        ),
        ScaleTransition(
          scale: TweenSequence<double>([
            TweenSequenceItem(
              tween: Tween(begin: 0.8, end: 1.02).chain(CurveTween(curve: Curves.easeOutQuad)),
              weight: 0.8,
            ),
            TweenSequenceItem(
              tween: Tween(begin: 1.02, end: 1.0).chain(CurveTween(curve: Curves.easeInOutQuad)),
              weight: 0.2,
            ),
          ]).animate(animation),
          child: FixedSlideTransition( // flutter's default SlideTransition causes an assertion when scrolling in a ListView.builder inside it
            position: Tween<Offset>(
              begin: const Offset(0.0, 128),
              end: Offset.zero,
            ).animate(animation), // flutter's default SlideTransition causes an assertion when scrolling in a ListView.builder inside it
            child: child,
          ),
        ),
      ],
    );
    if (showWindowBarOnDesktop && !kIsWeb && Platform.isWindows
        && windowsDesktopBitsdojoWorking) {
      bool didSetIsMouseOverWindowBar = false;
      result = Column(
        children: [
          Builder(
            builder: (context) {
              MediaQuery.sizeOf(context); // listen to windows size changes
              if (appWindow.isMaximized) {
                if (isMouseOverWindowBar.value && didSetIsMouseOverWindowBar) {
                  // weird hack, but otherwise it's stuck on true
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    isMouseOverWindowBar.value = false;
                  });
                }
                return const SizedBox.shrink();
              } else {
                return MouseRegion(
                  opaque: false,
                  onEnter: (event) {
                    didSetIsMouseOverWindowBar = true;
                    isMouseOverWindowBar.value = true;
                  },
                  onExit: (event) {
                    isMouseOverWindowBar.value = false;
                  },
                  child: WindowBar(backgroundColor: Theme.of(context).cardColor),
                );
              }
            },
          ),
          Expanded(
            child: result,
          ),
        ],
      );
    }
    result = FadeUpwardsFadeTransition(
      routeAnimation: animation,
      child: result,
    );
    return result;
  }
}



class DialogFromZero extends StatefulWidget {

  final Widget? title;
  final Widget? content;
  final List<Widget> dialogActions;
  final List<Widget>? appBarActions;
  /// if this is passed, we assume scrolling is handled outside
  /// if null, a SingleChildScrollView is built around the content
  final ScrollController? scrollController;
  final bool useReponsiveInsets;
  /// set to false is useful to include AnimatedSwitcher below Dialog
  final bool includeDialogWidget;
  final EdgeInsets contentPadding;
  final double? maxWidth;
  final WrapAlignment dialogActionsWrapAlignment;
  final WrapAlignment dialogActionsWrapRunAlignment;
  final WrapCrossAlignment dialogActionsWrapCrossAxisAlignment;
  /// only use if need to replace the whole AppBat, prefer using title and appBarActions
  final Widget? appBar;
  /// forwarded to Dialog widget
  final Color? backgroundColor;
  /// forwarded to Dialog widget
  final double? elevation;
  /// forwarded to Dialog widget
  final Color? shadowColor;
  /// forwarded to Dialog widget
  final Color? surfaceTintColor;
  /// forwarded to Dialog widget
  final Clip clipBehavior;
  /// forwarded to Dialog widget
  final ShapeBorder? shape;
  /// forwarded to Dialog widget
  final AlignmentGeometry? alignment;
  /// for ctrl+enter shortcut, if not specified, it will be inferred as the last DialogButton found in dialogActions
  final VoidCallback? acceptCallback;

  const DialogFromZero({
    this.title,
    this.content,
    this.dialogActions = const [],
    this.appBarActions,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.scrollController,
    this.useReponsiveInsets = true,
    this.includeDialogWidget = true,
    this.maxWidth,
    this.dialogActionsWrapAlignment = WrapAlignment.end,
    this.dialogActionsWrapRunAlignment = WrapAlignment.end,
    this.dialogActionsWrapCrossAxisAlignment = WrapCrossAlignment.end,
    this.appBar,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.clipBehavior = Clip.none,
    this.shape,
    this.alignment = goldenRatioVerticalAlignment,
    this.acceptCallback,
    super.key,
  }) :  assert(appBar==null || (title==null && appBarActions==null),
          'Setting appBar overrides title and appBarActions, no need to specify both',
        ),
        assert(appBarActions==null || title!=null,
          'If setting appBarActions, a title must also be specified',
        );

  @override
  State<DialogFromZero> createState() => _DialogFromZeroState();

}

class _DialogFromZeroState extends State<DialogFromZero> {

  late final appBarSizeNotifier = ValueNotifier<Size>(Size(0, widget.appBar==null ? 0 : 56));
  late final appBarTitleSizeNotifier = ValueNotifier<Size>(Size.zero);
  late final actionsSizeNotifier = ValueNotifier<Size>(Size(0, widget.dialogActions.isEmpty ? 0 : 61));
  late final individualActionsSizeNotifiers = <ValueNotifier<Size>>[];
  late final appBarGlobalKey = GlobalKey<AppbarFromZeroState>();

  @override
  void initState() {
    super.initState();
    assert(widget.title!=null || widget.content!=null || widget.dialogActions.isNotEmpty,
      'Dialog can\'t be completely empty...',
    );
    updateIndividualActionsSizeNotifier();
  }

  @override
  void didUpdateWidget(covariant DialogFromZero oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateIndividualActionsSizeNotifier();
  }

  void updateIndividualActionsSizeNotifier() {
    if (widget.dialogActions.length < individualActionsSizeNotifiers.length) {
      individualActionsSizeNotifiers.removeRange(widget.dialogActions.length, individualActionsSizeNotifiers.length);
    } else if (widget.dialogActions.length > individualActionsSizeNotifiers.length) {
      final diff = widget.dialogActions.length - individualActionsSizeNotifiers.length;
      individualActionsSizeNotifiers.addAll(List.generate(diff, (i) => ValueNotifier(Size.zero)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = widget.scrollController ?? ScrollController();
    Widget content = Padding(
      padding: widget.contentPadding,
      child: widget.content,
    );
    if (widget.scrollController==null) {
      content = SingleChildScrollView(
        controller: scrollController,
        child: content,
      );
    }
    Widget? appBar;
    if (widget.appBar!=null) {
      appBar = Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 68,
          ),
        ),
        child: widget.appBar!,
      );
    } else if (widget.title!=null) {
      appBar = AppbarFromZero(
        key: appBarGlobalKey,
        useFlutterAppbar: false,
        title: DefaultTextStyle(
          style: Theme.of(context).textTheme.titleLarge!,
          child: Container(
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 12),
            alignment: Alignment.centerLeft,
            child: ValueListenableBuilder<Size>(
              valueListenable: appBarTitleSizeNotifier,
              builder: (context, value, child) {
                if (value.width==0) { // Hack to messure full size of Text in the first frame
                  return OverflowScroll(child: child!);
                } else {
                  return child!;
                }
              },
              child: FillerRelayer(
                notifier: appBarTitleSizeNotifier,
                child: widget.title!,
              ),
            ),
            // child: OverflowScroll( // prefer letting the title appbar take more height, but height could be easily bound with an OverflowScroll
            //   child: FillerRelayer(
            //     notifier: appBarTitleSizeNotifier,
            //     child: widget.title!,
            //   ),
            // ),
          ),
        ),
        actions: widget.appBarActions,
      );
    }
    var dialogActions = List<Widget>.from(widget.dialogActions);
    VoidCallback? acceptCallback = widget.acceptCallback;
    for (int i=dialogActions.lastIndex; i>=0; i--) {
      final e = dialogActions[i];
      if (e is DialogButton && e.onPressed!=null) {
        acceptCallback ??= e.onPressed;
        dialogActions[i] = DefaultDialogAction(
          callback: e.onPressed,
          child: e,
        );
        break;
      }
    }
    dialogActions = dialogActions.mapIndexed((i, e) {
      return FillerRelayer(
        notifier: individualActionsSizeNotifiers[i],
        child: e,
      );
    }).toList();
    Widget result = Stack(
      children: [
        MultiValueListenableBuilder(
          valueListenables: [
            appBarSizeNotifier,
            actionsSizeNotifier,
            appBarTitleSizeNotifier,
            ...individualActionsSizeNotifiers,
          ],
          builder: (context, values, child) {
            final appBarSize = values[0] as Size;
            final actionsSize = values[1] as Size;
            final appBarTitleSize = values[2] as Size;
            final individualActionsSizeNotifiers = values.sublist(3).cast<Size>();
            final minSizeFromAppbar = appBarTitleSize.width + 48
                + ((appBarGlobalKey.currentState?.actions.length??0)*40);
            final minSizeFromDialogActions = individualActionsSizeNotifiers
                .sumBy((e) => e.width) + 48;
            final minSize = max(minSizeFromAppbar, minSizeFromDialogActions);
            return Container(
              constraints: BoxConstraints(
                minWidth: min(minSize, (widget.maxWidth??double.infinity)),
                maxWidth: widget.maxWidth ?? double.infinity,
              ),
              padding: EdgeInsets.only(
                top: appBarSize.height,
                bottom: actionsSize.height,
              ),
              child: child,
            );
          },
          child: ScrollbarFromZero(
            controller: scrollController,
            child: content,
          ),
        ),
        if (dialogActions.isNotEmpty)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: FillerRelayer(
              notifier: actionsSizeNotifier,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                child: Wrap(
                  alignment: widget.dialogActionsWrapAlignment,
                  runAlignment: widget.dialogActionsWrapRunAlignment,
                  crossAxisAlignment: widget.dialogActionsWrapCrossAxisAlignment,
                  children: dialogActions,
                ),
              ),
            ),
          ),
        if (appBar!=null)
          Positioned(
            top: 0, left: 0, right: 0,
            child: FillerRelayer(
              notifier: appBarSizeNotifier,
              child: appBar,
            ),
          ),
      ],
    );
    if (widget.includeDialogWidget) {
      if (widget.useReponsiveInsets) {
        result = ResponsiveInsetsDialog(
          elevation: widget.elevation,
          shadowColor: widget.shadowColor,
          surfaceTintColor: widget.surfaceTintColor,
          clipBehavior: widget.clipBehavior,
          shape: widget.shape,
          alignment: widget.alignment,
          child: result,
        );
      } else {
        result = Dialog(
          elevation: widget.elevation,
          shadowColor: widget.shadowColor,
          surfaceTintColor: widget.surfaceTintColor,
          clipBehavior: widget.clipBehavior,
          shape: widget.shape,
          alignment: widget.alignment,
          child: result,
        );
      }
    }
    result = MediaQuery.removeViewPadding(
      context: context,
      child: result,
    );
    if (acceptCallback!=null) {
      result = CallbackShortcuts(
        bindings: {
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.enter): () {
            acceptCallback?.call();
          },
        },
        child: result,
      );
    }
    return result;
  }

}


class DefaultDialogAction extends StatefulWidget {

  final Widget child;
  final VoidCallback? callback;

  const DefaultDialogAction({
    required this.child,
    this.callback,
    super.key,
  });

  @override
  State<DefaultDialogAction> createState() => _DefaultDialogActionState();
}
class _DefaultDialogActionState extends State<DefaultDialogAction> {
  final focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      focusNode.requestFocus();
      focusNode.previousFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: widget.child,
    );
  }
}




enum DialogButtonType {
  cancel,
  accept,
  other,
}
class DialogButton extends StatelessWidget {

  final DialogButtonType _dialogButtonType;
  final Widget? child;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Color? color;
  final EdgeInsets? padding;
  final FocusNode? focusNode;
  final ButtonStyle? style; /// this overrides color and padding
  final String? tooltip;

  const DialogButton({
    required Widget child, // required non-null child
    required this.onPressed,
    this.leading,
    this.color,
    this.padding,
    this.focusNode,
    this.style,
    this.tooltip,
    super.key,
  })  : child = child, // ignore: prefer_initializing_formals
        _dialogButtonType = DialogButtonType.other;

  const DialogButton.cancel({
    this.child,
    this.onPressed,
    this.leading,
    this.color,
    this.padding,
    this.focusNode,
    this.style,
    this.tooltip,
    super.key,
})  : _dialogButtonType = DialogButtonType.cancel;

  const DialogButton.accept({
    required this.onPressed,
    this.child,
    this.leading,
    this.color,
    this.padding,
    this.focusNode,
    this.style,
    this.tooltip,
    super.key,
  })  : _dialogButtonType = DialogButtonType.accept;

  @override
  Widget build(BuildContext context) {
    Widget child = this.child ?? _defaultChild(context);
    if (leading!=null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading!,
          const SizedBox(width: 6,),
          child,
        ],
      );
    }
    final onPressed = this.onPressed ?? _defaultOnPressed(context);
    Color? color = onPressed==null
        ? Theme.of(context).disabledColor
        : (this.color ?? _defaultColor(context));
    Widget result = TextButton(
      onPressed: onPressed,
      focusNode: focusNode,
      style: style ?? TextButton.styleFrom(
        foregroundColor: color,
        padding: padding,
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: child,
        ),
      ),
    );
    if (tooltip!=null) {
      result = TooltipFromZero(
        message: tooltip,
        child: result,
      );
    }
    return result;
  }

  Widget _defaultChild(BuildContext context) {
    switch(_dialogButtonType) {
      case DialogButtonType.cancel:
        return Text(FromZeroLocalizations.of(context).translate("cancel_caps"));
      case DialogButtonType.accept:
        return Text(FromZeroLocalizations.of(context).translate("accept_caps"));
      case DialogButtonType.other:
        return const Text('???');
    }
  }

  Color? _defaultColor(BuildContext context) {
    switch(_dialogButtonType) {
      case DialogButtonType.cancel:
        return (Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.8));
      case DialogButtonType.accept:
        return Colors.blue;
      case DialogButtonType.other:
        return null;
    }
  }

  VoidCallback? _defaultOnPressed(BuildContext context) {
    switch(_dialogButtonType) {
      case DialogButtonType.cancel:
        return () {
          Navigator.of(context).pop(null); // Dismiss alert dialog
        };
      case DialogButtonType.accept:
        return null;
      case DialogButtonType.other:
        return null;
    }
  }

}





class RelayedFiller extends StatelessWidget {
  final ValueNotifier<Size?> notifier;
  final Widget? child;
  final bool applyWidth;
  final bool applyHeight;
  final Duration? duration; /// if null, no animation is apllied
  final Curve curve;
  final bool animateFromZero;
  const RelayedFiller({
    required this.notifier,
    this.applyWidth = true,
    this.applyHeight = true,
    this.duration,
    this.curve = Curves.easeOutCubic,
    this.animateFromZero = false,
    this.child,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Size?>(
      valueListenable: notifier,
      child: child,
      builder: (context, value, child) {
        if (duration==null || value==Size.zero) {
          return SizedBox(
            width: applyWidth ? value?.width : null,
            height: applyHeight ? value?.height : null,
            child: child,
          );
        } else {
          return AnimatedContainer(
            duration: duration!,
            curve: curve,
            width: applyWidth ? value?.width : null,
            height: applyHeight ? value?.height : null,
            child: child,
          );
        }
      },
    );
  }
}

class FillerRelayer extends StatefulWidget {
  final ValueNotifier<Size?> notifier;
  final Widget child;
  const FillerRelayer({
    required this.notifier,
    required this.child,
    super.key,
  });
  @override
  State<FillerRelayer> createState() => _FillerRelayerState();
}
class _FillerRelayerState extends State<FillerRelayer> {
  int _currentCallbackId = 0;
  void _addCallback(BuildContext context) {
    final callbackId = ++_currentCallbackId;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (callbackId!=_currentCallbackId) return;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (callbackId!=_currentCallbackId) return;
        try {
          widget.notifier.value = context.size;
        } catch (_) {}
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (notification) {
        if (notification is ScrollMetricsNotification
            || notification is SizeChangedLayoutNotification) {
          _addCallback(context);
        }
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: LayoutBuilder(
          builder: (context, constraints) {
            _addCallback(context);
            return widget.child;
          },
        ),
      ),
    );
  }
}



class DialogTitle extends StatelessWidget {

  final Widget child;
  final EdgeInsets padding;

  const DialogTitle({
    required this.child,
    this.padding = const EdgeInsets.all(8.0),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: DefaultTextStyle(
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        child: child,
      ),
    );
  }

}
