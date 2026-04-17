import 'package:abroadready/core/di/service_locator.dart';
import 'package:abroadready/core/firestore/schemas/university_application_schema.dart';
import 'package:abroadready/features/home/data/services/university_application_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final UniversityApplicationService _applicationService =
      sl<UniversityApplicationService>();

  Future<void> _onToggle(
    UniversityApplicationEntity application,
    UniversityApplicationDocument document,
    bool value,
  ) async {
    try {
      await _applicationService.toggleDocumentReady(
        applicationId: application.id,
        documentName: document.name,
        isReady: value,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<UniversityApplicationEntity>>(
        stream: _applicationService.watchMyApplications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load your document checklist.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final applications =
              snapshot.data ?? const <UniversityApplicationEntity>[];

          if (applications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No university applications yet. Apply from a university detail page to start your checklist.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  title: Text(
                    application.universityName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2136),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${application.readyDocuments}/${application.totalDocuments} ready • ${application.universityCity}, ${application.universityCountry}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6E7899),
                      ),
                    ),
                  ),
                  trailing: _StatusBadge(application: application),
                  children: application.documents
                      .map(
                        (document) => _DocumentTile(
                          document: document,
                          onChanged: (value) =>
                              _onToggle(application, document, value),
                        ),
                      )
                      .toList(growable: false),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.application});

  final UniversityApplicationEntity application;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    if (application.totalDocuments > 0 &&
        application.readyDocuments == application.totalDocuments) {
      color = const Color(0xFF1D9E62);
      label = 'VERIFIED';
    } else if (application.readyDocuments > 0) {
      color = const Color(0xFFB36C00);
      label = 'PENDING';
    } else {
      color = const Color(0xFF5D6F93);
      label = 'ACTION REQUIRED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.document,
    required this.onChanged,
  });

  final UniversityApplicationDocument document;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => onChanged(!document.isReady),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: document.isReady
                    ? const Color(0xFF4A59E3)
                    : const Color(0xFFE6EAF8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                document.isReady ? CupertinoIcons.check_mark : CupertinoIcons.add,
                size: 16,
                color: document.isReady
                    ? Colors.white
                    : const Color(0xFF8A94B3),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              document.name,
              style: TextStyle(
                fontSize: 15,
                color: const Color(0xFF1C2236),
                decoration: document.isReady
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          CupertinoSwitch(
            value: document.isReady,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}