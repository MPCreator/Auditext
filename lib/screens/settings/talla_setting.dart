import 'package:flutter/material.dart';
import '../../models/talla.dart';
import '../../services/db/dao/talla_dao.dart';

class SettingsTallaScreen extends StatefulWidget {
  const SettingsTallaScreen({super.key});

  @override
  State<SettingsTallaScreen> createState() => _SettingsTallaScreenState();
}

class _SettingsTallaScreenState extends State<SettingsTallaScreen> {
  List<Talla> _tallas = [];
  final TallaDAO _tallaDAO = TallaDAO();

  @override
  void initState() {
    super.initState();
    _fetchTallas();
  }

  Future<void> _fetchTallas() async {
    final tallas = await _tallaDAO.getTallas();
    setState(() {
      _tallas = tallas;
    });
  }

  Future<void> _addTalla(String rango) async {
    final newTalla = Talla(rango: rango);
    await _tallaDAO.insertTalla(newTalla);
    _fetchTallas();
  }

  Future<void> _editTalla(int id, String newRango) async {
    final updatedTalla = Talla(id: id, rango: newRango);
    await _tallaDAO.updateTalla(updatedTalla);
    _fetchTallas();
  }

  Future<void> _deleteTalla(int id) async {
    await _tallaDAO.deleteTalla(id);
    _fetchTallas();
  }

  void _showAddTallaDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir talla'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Rango de la talla'),
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
                _addTalla(name);
              }
              Navigator.pop(context);
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  void _showEditTallaDialog(int id, String currentName) {
    final TextEditingController nameController =
    TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar talla'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nuevo nombre del talla'),
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
                _editTalla(id, newName);
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
        title: const Center(child: Text('Tallas')),
      ),
      body: _tallas.isEmpty
          ? const Center(child: Text('No hay tallas disponibles.'))
          : ListView.builder(
        itemCount: _tallas.length,
        itemBuilder: (context, index) {
          final talla = _tallas[index];
          return ListTile(
            title: Text(talla.rango),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () =>
                      _showEditTallaDialog(talla.id!, talla.rango),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTalla(talla.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTallaDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
