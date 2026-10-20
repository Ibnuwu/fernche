import 'package:flutter/material.dart';

class FerncheAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  const FerncheAppBar({super.key, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Image.asset(
        Theme.of(context).brightness == Brightness.dark
            ? 'assets/logo-putih.png'
            : 'assets/logo-hitam.png',
        height: 40,
      ),
      actions: actions,
    );
  }
}
