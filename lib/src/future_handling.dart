import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:from_zero_ui/from_zero_ui.dart';
import 'package:from_zero_ui/src/exposed_transitions.dart';


class LoadingCard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Card(
      child: LoadingSign(),
    );
  }

}

class LoadingSign extends StatelessWidget {

  const LoadingSign();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

}

class ErrorCard extends StatelessWidget {

  String title;
  String? subtitle;
  Widget? icon;
  VoidCallback? onRetry;
  EdgeInsets padding;

  ErrorCard({
    required this.title,
    this.subtitle,
    this.onRetry,
    this.icon,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: ErrorSign(
          title: title,
          subtitle: subtitle,
          onRetry: onRetry,
          icon: icon,
        ),
      ),
    );
  }

}

class ErrorSign extends StatelessWidget {

  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;
  final Widget? icon;

  ErrorSign({required this.title, this.subtitle, this.onRetry, this.icon, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: Theme.of(context).iconTheme.copyWith(size: 64, color: Theme.of(context).disabledColor,),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon!=null)
                icon!,
              if (icon!=null)
                SizedBox(height: 6,),
              Text(
                title,
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              if (subtitle!=null)
                SizedBox(height: 12,),
              if (subtitle!=null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
              if (onRetry!=null)
                SizedBox(height: 12,),
              if (onRetry!=null)
                RaisedButton(
                  child: Text(FromZeroLocalizations.of(context).translate("retry")), //TODO 3 internationalize
                  onPressed: onRetry,
                ),
            ],
          ),
        ),
      ),
    );
  }

}

typedef SuccessBuilder<T> = Widget Function(BuildContext context, T data);
typedef ErrorBuilder = Widget Function(BuildContext context, Object? error);
typedef LoadingBuilder = Widget Function(BuildContext context);
Widget _defaultLoadingBuilder(context){
  return LoadingSign();
}

Widget _defaultErrorBuilder(context, error){
  return ErrorSign(
    icon: Icon(Icons.error_outline), //size: 64, color: Theme.of(context).errorColor,
    title: FromZeroLocalizations.of(context).translate("error"),
    subtitle: FromZeroLocalizations.of(context).translate("error_details"),
  );
}

Widget _defaultTransitionBuilder(Widget child, Animation<double> animation){
  return ZoomedFadeInFadeOutTransition(
    animation: animation,
    child: child,
  );
}

Widget _noneTransitionBuilder(Widget child, Animation<double> animation){
  return child;
}


class FutureBuilderFromZero<T> extends StatefulWidget {

  final initialData;
  final Future future;
  final SuccessBuilder<T> successBuilder;
  final Duration duration;
  final bool applyAnimatedContainerFromChildSize;
  final bool keepPreviousDataWhileLoading;
  ErrorBuilder errorBuilder;
  LoadingBuilder loadingBuilder;
  AnimatedSwitcherTransitionBuilder transitionBuilder;

  FutureBuilderFromZero({
    Key? key,
    required this.future,
    required this.successBuilder,
    this.errorBuilder: _defaultErrorBuilder,
    this.loadingBuilder: _defaultLoadingBuilder,
    this.initialData,
    AnimatedSwitcherTransitionBuilder? transitionBuilder,
    this.keepPreviousDataWhileLoading = false,
    bool applyDefaultTransition = true,
    Duration? duration,
    this.applyAnimatedContainerFromChildSize = false,
  }) :  transitionBuilder = transitionBuilder ?? (applyDefaultTransition ? _defaultTransitionBuilder : _noneTransitionBuilder),
        duration = duration ?? (applyDefaultTransition ? const Duration(milliseconds: 300) : Duration.zero),
        super(key: key);

  @override
  _FutureBuilderFromZeroState<T> createState() => _FutureBuilderFromZeroState<T>();

}

class _FutureBuilderFromZeroState<T> extends State<FutureBuilderFromZero<T>> {

  bool skipFrame = false;
  late int initialTimestamp;

  @override
  void initState() {
    super.initState();
    initialTimestamp = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  void didUpdateWidget(FutureBuilderFromZero<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.future,
      initialData: widget.initialData,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        Widget result;
        int state = 0;
        if (snapshot.connectionState == ConnectionState.done || (widget.keepPreviousDataWhileLoading&&snapshot.hasData)){
          skipFrame = true;
          if (snapshot.hasData){
            state = 1;
            result = widget.successBuilder(context, snapshot.data);
          } else {
            state = -1;
            result = widget.errorBuilder(context, snapshot.hasError ? snapshot.error : "Forever Loading");
          }
        } else{
          if (skipFrame && (snapshot.hasData || snapshot.hasError)){
            WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
              try{setState(() {
                skipFrame = false;
              });}catch(_){}
            });
            if (snapshot.hasData){
              state = 1;
              result = widget.successBuilder(context, snapshot.data);
            } else {
              state = -1;
              result = widget.errorBuilder(context, snapshot.error);
            }
          } else{
            state = 0;
            result = widget.loadingBuilder(context);
          }
        }
        int milliseconds = (DateTime.now().millisecondsSinceEpoch-initialTimestamp).clamp(0, widget.duration.inMilliseconds).toInt();
        if (widget.transitionBuilder != null){
          result = AnimatedSwitcher(
            transitionBuilder: widget.transitionBuilder,
            child: Container(
              key: ValueKey(state),
              child: result,
            ),
            duration: Duration(milliseconds: milliseconds),
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                overflow: Overflow.visible,
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: OverflowBox(
                      child: Stack(
                        children: previousChildren,
                      ),
                    ),
                  ),
                  if (currentChild!=null)
                    currentChild,
                ],
              );
            },
          );
        }
        if (widget.applyAnimatedContainerFromChildSize){
          result = AnimatedContainerFromChildSize(
            duration: widget.duration,
            child: result,
          );
        }
        return result;
      },
    );
  }

}


/// Only updates when a different child is given, like AnimatedSwitcher
class AnimatedContainerFromChildSize extends StatefulWidget {

  final Duration duration;
  final Curve curve;
  final Widget child;

  AnimatedContainerFromChildSize({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
  });

  @override
  _AnimatedContainerFromChildSizeState createState() => _AnimatedContainerFromChildSizeState();

}

class Export extends StatelessWidget {
  // !!! TODO !!! fix export web issues and move it here or a lot of stuff will break
  Widget build(context) { return Container(); }
}

class _AnimatedContainerFromChildSizeState extends State<AnimatedContainerFromChildSize> {

  GlobalKey globalKey = GlobalKey();
  late Size previouSize;
  Size? size; //TODO 3 use a provider for sizes to notify parents of changes and allow nesting
  bool skipNextCalculation = false;
  late int initialTimestamp;

  late bool export;
  @override
  void initState() {
    initialTimestamp = DateTime.now().millisecondsSinceEpoch;
    export = context.findAncestorWidgetOfExactType<Export>()!=null;
    _addCallback(null);
    super.initState();
  }
  @override
  void didUpdateWidget(AnimatedContainerFromChildSize oldWidget) {
    _addCallback(oldWidget);
    super.didUpdateWidget(oldWidget);
  }

  void _addCallback(AnimatedContainerFromChildSize? oldWidget){
    if (widget.child != oldWidget?.child){
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        try {
          RenderBox renderBox = globalKey.currentContext!.findRenderObject() as RenderBox;
          previouSize = size!;
          size = renderBox.size;
          if (size!=previouSize)
          setState(() {
            skipNextCalculation = true;
          });
        } catch (_, __) {}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (export) return widget.child;
    return LayoutBuilder(
      builder: (context, constraints) {
        _addCallback(null);
        Widget child = Container(key: globalKey, child: widget.child,);
        if (size == null){
          return AnimatedContainer(
            duration: widget.duration,
            curve: widget.curve,
            child: child,
          );
        } else{
          double height = max(size!.height, constraints.minHeight);
          double width = max(size!.width, constraints.minWidth);
          double durationMult = 1;
          if (previouSize != null){
            double previousHeight = max(previouSize.height, constraints.minHeight);
            double previousWidth = max(previouSize.width, constraints.minWidth);
//            durationMult = ((max((previousHeight-height).abs(), (previousWidth-width).abs()))/64).clamp(0.0, 1.0); TODO 3 make this work right when called multiple times in succesion by LayoutBuilder
          }
          int milliseconds = (DateTime.now().millisecondsSinceEpoch-initialTimestamp).clamp(0, widget.duration.inMilliseconds*durationMult).toInt();

          return AnimatedContainer(
            height: height,
            width: width,
            duration: Duration(milliseconds: milliseconds),
            curve: widget.curve,
            child: OverflowBox(
              maxWidth: constraints.maxWidth,
              maxHeight: constraints.maxHeight,
              minWidth: constraints.minWidth,
              minHeight: constraints.minHeight,
              alignment: Alignment.topLeft,
              child: child,
            ),
          );
        }
      },
    );
  }
}
