import 'package:chamba_app/models/user_model.dart';
import 'package:chamba_app/utils/helpers.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final User? user;
  final double radius;
  final VoidCallback? onTap;
  final String? placeholderText; // Optional text if user is null but we want to show initials

  const UserAvatar({
    super.key,
    this.user,
    this.radius = 24.0,
    this.onTap,
    this.placeholderText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ImageProvider? backgroundImage;
    Widget? child;

    if (user?.profilePictureUrl != null && user!.profilePictureUrl!.isNotEmpty) {
      backgroundImage = NetworkImage(user!.profilePictureUrl!);
    } else {
      // Use initials if no image URL
      String initials = '';
      if (user?.name != null && user!.name.isNotEmpty) {
        initials = Helpers.getInitials(user!.name);
      } else if (placeholderText != null && placeholderText!.isNotEmpty) {
        initials = Helpers.getInitials(placeholderText!);
      }

      if (initials.isNotEmpty) {
        child = Text(
          initials,
          style: TextStyle(
            fontSize: radius * 0.8, // Adjust font size based on radius
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary, // Or a contrasting color
          ),
        );
      } else {
        // Fallback icon if no image and no initials
        child = Icon(
          Icons.person,
          size: radius * 1.2, // Adjust icon size
          color: theme.colorScheme.onPrimary, // Or a contrasting color
        );
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: user?.profilePictureUrl != null && user!.profilePictureUrl!.isNotEmpty
            ? Colors.transparent // Let network image show
            : _getAvatarBackgroundColor(user?.name ?? placeholderText, theme), // Background for initials/icon
        backgroundImage: backgroundImage,
        child: child,
      ),
    );
  }

  Color _getAvatarBackgroundColor(String? name, ThemeData theme) {
    if (name == null || name.isEmpty) {
      return theme.colorScheme.primary.withOpacity(0.7); // Default color
    }
    // Simple hash to get a somewhat consistent color based on name
    final int hash = name.hashCode;
    final List<Color> colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      Colors.teal,
      Colors.deepOrange,
      Colors.indigo,
      Colors.brown,
    ];
    return colors[hash % colors.length].withOpacity(0.8);
  }
}

// Example Usage:
// User someUser = User(id: '1', name: 'Jane Doe', email: 'jane@example.com', userType: UserType.client, profilePictureUrl: 'https://via.placeholder.com/150');
// UserAvatar(user: someUser, radius: 30)

// User userWithNoImage = User(id: '2', name: 'John Smith', email: 'john@example.com', userType: UserType.worker);
// UserAvatar(user: userWithNoImage, radius: 25)

// UserAvatar(radius: 20, placeholderText: "Guest") // For a guest user or when user is null
// UserAvatar(user: null, radius: 20) // Will show default person icon
