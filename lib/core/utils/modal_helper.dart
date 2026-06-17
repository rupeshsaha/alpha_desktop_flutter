import 'package:flutter/material.dart';

class ModalHelper {
  /// Shows a right-side sliding modal panel.
  /// 
  /// The [title] is displayed at the top.
  /// The [contentBuilder] returns the scrollable middle content.
  /// The [actionBuilder] returns the bottom action widget (like buttons), pinned to the bottom.
  static Future<T?> showRightSideModal<T>({
    required BuildContext context,
    required String title,
    required Widget Function(BuildContext context, StateSetter setState) contentBuilder,
    required Widget Function(BuildContext context, StateSetter setState) actionBuilder,
    bool barrierDismissible = true,
    double width = 500,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierLabel: 'RightSideModal',
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            type: MaterialType.transparency,
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  width: width,
                  height: double.infinity,
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                              splashRadius: 24,
                            ),
                          ],
                        ),
                      ),
                      
                      // Scrollable Body
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: contentBuilder(context, setModalState),
                        ),
                      ),
                      
                      // Pinned Bottom Actions
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border(
                            top: BorderSide(
                              color: Theme.of(context).dividerColor.withOpacity(0.1),
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: actionBuilder(context, setModalState),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    );
  }
}
