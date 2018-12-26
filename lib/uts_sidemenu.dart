import 'package:flutter/material.dart';

enum UTSDirection { horizontal, vertical }
enum UTSMode { right, left }

typedef void ToggleMenu();
typedef void OnSlide(double dx);
typedef void OnOpen();
typedef void OnClose();
typedef void OnStateChange(AnimationStatus status);

class MenuNotifier {
  ToggleMenu _toggle;
  ToggleMenu _open;
  ToggleMenu _close;

  static MenuNotifier notify = new MenuNotifier();

  void setMenuToggle(ToggleMenu n) {
    this._toggle = n;
  }

  void setMenuOpen(ToggleMenu n) {
    this._open = n;
  }

  void setMenuClose(ToggleMenu n) {
    this._close = n;
  }

  void toggle() {
    this._toggle();
  }

  void open() {
    this._open();
  }

  void close() {
    this._close();
  }
}

class UTSSideMenu extends StatefulWidget {
  final Widget body;
  final Widget menuBody;
  final AppBar appBar;
  final double menuSize;
  final bool isBackdropDisabled;
  final bool isPanDisabled;
  final double menuFriction;
  final int duration;
  final UTSDirection direction;
  final UTSMode mode;
  final BoxShadow shadow;
  final dynamic curve;
  final OnOpen onOpen;
  final OnClose onClose;
  final OnSlide onSlide;
  final OnStateChange onStateChange;

  UTSSideMenu(
      {@required this.body,
      @required this.menuBody,
      appBar,
      @required menuSize,
      this.duration = 500,
      this.direction = UTSDirection.horizontal,
      this.mode = UTSMode.right,
      this.isBackdropDisabled = false,
      this.isPanDisabled = false,
      this.menuFriction = 0.0,
      this.curve = Curves.fastOutSlowIn,
      this.shadow,
      this.onOpen,
      this.onClose,
      this.onSlide,
      this.onStateChange})
      : this.appBar = appBar,
        assert(menuSize >= 0.0 &&
            menuSize <= 1.0 &&
            menuFriction >= 0.0 &&
            menuFriction <= 1.0),
        this.menuSize = menuSize;

  @override
  UTSSideMenuState createState() => UTSSideMenuState();
}

class UTSSideMenuState extends State<UTSSideMenu>
    with TickerProviderStateMixin {
  bool _isOpened;
  double _position;
  double _backDropLeft;
  double _menuSize;
  double _backDropOpacity;
  double _maxBackDropOpacity;
  int _animationDuration;
  double _panOffset;
  double _opacityStart;
  bool _canPan;
  AnimationController _controller;
  Tween<double> _animationTween;
  Animation<double> _animation;
  Animation curve;
  double _initialMenuPosition;
  double _menuPosition;
  double startPos = 0;

  @override
  void didChangeDependencies() {
    setState(() {
      _backDropLeft = MediaQuery.of(context).size.width;
      if (widget.direction == UTSDirection.horizontal) {
        _menuSize = MediaQuery.of(context).size.width * widget.menuSize;
      } else {
        _menuSize = MediaQuery.of(context).size.height * widget.menuSize;
      }
      if (widget.menuFriction != 0) {
        _initialMenuPosition = -(_menuSize * widget.menuFriction);
        _menuPosition = -_initialMenuPosition;
      } else {
        _initialMenuPosition = 0;
        _menuPosition = 0;
      }
    });
    _initMenuAnimations();

    print(_getInitialMenu(2));
    print(_getInitialMenu(4));
    print(_getInitialMenu(1));
    print(_getInitialMenu(3));

    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _position = 0;
    _backDropOpacity = 0;
    _maxBackDropOpacity = 0.4;
    _animationDuration = widget.duration;
    _panOffset = 30.0;
    _canPan = false;
    _isOpened = false;
    _opacityStart = 0.2;

    MenuNotifier.notify.setMenuToggle(() {
      this._toggle();
    });
    MenuNotifier.notify.setMenuOpen(() {
      this._open();
    });
    MenuNotifier.notify.setMenuClose(() {
      this._close();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initMenuAnimations() {
    _controller = new AnimationController(
      duration: Duration(milliseconds: _animationDuration),
      vsync: this,
    )
      ..addListener(() {
        setState(() {
          if (!_isOpened &&
              !widget.isBackdropDisabled &&
              _controller.value >= _opacityStart &&
              (_controller.value - _opacityStart) <= _maxBackDropOpacity) {
            _backDropOpacity = _controller.value - _opacityStart;
          } else if (_isOpened &&
              !widget.isBackdropDisabled &&
              _controller.value - (1.0 - _maxBackDropOpacity) >= 0) {
            _backDropOpacity = _controller.value - (1.0 - _maxBackDropOpacity);
          }
          _position = _animation.value;

          _initialMenuPosition =
              ((_position / _menuSize) * _menuPosition) - _menuPosition;
        });

        if (widget.onSlide != null) widget.onSlide(_position);
      })
      ..addStatusListener(
        (status) {
          if (widget.onStateChange != null) widget.onStateChange(status);

          if (status == AnimationStatus.dismissed) {
            setState(() {
              _isOpened = false;
              _backDropLeft = MediaQuery.of(context).size.width;
            });
            if (widget.onClose != null) widget.onClose();
          }
          if (status == AnimationStatus.completed) {
            setState(() {
              _isOpened = true;
            });
            if (widget.onOpen != null) widget.onOpen();
          }
        },
      );

    initCurve(widget.curve);
  }

  void initCurve(dynamic c) {
    curve = CurvedAnimation(parent: _controller, curve: c);
    /* the _menuSize - 1 is to remove a blank line between the menu and the main body.
     * I don't know why but there is a little empty region without that -1 */
    _animationTween = new Tween<double>(begin: 0, end: _menuSize - 1);
    _animation = _animationTween.animate(curve);
  }

  void _toggle() {
    if (!_isOpened) {
      _open();
    } else {
      _close();
    }
  }

  void _open() {
    setState(() {
      _backDropLeft = 0;
    });
    _controller.forward().orCancel;
  }

  void _close() {
    _controller.reverse().orCancel;
  }

  double _getDragPosition(double d) {
    if (widget.direction == UTSDirection.horizontal &&
        widget.mode == UTSMode.right) {
      return -d + MediaQuery.of(context).size.width;
    } else if (widget.direction == UTSDirection.vertical ||
        (widget.direction == UTSDirection.horizontal &&
            widget.mode == UTSMode.left)) {
      return d;
    }
    return 0.0;
  }

  // @pos 1. top - 2. right - 3. bottom - 4. left //

  double _getInitialMenu(int pos) {
    switch (pos) {
      //top
      case 1:
        return widget.direction == UTSDirection.vertical
            ? _initialMenuPosition
            : 0.0;
        break;
      //right
      case 2:
        return widget.direction == UTSDirection.horizontal &&
                widget.mode == UTSMode.right
            ? _initialMenuPosition
            : widget.direction == UTSDirection.horizontal &&
                    widget.mode == UTSMode.left
                ? (MediaQuery.of(context).size.width - _menuSize) -
                    _initialMenuPosition
                : 0.0;
      //bottom
      case 3:
        return widget.direction == UTSDirection.vertical
            ? MediaQuery.of(context).size.height -
                _menuSize -
                _initialMenuPosition
            : 0.0;
        break;
      //left
      case 4:
        return widget.direction == UTSDirection.horizontal &&
                widget.mode == UTSMode.right
            ? MediaQuery.of(context).size.width -
                _menuSize -
                _initialMenuPosition
            : widget.direction == UTSDirection.horizontal &&
                    widget.mode == UTSMode.left
                ? _initialMenuPosition
                : 0.0;
        break;
      default:
        return 0.0;
    }
  }

  double _getMainBodyPosition(int pos) {
    switch (pos) {
      //top
      case 1:
        return widget.direction == UTSDirection.vertical ? _position : 0;
        break;
      //right
      case 2:
        return widget.direction == UTSDirection.horizontal &&
                widget.mode == UTSMode.right
            ? _position
            : widget.direction == UTSDirection.horizontal &&
                    widget.mode == UTSMode.left
                ? -_position
                : 0;
        break;
      //bottom
      case 3:
        return widget.direction == UTSDirection.vertical ? -_position : 0;
        break;
      //left
      case 4:
        return widget.direction == UTSDirection.horizontal &&
                widget.mode == UTSMode.right
            ? -_position
            : widget.direction == UTSDirection.horizontal &&
                    widget.mode == UTSMode.left
                ? _position
                : 0;
        break;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          right: _getInitialMenu(2),
          left: _getInitialMenu(4),
          top: _getInitialMenu(1),
          bottom: _getInitialMenu(3),
          child: widget.menuBody,
        ),
        Positioned.fill(
          right: _getMainBodyPosition(2),
          left: _getMainBodyPosition(4),
          top: _getMainBodyPosition(1),
          bottom: _getMainBodyPosition(3),
          child: GestureDetector(
            onHorizontalDragEnd: (e) {
              if (widget.isPanDisabled) return;

              bool closeBreakpoint = _position >= _menuSize - 30;
              bool openBreakpoint = _position <= 50;

              if (closeBreakpoint && _isOpened) {
                _open();
              } else if (openBreakpoint && !_isOpened) {
                _close();
              } else if (!_isOpened) {
                _open();
              } else {
                _close();
              }
            },
            onHorizontalDragStart: (e) {
              if (widget.isPanDisabled) return;

              startPos = _getDragPosition(
                  widget.direction == UTSDirection.vertical
                      ? e.globalPosition.dy
                      : e.globalPosition.dx);

              if (widget.direction == UTSDirection.vertical) {
                _panOffset = MediaQuery.of(context).size.height - _panOffset;
              }

              setState(() {
                _canPan = (startPos < _panOffset && !_isOpened || _isOpened);
              });
            },
            onHorizontalDragUpdate: (e) {
              if (!_canPan || widget.isPanDisabled) return;

              setState(() {
                _backDropLeft = 0;
              });
              double pos = _getDragPosition(
                  widget.direction == UTSDirection.vertical
                      ? e.globalPosition.dy
                      : e.globalPosition.dx);

              /* TODO: Adjust this section. Right now, when dragging, the main section doesn't follow the finger precisely because of the Curve. Now works well only with linear curve. */
              /* Maybe i can change the curve dynamically but i don't like it and doesn't work right. Waiting for a better solution.  */
              _controller.value = (pos / _menuSize).clamp(0.0, 1.0);
              /*************/
            },
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: [
                        widget.shadow == null
                            ? BoxShadow(
                                color: Colors.black.withAlpha(70),
                                offset: Offset(3.0, 0),
                                spreadRadius: 3.0,
                                blurRadius: 15.0,
                              )
                            : widget.shadow
                      ],
                    ),
                    child: widget.body,
                  ),
                ),
                Positioned(
                  left: _backDropLeft,
                  right: 0,
                  top: widget.appBar != null
                      ? (widget.appBar.preferredSize.height +
                          MediaQuery.of(context).padding.top)
                      : MediaQuery.of(context).padding.top,
                  bottom: 0,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: _animationDuration),
                    curve: Curves.ease,
                    opacity: _backDropOpacity,
                    child: Container(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
