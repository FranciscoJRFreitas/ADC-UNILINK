import 'package:flutter/material.dart';
import 'package:unilink2023/domain/User.dart';


class UserProfilePage extends StatelessWidget {
  final User user;
  final User targetUser;
  final bool isNotUser;

  UserProfilePage({required this.user, required this.targetUser, required this.isNotUser});

  @override
  Widget build(BuildContext context) {
    //String? currentUser = await cacheFactory.getValue('users', 'username');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 8, 52, 88),
        title: Text(
            '${user.displayName}${user.username == targetUser.username ? ' (You)' : ''}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard('Página a ser alterada para "profile page"', '', context),
              _buildProfileCard('Username', user.username, context),
              _buildProfileCard('Email', user.email, context),
              if (isNotUser)
                _buildProfileCard('Role', user.role ?? 'N/A', context),
              if (isNotUser)
                _buildProfileCard('State', user.state ?? 'N/A', context),
              if (isNotUser)
                _buildProfileCard('Profile Visibility',
                    user.profileVisibility ?? 'N/A', context),
              if (isNotUser)
                _buildProfileCard('Mobile', user.mobilePhone ?? 'N/A', context),
              if (isNotUser)
                _buildProfileCard(
                    'Occupation', user.occupation ?? 'N/A', context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(String title, String value, context) {
    print(value);
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          value,
          style: TextStyle(color: Colors.black87),
          //style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}