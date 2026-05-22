import 'package:flutter/material.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  bool _isFollowing = false;

 
  final Map<String, dynamic> companyData = {
    'name': 'TechFlow Solutions',
    'logo': 'https://via.placeholder.com/120',
    'cover': 'https://via.placeholder.com/400x200',
    'tagline': 'Innovative Technology Solutions',
    'industry': 'Information Technology',
    'founded': '2015',
    'headquarters': 'San Francisco, CA',
    'employees': '500+',
    'website': 'www.techflowsolutions.com',
    'email': 'contact@techflow.com',
    'phone': '+1 (415) 555-0123',
    'about':
        'TechFlow Solutions is a leading provider of innovative technology solutions for enterprises worldwide. We specialize in cloud computing, AI integration, and digital transformation services. Our dedicated team of experts works tirelessly to deliver cutting-edge solutions that drive business growth.',
    'stats': [
      {'label': 'Employees', 'value': '500+'},
      {'label': 'Countries', 'value': '25+'},
      {'label': 'Projects', 'value': '1000+'},
      {'label': 'Clients', 'value': '300+'},
    ],
    'services': [
      'Cloud Solutions',
      'AI & Machine Learning',
      'Data Analytics',
      'Mobile Development',
      'Web Development',
      'IT Consulting',
    ],
    'locations': [
      {
        'city': 'San Francisco',
        'country': 'USA',
        'address': '123 Tech Street, San Francisco, CA 94105',
        'phone': '+1 (415) 555-0123',
      },
      {
        'city': 'London',
        'country': 'UK',
        'address': '456 Innovation Drive, London, UK',
        'phone': '+44 20 7946 0958',
      },
      {
        'city': 'Mumbai',
        'country': 'India',
        'address': '789 Business Park, Mumbai, India',
        'phone': '+91 22 2341 3456',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text('Edit Profile')),
              const PopupMenuItem(child: Text('Share')),
              const PopupMenuItem(child: Text('Report')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            Stack(
              children: [
                Container(
                  height: 200,
                  color: Colors.blue.shade300,
                  child: Image.network(
                    companyData['cover'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.blue.shade300,
                        child: Center(
                          child: Icon(
                            Icons.image,
                            size: 60,
                            color: Colors.white30,
                          ),
                        ),
                      );
                    },
                  ),
                ),
               
                Positioned(
                  bottom: -40,
                  left: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Image.network(
                        companyData['logo'],
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.business,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              companyData['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              companyData['tagline'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _isFollowing = !_isFollowing);
                        },
                        icon: Icon(_isFollowing ? Icons.check : Icons.add),
                        label: Text(_isFollowing ? 'Following' : 'Follow'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFollowing
                              ? Colors.blue.shade700
                              : Colors.blue.shade100,
                          foregroundColor: _isFollowing
                              ? Colors.white
                              : Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: companyData['stats'].length,
                itemBuilder: (context, index) {
                  final stat = companyData['stats'][index];
                  return _buildStatCard(stat['value'], stat['label']);
                },
              ),
            ),
            const SizedBox(height: 28),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.business,
                      'Industry',
                      companyData['industry'],
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Founded',
                      companyData['founded'],
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      Icons.location_on,
                      'Headquarters',
                      companyData['headquarters'],
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      Icons.people,
                      'Employees',
                      companyData['employees'],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionCard(
                title: 'Contact Information',
                child: Column(
                  children: [
                    _buildContactItem(
                      icon: Icons.email,
                      label: 'Email',
                      value: companyData['email'],
                    ),
                    const Divider(height: 20),
                    _buildContactItem(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: companyData['phone'],
                    ),
                    const Divider(height: 20),
                    _buildContactItem(
                      icon: Icons.language,
                      label: 'Website',
                      value: companyData['website'],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionCard(
                title: 'About Us',
                child: Text(
                  companyData['about'],
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionCard(
                title: 'Our Services',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (companyData['services'] as List<String>)
                      .map((service) => _buildServiceChip(service))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 28),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionCard(
                title: 'Our Locations',
                child: Column(
                  children: List.generate(companyData['locations'].length, (
                    index,
                  ) {
                    final location = companyData['locations'][index];
                    return Column(
                      children: [
                        _buildLocationCard(location),
                        if (index < companyData['locations'].length - 1)
                          const Divider(height: 20),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 28),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _launchEmail(companyData['email']),
                    icon: const Icon(Icons.mail),
                    label: const Text('Send Email'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _launchPhone(companyData['phone']),
                    icon: const Icon(Icons.phone),
                    label: const Text('Call Company'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade700),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildServiceChip(String service) {
    return Chip(
      label: Text(service),
      backgroundColor: Colors.blue.shade100,
      labelStyle: TextStyle(
        color: Colors.blue.shade700,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${location['city']}, ${location['country']}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                location['address'],
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              location['phone'],
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ],
    );
  }

  void _launchEmail(String email) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Opening email client for $email')));
  }

  void _launchPhone(String phone) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Calling $phone')));
  }
}
  