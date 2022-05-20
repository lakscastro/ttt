import 'package:flutter/material.dart';
import 'package:nsd/nsd.dart';
import 'package:pixelarticons/pixel.dart';

import '../theme/colors.dart';
import '../theme/dp.dart';
import 'clickable.dart';

class RoomListTile extends StatelessWidget {
  const RoomListTile({
    Key? key,
    required this.service,
    required this.onTap,
  }) : super(key: key);

  final Service service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Clickable(
      strokeWidth: 0.0,
      builder: (context, child, isHovered) {
        return ListTile(
          onTap: onTap,
          leading: Icon(
            Pixel.devices,
            color: isHovered ? kHighContrast : kDarkerColor,
            size: k15dp,
          ),
          title: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: service.name!.split('#').first,
                  style: TextStyle(
                    color: isHovered ? kHighContrast : kDarkerColor,
                    fontSize: k10dp,
                  ),
                ),
                TextSpan(
                  text: '#${service.name!.split('#').last}',
                  style: const TextStyle(
                    color: kDisabledColor,
                    fontSize: k10dp,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
