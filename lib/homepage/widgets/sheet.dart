import 'package:airaware/homepage/widgets/modal1.dart';
import 'package:flutter/material.dart';
import 'package:airaware/homepage/widgets/modal.dart';


class Sheet {
  static void showModalBottomSheetWithData(BuildContext context, dynamic data) {
    final ValueNotifier<double> snapSizeNotifier = ValueNotifier<double>(0.3);

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            final snapSize = notification.extent;
            snapSizeNotifier.value = snapSize;
            return true;
          },
          child: DraggableScrollableSheet(
            initialChildSize: 0.3, // Initial height set to 30% of the screen
            minChildSize: 0.3, // Minimum height set to 30%
            maxChildSize: 1.0, // Maximum height set to 100%
            snap: true, // Enable snapping
            snapSizes: [0.3, 1.0], // Define snapping points
            expand: false,
            builder: (BuildContext context, ScrollController scrollController) {
              return ValueListenableBuilder<double>(
                valueListenable: snapSizeNotifier,
                builder: (context, snapSize, child) {
                  // Update the layout based on the current snap size
                  if (snapSize >= 0.95) {
                    return SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Modal(data: data ,state:1), // Pass the data to the Modal widget
                      ),
                    );
                  } else {
                    return SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Modal(data: data ,state:0), // Pass the data to the Modal widget
                      ),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
