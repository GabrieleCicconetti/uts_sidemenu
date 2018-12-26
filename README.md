# uts_sidemenu

A sidemenu for Flutter that goes under the Scaffold.

## Getting Started

This is basically a drawer but goes under the Scaffold. 

## Parameters

- Widget body: The main body of the page;
- Widget menuBody: The menu body;
- AppBar appBar: This is used to calculated the appBar height for the back drop;
- int duration: The menu transition duration in milliseconds;
- double menuSize: The menu size on percentage (> 0.0 && < 1.0)
- bool isPanDisabled: Used to enabled/disabled pan gesture;
- bool isBackDropDisabled: Used to enable/disabled the back drop;
- BoxShadow shadow: The shadow of the main body that goes on the menu;
- double menuFriction: This is used to give a parallax effect. 0.0 is static, 
 with 1.0 the menu follows the main body (> 0.0 && < 1.0); 
- UTSDirection direction: horizontal or vertical;
- UTSMode mode: The position of the menu for the horizontal direction, left or right;
- curve: The animation curve;
- onOpen, onClose, onSlide: callbacks;   

## Usage
```
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UTSSideMenu(
        body: _getMainBody(),
        menuBody: _getPegasoMenuBody(),
        appBar: _appBar,
        duration: 600,
        menuSize: 0.7,
        isPanDisabled: false,
        isBackdropDisabled: false,
        shadow: BoxShadow(
          color: Colors.black45,
          offset: Offset(3.0, 0.0),
          spreadRadius: 10.0,
          blurRadius: 3.0
        ),
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
          setState(() {
            // your code
          });
        },
      ),
    );
  } 
```