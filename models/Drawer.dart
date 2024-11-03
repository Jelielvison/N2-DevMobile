import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Perfil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Meus Hobbies'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/hobbies');
            },
          ),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Cadastrar Hobby'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/add_hobby');
            },
          ),
        ],
      ),
    );
  }
}