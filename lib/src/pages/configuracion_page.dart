import 'package:flutter/material.dart';
import 'package:menubar/src/pages/config/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  bool _sonido = true;
  bool _notificaciones = true;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sonido = prefs.getBool('sonido') ?? true;
      _notificaciones = prefs.getBool('notificaciones') ?? true;
    });
  }

  Future<void> _guardarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sonido', _sonido);
    await prefs.setBool('notificaciones', _notificaciones);
  }

  @override
  Widget build(BuildContext context) {
    final modoOscuro = Provider.of<ThemeNotifier>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Sonido"),
            value: _sonido,
            onChanged: (v) {
              setState(() => _sonido = v);
              _guardarPreferencias();
            },
          ),
          SwitchListTile(
            title: const Text("Notificaciones"),
            value: _notificaciones,
            onChanged: (v) {
              setState(() => _notificaciones = v);
              _guardarPreferencias();
            },
          ),
          SwitchListTile(
            title: const Text("Modo oscuro"),
            value: modoOscuro,
            onChanged: (v) {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
          ListTile(
            title: const Text("Cambiar idioma"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Solo disponible en Español")),
              );
            },
          ),
          ListTile(
            title: const Text("Acerca de los museos"),
            trailing: const Icon(Icons.info),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text("Descubre los museos más destacados de Quito.")),
              );
            },
          ),
        ],
      ),
    );
  }
}

