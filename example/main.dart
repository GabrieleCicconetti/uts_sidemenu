import 'package:flutter/material.dart';
import 'package:uts_sidemenu/uts_sidemenu.dart';


class ExampleApp extends StatelessWidget {
  AppBar _getAppBar() {
    return AppBar(
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            // Toggle the menu state open/close
            MenuNotifier.notify.toggle();

            // or user directly open/close methods
            // MenuNotifier.notify.open();

            // or
            // MenuNotifier.notify.close();
          },
          child: Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
      ],
      title: Text("Title"),
    );
  }

  Widget _getMainBody() {
    return Scaffold(
      appBar: _getAppBar(),
      body: Container(),
    );
  }

  Widget _getMenuBody() {
    return Container(
      child: Text("This is my menu body"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UTSSideMenu(
        body: _getMainBody(),
        menuBody: _getMenuBody(),
        appBar: _getAppBar(),
        duration: 600,
        menuSize: 0.7,
        isPanDisabled: false,
        isBackdropDisabled: false,
        shadow: BoxShadow(
            color: Colors.black45,
            offset: Offset(3.0, 0.0),
            spreadRadius: 10.0,
            blurRadius: 3.0),
        menuFriction: 0.3,
        direction: UTSDirection.horizontal,
        mode: UTSMode.right,
        curve: Curves.easeInOut,
        onOpen: () {
          //your code
        },
        onClose: () {
          // your code
        },
        onSlide: (dx) {
          // your code
        },
      ),
    );
  }
}
