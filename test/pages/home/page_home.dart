import 'package:flutter/material.dart';
import 'package:from_zero_ui/from_zero_ui.dart';
import 'package:from_zero_ui/src/fluro_router_from_zero.dart';

class PageHome extends PageFromZero {

  static List<List<ResponsiveDrawerMenuItem>> tabs = [
    [
      ResponsiveDrawerMenuItem(
        title: "Home",
        icon: Icons.home,
        route: "/",
      ),
      ResponsiveDrawerMenuItem(
        title: "Scaffold FromZero",
        icon: Icons.subtitles,
        route: "/scaffold",
      ),
      ResponsiveDrawerMenuItem(
        title: "Lightweight Table",
        icon: Icons.table_chart,
        route: "/lightweight_table",
      ),
      ResponsiveDrawerMenuItem(
        title: "Future Handling",
        icon: Icons.refresh,
        route: "/future_handling",
      ),
      ResponsiveDrawerMenuItem(
        title: "Heroes",
        icon: Icons.person_pin_circle,
        route: "/heroes",
      ),
    ],
  ];

  static List<List<ResponsiveDrawerMenuItem>> footerTabs = [
    [
      ResponsiveDrawerMenuItem(
        title: "Settings",
        icon: Icons.settings,
        route: "/settings",
      )
    ]
  ];

  @override
  int get pageScaffoldDepth => 1;
  @override
  String get pageScaffoldId => "Home";

  PageHome(PageFromZero previousPage, Animation<double> animation, Animation<double> secondaryAnimation)
      : super(previousPage, animation, secondaryAnimation);

  @override
  _PageHomeState createState() => _PageHomeState();

}

class _PageHomeState extends State<PageHome> {

  @override
  Widget build(BuildContext context) {
    return ScaffoldFromZero(
      currentPage: widget,
      title: Text("FromZero playground"),
      body: Container(),
      drawerContentBuilder: (compact) => DrawerMenuFromZero(tabs: PageHome.tabs, compact: compact, selected: [0, 0],),
      drawerFooterBuilder: (compact) => DrawerMenuFromZero(tabs: PageHome.footerTabs, compact: compact, selected: [-1, -1], replaceInsteadOfPuhsing: DrawerMenuFromZero.neverReplaceInsteadOfPuhsing,),
    );
  }

}
