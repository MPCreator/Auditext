import 'package:flutter/material.dart';

import '../../../models/color.dart';
import '../../services/db/dao/color_dao.dart';

class SettingsColorScreen extends StatefulWidget {
  const SettingsColorScreen({super.key});

  @override
 State<SettingsColorScreen> createState() => _SettingsColorScreenState();
}

class _SettingsColorScreenState extends State<SettingsColorScreen> {
  List<Color> _colors = [];
  final ColorDAO _colorDAO = ColorDAO();

  @override
  void initState() {
    super.initState();
    _fetchColors();
  }

  Future<void> _fetchColors() async {
    final colors = await _colorDAO.getColors();
    setState(() {
      _colors = colors;
    });
  }

  Future<void> _addColor(String name) async {
    final newColor = Color(nombre: name);
    await _colorDAO.insertColor(newColor);
    _fetchColors();
  }

  Future<void> _editColor(int id, String newName) async {
    final updatedColor = Color(id: id, nombre: newName);
    await _colorDAO.updateColor(updatedColor);
    _fetchColors();
  }

  Future<void> _deleteColor(int id) async {
    await _colorDAO.deleteColor(id);
    _fetchColors();
  }

  void _showAddColorDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir color'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nombre del color'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                _addColor(name);
              }
              Navigator.pop(context);
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  void _showEditColorDialog(int id, String currentName) {
    final TextEditingController nameController =
    TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar color'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nuevo nombre del color'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                _editColor(id, newName);
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Colores')),
      ),
      body: _colors.isEmpty
          ? const Center(child: Text('No hay colores disponibles.'))
          : ListView.builder(
        itemCount: _colors.length,
        itemBuilder: (context, index) {
          final color = _colors[index];
          return ListTile(
            title: Text(color.nombre),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () =>
                      _showEditColorDialog(color.id!, color.nombre),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteColor(color.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddColorDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
