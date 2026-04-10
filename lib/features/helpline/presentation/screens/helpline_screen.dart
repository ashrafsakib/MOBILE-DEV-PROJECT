import 'package:abroadready/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelplineScreen extends StatefulWidget {
  const HelplineScreen({super.key});

  @override
  State<HelplineScreen> createState() => _HelplineScreenState();
}

class _HelplineScreenState extends State<HelplineScreen> {
  static const String _allCountries = 'All';

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedCountry = _allCountries;

  final List<_SupportContact> _contacts = const [
    _SupportContact(
      name: 'University of Helsinki Admissions',
      country: 'Finland',
      type: 'University',
      phone: '+3582941911',
      email: 'admissions@helsinki.fi',
    ),
    _SupportContact(
      name: 'Aalto University Admissions',
      country: 'Finland',
      type: 'University',
      phone: '+358947001',
      email: 'admissions@aalto.fi',
    ),
    _SupportContact(
      name: 'Embassy of Germany in Helsinki',
      country: 'Finland',
      type: 'Embassy',
      phone: '+358945820',
      email: 'info@helsinki.diplo.de',
    ),
    _SupportContact(
      name: 'Technical University of Munich Admissions',
      country: 'Germany',
      type: 'University',
      phone: '+498928901',
      email: 'studium@tum.de',
    ),
    _SupportContact(
      name: 'RWTH Aachen International Office',
      country: 'Germany',
      type: 'University',
      phone: '+492418090',
      email: 'international@rwth-aachen.de',
    ),
    _SupportContact(
      name: 'Embassy of Finland in Berlin',
      country: 'Germany',
      type: 'Embassy',
      phone: '+4930505030',
      email: 'sanomat.ber@formin.fi',
    ),
  ];

  final List<_HelpArticle> _articles = const [
    _HelpArticle(
      country: 'Finland',
      university: 'University of Helsinki',
      title: 'How to choose your first-term courses in Finland',
      summary:
          'A practical checklist to pick courses, balance workload, and avoid timetable conflicts.',
      category: 'Academics',
    ),
    _HelpArticle(
      country: 'Finland',
      university: 'Aalto University',
      title: 'Finland student visa documents explained',
      summary:
          'Understand what documents are needed before departure and how to prepare backups.',
      category: 'Visa',
    ),
    _HelpArticle(
      country: 'Finland',
      university: 'Tampere University',
      title: 'Finding student accommodation quickly in Tampere',
      summary:
          'Tips for shortlisting neighborhoods, reading lease terms, and avoiding rental scams.',
      category: 'Housing',
    ),
    _HelpArticle(
      country: 'Finland',
      university: 'University of Turku',
      title: 'Part-time jobs for international students in Finland',
      summary:
          'Work-hour rules, where to search, and how to tailor your CV for campus jobs.',
      category: 'Career',
    ),
    _HelpArticle(
      country: 'Germany',
      university: 'Technical University of Munich (TUM)',
      title: 'Germany health insurance basics for newcomers',
      summary:
          'What to buy, when to buy it, and common mistakes students make in their first month.',
      category: 'Health',
    ),
    _HelpArticle(
      country: 'Germany',
      university: 'Heidelberg University',
      title: 'Opening a student bank account in Germany',
      summary:
          'Step-by-step guide with required IDs, proof of address, and onboarding timelines.',
      category: 'Finance',
    ),
    _HelpArticle(
      country: 'Germany',
      university: 'RWTH Aachen University',
      title: 'Orientation week survival guide for German campuses',
      summary:
          'How to plan your first week, meet communities, and complete must-do admin tasks.',
      category: 'Campus Life',
    ),
    _HelpArticle(
      country: 'Germany',
      university: 'Technical University of Berlin',
      title: 'Staying on top of assignment deadlines',
      summary:
          'Build a realistic assignment calendar and avoid last-minute submission issues.',
      category: 'Academics',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openUri(Uri uri) async {
    final success = await launchUrl(uri);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open this action right now.')),
      );
    }
  }

  Future<void> _callNumber(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    await _openUri(uri);
  }

  Future<void> _emailAddress(String email, String subject) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: <String, String>{'subject': subject},
    );
    await _openUri(uri);
  }

  List<String> get _countryOptions {
    final countries =
        _articles.map((article) => article.country).toSet().toList()..sort();
    return <String>[_allCountries, ...countries];
  }

  bool _matchesCountry(String country) {
    return _selectedCountry == _allCountries || country == _selectedCountry;
  }

  List<_HelpArticle> get _filteredArticles {
    final query = _query.trim().toLowerCase();
    return _articles.where((article) {
      if (!_matchesCountry(article.country)) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }

      return article.title.toLowerCase().contains(query) ||
          article.country.toLowerCase().contains(query) ||
          article.university.toLowerCase().contains(query) ||
          article.category.toLowerCase().contains(query) ||
          article.summary.toLowerCase().contains(query);
    }).toList();
  }

  List<_SupportContact> get _filteredContacts {
    final query = _query.trim().toLowerCase();
    return _contacts.where((contact) {
      if (!_matchesCountry(contact.country)) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }

      return contact.name.toLowerCase().contains(query) ||
          contact.country.toLowerCase().contains(query) ||
          contact.type.toLowerCase().contains(query) ||
          contact.email.toLowerCase().contains(query) ||
          contact.phone.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final articles = _filteredArticles;
    final contacts = _filteredContacts;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Student Helpline')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Text(
              'Need help? Contact a university or embassy directly, and read country-specific help articles.',
              style: textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _countryOptions
                .map(
                  (country) => ChoiceChip(
                    label: Text(country),
                    selected: _selectedCountry == country,
                    onSelected: (_) =>
                        setState(() => _selectedCountry = country),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search by country, university, embassy or topic',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
          const SizedBox(height: 18),
          Text('Contact Directory', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '${contacts.length} contact${contacts.length == 1 ? '' : 's'} available',
            style: textTheme.labelLarge,
          ),
          const SizedBox(height: 10),
          if (contacts.isEmpty)
            _EmptyState(text: 'No contacts match this filter.')
          else
            ...contacts.map(
              (contact) => _ContactCard(
                contact: contact,
                onCall: () => _callNumber(contact.phone),
                onEmail: () => _emailAddress(
                  contact.email,
                  'Support request - ${contact.name}',
                ),
              ),
            ),
          const SizedBox(height: 14),
          Text('Help Articles', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '${articles.length} article${articles.length == 1 ? '' : 's'} found',
            style: textTheme.labelLarge,
          ),
          const SizedBox(height: 10),
          if (articles.isEmpty)
            _EmptyState(text: 'No articles match your search.')
          else
            ...articles.map((article) => _ArticleCard(article: article)),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.contact,
    required this.onCall,
    required this.onEmail,
  });

  final _SupportContact contact;
  final VoidCallback onCall;
  final VoidCallback onEmail;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${contact.country} - ${contact.type}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Call',
                  onPressed: onCall,
                  icon: const Icon(Icons.call),
                ),
                IconButton(
                  tooltip: 'Email',
                  onPressed: onEmail,
                  icon: const Icon(Icons.mail_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(contact.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Phone: ${contact.phone}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Email: ${contact.email}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article});

  final _HelpArticle article;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                article.category,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            const SizedBox(height: 10),
            Text(article.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              article.university,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              article.summary,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpArticle {
  const _HelpArticle({
    required this.country,
    required this.university,
    required this.title,
    required this.summary,
    required this.category,
  });

  final String country;
  final String university;
  final String title;
  final String summary;
  final String category;
}

class _SupportContact {
  const _SupportContact({
    required this.name,
    required this.country,
    required this.type,
    required this.phone,
    required this.email,
  });

  final String name;
  final String country;
  final String type;
  final String phone;
  final String email;
}
