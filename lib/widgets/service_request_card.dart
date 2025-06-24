import 'package:chamba_app/models/service_request_model.dart';
import 'package:chamba_app/models/user_model.dart';
import 'package:chamba_app/utils/helpers.dart';
import 'package:chamba_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';

class ServiceRequestCard extends StatelessWidget {
  final ServiceRequest request;
  final UserType userType; // To tailor the display (client or worker view)
  final VoidCallback? onTap;

  const ServiceRequestCard({
    super.key,
    required this.request,
    required this.userType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // Determine the other party involved
    User? otherParty = (userType == UserType.client) ? request.worker : request.client;
    String otherPartyRole = (userType == UserType.client) ? "Trabajador" : "Cliente";

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      clipBehavior: Clip.antiAlias, // Ensures the InkWell splash is contained
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      request.category,
                      style: textTheme.titleLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text(
                      Helpers.capitalizeFirstLetter(request.status.name),
                      style: textTheme.labelSmall?.copyWith(color: _getStatusColor(request.status, colorScheme).computeLuminance() > 0.5 ? Colors.black : Colors.white),
                    ),
                    backgroundColor: _getStatusColor(request.status, colorScheme),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              _buildInfoRow(Icons.calendar_today, Helpers.formatDateTime(request.dateTime), textTheme),
              _buildInfoRow(Icons.location_on, request.address, textTheme),
              if (request.description.isNotEmpty && userType == UserType.worker) // Show description to worker
                 Padding(
                   padding: const EdgeInsets.only(top:4.0),
                   child: _buildInfoRow(Icons.notes, request.description, textTheme, maxLines: 2),
                 ),

              const Divider(height: 20.0),

              if (otherParty != null)
                Row(
                  children: [
                    UserAvatar(user: otherParty, radius: 20),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(otherPartyRole, style: textTheme.bodySmall?.copyWith(color: textTheme.bodySmall?.color?.withOpacity(0.7))),
                          Text(otherParty.name, style: textTheme.titleMedium),
                           if (userType == UserType.client && request.worker != null) // Show worker rating to client
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                SizedBox(width: 4),
                                Text("${request.worker!.averageRating.toStringAsFixed(1)} (${request.worker!.totalRatings} calific.)", style: textTheme.bodySmall),
                                if(request.worker!.isVerified) ...[
                                  SizedBox(width: 6),
                                  Icon(Icons.verified_user, color: colorScheme.secondary, size: 14),
                                ]
                              ],
                            ),
                        ],
                      ),
                    ),
                    // Could add a chat icon or call icon here if applicable
                    // Icon(Icons.chevron_right, color: Colors.grey)
                  ],
                )
              else if (request.status == ServiceStatus.pending && userType == UserType.client)
                Text(
                  'Esperando asignación de trabajador...',
                  style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                )
              else if (request.status == ServiceStatus.rejected && userType == UserType.worker)
                 Text(
                  'Rechazaste este trabajo.',
                  style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: colorScheme.error),
                ),

              // Show rating if completed and rated (client's view of worker's rating)
              if (request.status == ServiceStatus.completed && userType == UserType.client && request.clientRatingForWorker != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Text("Tu calificación: ", style: textTheme.bodySmall),
                      ...List.generate(5, (index) => Icon(
                        index < request.clientRatingForWorker! ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      )),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, TextTheme textTheme, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.0, color: textTheme.bodySmall?.color?.withOpacity(0.6)),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodyMedium,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ServiceStatus status, ColorScheme colorScheme) {
    switch (status) {
      case ServiceStatus.pending:
        return Colors.orange.shade300;
      case ServiceStatus.accepted:
        return colorScheme.secondary.withOpacity(0.8);
      case ServiceStatus.inProgress:
        return colorScheme.primary.withOpacity(0.8);
      case ServiceStatus.completed:
        return Colors.green.shade400;
      case ServiceStatus.cancelled:
        return Colors.grey.shade500;
      case ServiceStatus.rejected:
        return colorScheme.error.withOpacity(0.7);
      default:
        return Colors.grey;
    }
  }
}
