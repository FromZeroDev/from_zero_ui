
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:from_zero_ui/src/custom_painters.dart';
import 'package:from_zero_ui/src/fluro_router_from_zero.dart';
import 'package:from_zero_ui/src/scrollbar_from_zero.dart';
import 'file:///C:/Workspaces/Flutter/from_zero_ui/lib/util/no_fading_material_transitions.dart';
import 'package:provider/provider.dart';
import '../util/no_fading_shared_axis_transition.dart' as no_fading_shared_axis_transition;
import '../util/no_fading_fade_through_transition.dart' as no_fading_fade_through_transition;



//TODO 1 implement enhanced heroes
//Widget fadeTransitionFlightShuttleBuilder(flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
//  final Hero newHero = flightDirection == HeroFlightDirection.pop
//      ? fromHeroContext.widget : toHeroContext.widget;
//  final Hero oldHero = flightDirection == HeroFlightDirection.push
//      ? fromHeroContext.widget : toHeroContext.widget;
//  return Stack(
//    children: <Widget>[
//      oldHero.child,
//      FadeTransition( // this could be any transition ever !!!
//        opacity: animation,
//        child: newHero.child,
//      ),
//    ],
//  );
//}


typedef Widget DrawerContentBuilder(bool compact,);

class ScaffoldFromZero extends StatefulWidget {

  static const double small = 0;
  static const double medium = 612;
  static const double large = 848;
  static const double xLarge = 1280;
  static const List<double> sizes = [small, medium, large, xLarge];

  static final GlobalKey bodyGlobalKey = GlobalKey();

  final Widget title;
  final List<Widget> actions;
  final Widget body;
  final Widget floatingActionButton;
  final DrawerContentBuilder drawerContentBuilder;
  final DrawerContentBuilder drawerFooterBuilder;
  final Widget drawerTitle;
  final bool useCompactDrawerInsteadOfClose;
  final double appbarHeight;
  final bool constraintBodyOnXLargeScreens;
  final PageFromZero currentPage;


  ScaffoldFromZero({
    this.title,
    this.actions,
    this.body,
    this.floatingActionButton,
    this.drawerContentBuilder,
    this.drawerFooterBuilder,
    this.drawerTitle,
    this.useCompactDrawerInsteadOfClose = true,
    this.constraintBodyOnXLargeScreens = true,
    this.appbarHeight = 56, //TODO 3 increase appbarHeight with font size to avoid it breaking
    this.currentPage,
  });

  @override
  _ScaffoldFromZeroState createState() => _ScaffoldFromZeroState(
    drawerContentBuilder==null ? 0 : useCompactDrawerInsteadOfClose ? 56 : 0,
  );

}

class _ScaffoldFromZeroState extends State<ScaffoldFromZero> {

  static const double appbarElevation = 4;
  static const double drawerElevation = 2;
  static const double drawerWidth = 304;
  static const int drawerAnimationDuration = 300;
  static const drawerAnimationCurve = Curves.easeOutCubic;
  static const int animationTypeSame = 0;
  static const int animationTypeOther = 1;
  static const int animationTypeInner = 2;
  static const int animationTypeOuter = 3;

  double width;
  double height;
  bool displayMobileLayout;
  double compactDrawerWidth;
  ScrollController drawerContentScrollController = ScrollController();
  bool canPop;


  get animation => widget.currentPage?.animation ?? kAlwaysCompleteAnimation;
  get secondaryAnimation => widget.currentPage?.secondaryAnimation ?? kAlwaysDismissedAnimation;



  _ScaffoldFromZeroState(this.compactDrawerWidth);

  @override
  void initState() {
    super.initState();
    FluroRouterFromZero.previousPage = widget.currentPage;
    changeNotifier = Provider.of<ScaffoldFromZeroChangeNotifier>(context, listen: false);
    _updateAnimationType(widget.currentPage, widget.currentPage?.previousPage);
  }

  @override
  void dispose() {
    super.dispose();
    if (FluroRouterFromZero.previousPage == widget.currentPage){
      FluroRouterFromZero.previousPage = widget.currentPage.previousPage;
      _updateAnimationType(widget.currentPage?.previousPage, widget.currentPage?.previousPage?.previousPage);
    }
  }

  ScaffoldFromZeroChangeNotifier changeNotifier;
  void _updateAnimationType(PageFromZero currentPage, PageFromZero previousPage){
    int animationType = animationTypeOther;
    if (currentPage!=null && previousPage!=null) {
      if (currentPage.pageScaffoldId == previousPage.pageScaffoldId) {
        if (currentPage.pageScaffoldDepth > previousPage.pageScaffoldDepth) {
          animationType = animationTypeInner;
        } else if (currentPage.pageScaffoldDepth < previousPage.pageScaffoldDepth) {
          animationType = animationTypeOuter;
        } else {
          animationType = animationTypeSame;
        }
      }
    }
    changeNotifier.animationTypeSILENT = animationType;
  }

  @override
  Widget build(BuildContext context) {

    if (canPop==null) canPop = Navigator.of(context).canPop();
    return Consumer<ScaffoldFromZeroChangeNotifier>(
      builder: (context, changeNotifier, child) {
        return LayoutBuilder(
            builder: (context, constraints) {
              width = constraints.maxWidth;
              height = constraints.maxHeight;
              displayMobileLayout = width < ScaffoldFromZero.medium;
              if (displayMobileLayout || widget.drawerContentBuilder==null)
                changeNotifier.currentDrawerWidthSILENT = 0;
              else if (widget.drawerContentBuilder!=null && changeNotifier.currentDrawerWidth < compactDrawerWidth)
                changeNotifier.currentDrawerWidthSILENT = compactDrawerWidth;

              double fabPadding = (width-changeNotifier.currentDrawerWidth-ScaffoldFromZero.xLarge)/2 ;
              if (fabPadding < 12) fabPadding = width < ScaffoldFromZero.medium ? 0 : 12;
              return FadeUpwardsSlideTransition(
                routeAnimation: changeNotifier.animationType==animationTypeOther ? animation : kAlwaysCompleteAnimation,
                child: FadeUpwardsFadeTransition(
                  routeAnimation: animation,
                  child: Scaffold(
                    floatingActionButton: Padding(
                      padding: EdgeInsets.only(bottom: width < ScaffoldFromZero.medium ? 0 : 12, right: fabPadding), //TODO TEST make fab always be on the edge of the usable surface,
                      child: widget.floatingActionButton,
                    ),
                    drawer: displayMobileLayout && widget.drawerContentBuilder!=null ? Drawer(
                      child: _getResponsiveDrawerContent(context, changeNotifier),
                      elevation: drawerElevation,
                    ) : null,
                    body: Builder(
                      builder: (context) {
                        return _getBody(context, changeNotifier);
                      },
                    ),
                  ),
                ),
              );
            }
        );
      },
    );
  }

  Widget _getBody(context, ScaffoldFromZeroChangeNotifier changeNotifier) {
    return Stack(
      children: [

        //BACKGROUND STRIPE TO PREVENT APPBAR TEARING WHEN CLOSE/OPEN DRAWER
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: widget.appbarHeight,
            color: Theme.of(context).primaryColor,
          ),
        ),


        //DESKTOP DRAWER
        displayMobileLayout || widget.drawerContentBuilder==null
            ? SizedBox.shrink()
            : widget.useCompactDrawerInsteadOfClose
            ? Positioned(
          left: 0,
          child: AnimatedContainer(
            duration: Duration(milliseconds: drawerAnimationDuration),
            curve: drawerAnimationCurve,
            width: changeNotifier.currentDrawerWidth,
            height: height,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) => onHorizontalDragUpdate(details, changeNotifier),
              onHorizontalDragEnd: (details) => onHorizontalDragEnd(details, changeNotifier),
              child: _getResponsiveDrawerContent(context, changeNotifier),
            ),
          ),
        )
            : AnimatedPositioned(
          duration: Duration(milliseconds: drawerAnimationDuration),
          curve: drawerAnimationCurve,
          left: changeNotifier.currentDrawerWidth-drawerWidth,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) => onHorizontalDragUpdate(details, changeNotifier),
            onHorizontalDragEnd: (details) => onHorizontalDragEnd(details, changeNotifier),
            child: Container(
              width: drawerWidth,
              height: height,
              child: _getResponsiveDrawerContent(context, changeNotifier),
            ),
          ),
        ),

        //APPBAR + BODY
        AnimatedPositioned(
          duration: Duration(milliseconds: drawerAnimationDuration),
          curve: drawerAnimationCurve,
          left: changeNotifier.currentDrawerWidth,
          child: AnimatedContainer(
            duration: Duration(milliseconds: drawerAnimationDuration),
            curve: drawerAnimationCurve,
            width: width-changeNotifier.currentDrawerWidth,
            height: height,
            child: Stack(
              children: <Widget>[

                //APPBAR
                SizedBox(
                  height: widget.appbarHeight,
                  child: AppBar(
                    elevation: 0,
                    automaticallyImplyLeading: widget.drawerContentBuilder==null,
                    actions: widget.actions, // TODO 2 do something about overflowing actions
                    titleSpacing: (!displayMobileLayout&&widget.useCompactDrawerInsteadOfClose)||widget.drawerContentBuilder==null ? 16 : 8,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[

                        //DRAWER HAMBURGER BUTTON (only if not using compact style)
                        (!displayMobileLayout&&widget.useCompactDrawerInsteadOfClose)||widget.drawerContentBuilder==null ? SizedBox.shrink()
                            : AnimatedOpacity(
                          opacity: 1-changeNotifier.currentDrawerWidth/56<0 ? 0 : 1-changeNotifier.currentDrawerWidth/56,
                          duration: Duration(milliseconds: drawerAnimationDuration),
                          curve: drawerAnimationCurve,
                          child: AnimatedContainer(
                            width: changeNotifier.currentDrawerWidth>56 ? 0: 56-changeNotifier.currentDrawerWidth,
                            duration: Duration(milliseconds: drawerAnimationDuration),
                            curve: Curves.easeOutCubic,
                            padding: EdgeInsets.only(right: 8),
                            alignment: Alignment.centerLeft,
                            child: Builder(
                                builder: (context) {
                                  return IconButton(
                                    icon: Icon(Icons.menu),
                                    tooltip: "Abrir Menú",
                                    onPressed: () => _toggleDrawer(context, changeNotifier),
                                    hoverColor: Colors.white.withOpacity(0.1), //TODO 2 make this actually responsive that actually gets params from parent dark theme (just use AppBar)
                                  );
                                }
                            ),
                          ),
                        ),

                        //TITLE
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizeTransition(
                              sizeFactor: changeNotifier.animationType==animationTypeOther ? kAlwaysCompleteAnimation : animation,
                              axis: Axis.horizontal,
                              child: widget.title,
                            ),
                          ),
                        ),

                      ],
                    ),
                  )
                ),

                //BODY
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.only(top: widget.appbarHeight,),
                    width: widget.constraintBodyOnXLargeScreens ? ScaffoldFromZero.xLarge : double.infinity,
                    child: AnimatedBuilder(
                      animation: secondaryAnimation,
                      builder: (context, child) {
                        bool fadeAnim = changeNotifier.animationType==animationTypeSame;
                        bool sharedAnim = changeNotifier.animationType==animationTypeInner || changeNotifier.animationType==animationTypeOuter;
                        //TODO 3 implement animationType outer reverse
                        return no_fading_shared_axis_transition.SharedAxisTransition(
                          animation: sharedAnim ? animation : kAlwaysCompleteAnimation,
                          secondaryAnimation: sharedAnim ? secondaryAnimation : kAlwaysDismissedAnimation,
                          child: no_fading_fade_through_transition.FadeThroughTransition(
                            animation: fadeAnim ? animation : kAlwaysCompleteAnimation,
                            secondaryAnimation: fadeAnim ? secondaryAnimation : kAlwaysDismissedAnimation,
                            child: child,
                            fillColor: Colors.transparent,
                          ),
                          transitionType: no_fading_shared_axis_transition.SharedAxisTransitionType.scaled,
                          fillColor: Colors.transparent,
                        );
                      },
                      child: widget.body,
                    ),
                  ),
                ),

                //DESKTOP DRAWER OPEN GESTURE DETECTOR
                displayMobileLayout||widget.drawerContentBuilder==null ? const SizedBox.shrink()
                    : GestureDetector(
                  onHorizontalDragUpdate: (details) => onHorizontalDragUpdate(details, changeNotifier),
                  onHorizontalDragEnd: (details) => onHorizontalDragEnd(details, changeNotifier),
                  behavior: HitTestBehavior.translucent,
                  excludeFromSemantics: true,
                  child: Container(width: 18,),
                ),

              ],
            ),
          ),
        ),

        // custom shadows
        if (!displayMobileLayout)
        AnimatedContainer(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(top: widget.appbarHeight, left: changeNotifier.currentDrawerWidth),
          duration: Duration(milliseconds: drawerAnimationDuration),
          curve: drawerAnimationCurve,
          child: SizedBox(
            width: drawerElevation,
            height: double.infinity,
            child: CustomPaint(
              painter: SimpleShadowPainter(direction: SimpleShadowPainter.right, shadowOpacity: 0.3),
            ),
          ),
        ),
        Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: widget.appbarHeight),
          child: SizedBox(
            width: double.infinity,
            height: appbarElevation,
            child: CustomPaint(
              painter: SimpleShadowPainter(direction: SimpleShadowPainter.down, shadowOpacity: 0.4),
            ),
          ),
        ),

      ],
    );
  }

  _getResponsiveDrawerContent(context, ScaffoldFromZeroChangeNotifier changeNotifier){
    return Column(
      children: <Widget>[

        //TODO 2 add a way to paint an unscrollable header that can stack over the drawer appbar (or not)
        //DRAWER APPBAR
        SizedBox(
          height: widget.appbarHeight,
          child: OverflowBox(
            minWidth: 0,
            maxWidth: drawerWidth,
            minHeight: widget.appbarHeight,
            maxHeight: widget.appbarHeight,
            alignment: Alignment.centerRight,
            child: Material(
              color: Theme.of(context).primaryColor,
              child: Theme(
                data: Theme.of(context).copyWith(
                  hoverColor: Colors.white.withOpacity(0.1), //TODO 2 make this actually responsive that actually gets params from parent dark theme
                  iconTheme: Theme.of(context).iconTheme.copyWith(
                    color: Colors.white,
                  ),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: kIsWeb ? 4 : 8), // TODO WTFF dps are bigger in web ???
                      child: IconButton(
                        icon: Icon(widget.useCompactDrawerInsteadOfClose&&!displayMobileLayout ? Icons.menu : Icons.close),
                        tooltip: changeNotifier.currentDrawerWidth>compactDrawerWidth||displayMobileLayout ? "Cerrar Menú" : "Abrir Menú",
                        onPressed: (){
                          if (displayMobileLayout)
                            Navigator.of(context).pop();
                          else
                            _toggleDrawer(context, changeNotifier);
                        },
                      ),
                    ),
                    Expanded(child: Container()),
                    if (widget.drawerTitle!=null)
                      Hero(tag: "responsive_drawer_title", child: widget.drawerTitle),
                    SizedBox(width: 8,),
                    if (canPop)
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        tooltip: "Página Anterior", //TODO 3 internationalize
                        onPressed: () async{
                          var navigator = Navigator.of(context);
                          if (displayMobileLayout)
                            navigator.pop(); //TODO 2 implement a way to prevent route pop
//                        Confirmation prevent = Provider.of<AppbarStatus>(context, listen: false).preventNavigationCallback;
//                        if (prevent==null || await prevent()){
                          if (navigator.canPop())
                            navigator.pop();
//                        }
                        },
                      ),
                    SizedBox(width: 8,),
                  ],
                ),
              ),
            ),
          ),
        ),


        //DRAWER CONTENT
        Expanded(
          child: Container(
            decoration: BoxDecoration(),
            clipBehavior: Clip.hardEdge,
            child: OverflowBox(
              minWidth: drawerWidth,
              maxWidth: drawerWidth,
              minHeight: height-widget.appbarHeight,
              maxHeight: height-widget.appbarHeight,
              alignment: Alignment.bottomLeft,
              child: Material(
                color: Theme.of(context).cardColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FadeUpwardsSlideTransition(
                        routeAnimation: changeNotifier.animationType==animationTypeInner || changeNotifier.animationType==animationTypeOuter
                            ? animation : kAlwaysCompleteAnimation,
                        child: ScrollbarFromZero(
                          controller: drawerContentScrollController,
                          child: SingleChildScrollView(
                            controller: drawerContentScrollController,
                            child: widget.drawerContentBuilder(changeNotifier.currentDrawerWidth==compactDrawerWidth),
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Theme.of(context).cardColor,
                      child: Column(
                        children: <Widget>[
                          Divider(height: 1,),
                          SizedBox(height: 6,),
                          widget.drawerFooterBuilder != null ? widget.drawerFooterBuilder(changeNotifier.currentDrawerWidth==compactDrawerWidth) : SizedBox.shrink(),
                          SizedBox(height: 12,),
                        ],
                      ),
                    ),
                  ],
                )
              ),
            ),
          ),
        ),

      ],
    );
  }

  _toggleDrawer(context, ScaffoldFromZeroChangeNotifier changeNotifier){
    var scaffold = Scaffold.of(context);
    if (scaffold.hasDrawer){
      if (scaffold.isDrawerOpen){
        // not clickable
      } else{
        scaffold.openDrawer();
      }
    } else{
      if (changeNotifier.currentDrawerWidth > compactDrawerWidth){
        changeNotifier.currentDrawerWidth = compactDrawerWidth;
      } else{
        changeNotifier.currentDrawerWidth = drawerWidth;
      }
    }
  }

  void onHorizontalDragUpdate (DragUpdateDetails details, ScaffoldFromZeroChangeNotifier changeNotifier) {
    double jump = changeNotifier.currentDrawerWidth + details.delta.dx;
    if (jump<compactDrawerWidth) jump = compactDrawerWidth;
    if (jump>drawerWidth) jump = drawerWidth;
    changeNotifier.currentDrawerWidth = jump;
  }
  static const double _kMinFlingVelocity = 365.0;
  void onHorizontalDragEnd (DragEndDetails details, ScaffoldFromZeroChangeNotifier changeNotifier) {
    double jump = changeNotifier.currentDrawerWidth;
    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity){
      if (details.velocity.pixelsPerSecond.dx>0) jump = drawerWidth;
      else jump = compactDrawerWidth;
    }
    else if (jump<drawerWidth/2) jump = compactDrawerWidth;
    else jump = drawerWidth;
    changeNotifier.currentDrawerWidth = jump;
  }

}

class ScaffoldFromZeroChangeNotifier extends ChangeNotifier{

  double _currentDrawerWidth = 304;

  double get currentDrawerWidth => _currentDrawerWidth;
  set currentDrawerWidth(double value) {
    _currentDrawerWidth = value;
    notifyListeners();
  }
  set currentDrawerWidthSILENT(double value) {
    _currentDrawerWidth = value;
  }

  int _animationType;
  int get animationType => _animationType;
  set animationType(int value) {
    _animationType = value;
    notifyListeners();
  }
  set animationTypeSILENT(int value) {
    _animationType = value;
  }


}

class PreviousScaffoldChangeNotifier extends ChangeNotifier{



}


