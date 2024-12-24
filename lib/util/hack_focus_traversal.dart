import 'package:flutter/widgets.dart';


class SingleFocusTraversal extends ReadingOrderTraversalPolicy {

  final FocusNode focusNode;

  SingleFocusTraversal(this.focusNode);

  @override
  FocusNode? findFirstFocus(FocusNode currentNode, {bool ignoreCurrentFocus = false}) {
    return focusNode;
  }

  @override
  FocusNode findLastFocus(FocusNode currentNode, {bool ignoreCurrentFocus = false}) {
    return focusNode;
  }

  @override
  FocusNode? findFirstFocusInDirection(FocusNode currentNode, TraversalDirection direction) {
    if (currentNode==focusNode) {
      return null;
    }
    return focusNode;
  }

  @override
  bool next(FocusNode currentNode) {
    if (currentNode==focusNode) {
      return super.next(currentNode);
    }
    focusNode.requestFocus();
    return true;
  }

  @override
  bool previous(FocusNode currentNode) {
    if (currentNode==focusNode) {
      return super.previous(currentNode);
    }
    focusNode.requestFocus();
    return true;
  }

  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    if (currentNode==focusNode) {
      return super.inDirection(currentNode, direction);
    }
    focusNode.requestFocus();
    return true;
  }

  @override
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants, FocusNode currentNode) {
    return [focusNode];
  }

}