import 'package:flutter/material.dart';
import 'package:flutter_tutorial/data/notifiers.dart';
import 'package:flutter_tutorial/views/pages/home_page.dart';
import 'package:flutter_tutorial/views/pages/profile_page.dart';
import 'widget/navbar_widget.dart';

List<Widget> pages = [
  HomePage(),
  ProfilePage(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(children: [Icon(Icons.person), Text("Flutter App")]),
        ),
        body: ValueListenableBuilder(
          valueListenable: selectedPageNotifier, 
          builder: (context, selectedPage, child) {
            return pages.elementAt(selectedPage);
          },),
        bottomNavigationBar: NavbarWidget(),
      );
  }
}