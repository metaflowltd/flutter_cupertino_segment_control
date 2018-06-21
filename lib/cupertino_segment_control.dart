library cupertino_segement_control;

import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';

class SegmentControlItem {
  SegmentControlItem(this.title, this.content);

  final String title;
  final Widget content;
}

abstract class SegmentControlCallbacks {
  void _changeTab(String title);
}


class SegmentControl extends StatefulWidget {
  SegmentControl(this.tabs, {this.activeTabIndex = 0, this.onChange, this.color, this.radius})
      : assert(tabs.length > 1 && tabs.length <= 3),
        assert(activeTabIndex <= tabs.length - 1);

  final List<SegmentControlItem> tabs;
  final int activeTabIndex;
  final Function onChange;
  final Color color;
  final double radius;

  @override
  _SegmentControlState createState() => new _SegmentControlState();
}

class _SegmentControlState extends State<SegmentControl>
    with SegmentControlCallbacks {
  int _activeTabIndex;

  @override
  void initState() {
    super.initState();

    setState(() {
      _activeTabIndex = widget.activeTabIndex;
    });
  }

  void _changeTab(String title) {
    if (widget.onChange != null){
      widget.onChange(_activeTabIndex);
    }
    setState(() {
      for (int i = 0; i < widget.tabs.length; i++) {
        SegmentControlItem t = widget.tabs[i];
        if (t.title == title) {
          _activeTabIndex = i;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activeTab = widget.tabs[_activeTabIndex].content;

    List<_SegmentControlItem> list = <_SegmentControlItem>[];

    for (int i = 0; i < widget.tabs.length; i++) {
      SegmentControlItem tap = widget.tabs[i];
      bool isActive = tap == widget.tabs[_activeTabIndex];
      _ButtonPlace place = _ButtonPlace.start;

      if (i > 0 && (widget.tabs.length - 1 == i)) {
        place = _ButtonPlace.end;
      } else if (i > 0 && (widget.tabs.length - 1 > i)) {
        place = _ButtonPlace.middle;
      }

      list.add(new _SegmentControlItem(this, tap, place, isActive, color: widget.color, radius: widget.radius));
    }

    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: list,
          ),
        activeTab,
      ],
    );
  }
}

class _SegmentControlItem extends StatefulWidget {
  _SegmentControlItem(this.callbacks, this.buttonTab, this.place, this.isActive,
      {this.color = CupertinoColors.activeBlue,radius = 3.0, this.padding = const EdgeInsets.symmetric(vertical: 8.0,
      horizontal: 13.0),
      this.inverseColor = CupertinoColors.white}): _defaultBorderRadius = radius;

  final double _defaultBorderRadius;

  final SegmentControlItem buttonTab;
  final SegmentControlCallbacks callbacks;
  final _ButtonPlace place;
  final bool isActive;
  final Color color;
  final Color inverseColor;
  final EdgeInsets padding;

  @override
  State createState() {
    return new _SegmentControlItemState(color, inverseColor);
  }
}

class _SegmentControlItemState extends State<_SegmentControlItem> {
  _SegmentControlItemState(this.color, this.inverseColor);

  Color color;
  Color inverseColor;
  bool tapDown = false;

  BoxDecoration _boxDecoration(_ButtonPlace place) {
    BorderRadius radius;

    switch (place) {
      case _ButtonPlace.start:
        radius = new BorderRadius.only(
          topLeft: new Radius.circular(widget._defaultBorderRadius),
          bottomLeft: new Radius.circular(widget._defaultBorderRadius),
        );
        break;
      case _ButtonPlace.end:
        radius = new BorderRadius.only(
          topRight: new Radius.circular(widget._defaultBorderRadius),
          bottomRight: new Radius.circular(widget._defaultBorderRadius),
        );
        break;
      default:
        break;
    }

    BoxDecoration dec = new BoxDecoration(
      color: widget.isActive ? color : inverseColor,
      border: place == _ButtonPlace.middle
          ? new Border(
              top: new BorderSide(color: tapDown ? inverseColor : color),
              bottom: new BorderSide(color: tapDown ? inverseColor : color),
            )
          : new Border.all(color: tapDown ? inverseColor : color),
      borderRadius: radius,
    );

    return dec;
  }

  void _tabDown() {
    if (!widget.isActive) {
      setState(() {
        tapDown = true;
        final Color _backupColor = color;
        color = inverseColor;
        inverseColor = _backupColor;
      });
    }
  }

  void _tabUp() {
    if (!widget.isActive) {
      tapDown = false;
      final Color _backupColor = color;
      color = inverseColor;
      inverseColor = _backupColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTapDown: (_) {
        _tabDown();
      },
      onTapUp: (_) {
        _tabUp();
      },
      onTap: () {
        widget.callbacks._changeTab(widget.buttonTab.title);
      },
      child: new Container(
        decoration: _boxDecoration(widget.place),
        padding: widget.padding,
        child: new Text(
          widget.buttonTab.title,
          style: new TextStyle(color: widget.isActive ? inverseColor : color),
        ),
      ),
    );
  }
}

enum _ButtonPlace { start, middle, end }
