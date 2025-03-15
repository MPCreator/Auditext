import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../models/auditoria/imagen_empaque.dart';
import '../../../models/auditoria/imagen_visual.dart';
import '../../../models/auditoria/imagen_medida.dart';

import '../../../providers/auditoria/imagen_empaque_provider.dart';
import '../../../providers/auditoria/imagen_visual_provider.dart';
import '../../../providers/auditoria/imagen_medida_provider.dart';

class ImagenesSection extends StatefulWidget {
  final int elementoId;

  const ImagenesSection({Key? key, required this.elementoId}) : super(key: key);

  @override
  _ImagenesSectionState createState() => _ImagenesSectionState();
}

class _ImagenesSectionState extends State<ImagenesSection> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _selectImage(BuildContext context, bool fromCamera, String tipo) async {
    try {
      final XFile? pickedFile = await (fromCamera
          ? _picker.pickImage(source: ImageSource.camera)
          : _picker.pickImage(source: ImageSource.gallery));
      if (pickedFile != null) {
        final String imagePath = pickedFile.path;
        if (tipo == 'Empaque') {
          final provider = Provider.of<ImagenEmpaqueProvider>(context, listen: false);
          int count = provider.ImagenEmpaques.where((img) => img.elementoId == widget.elementoId).length;
          final defaultTitle = "Imagen ${count + 1}";
          final newImage = ImagenEmpaque(
              elementoId: widget.elementoId,
              imagen: imagePath,
              titulo: defaultTitle);
          await provider.addImagenEmpaque(newImage);
        } else if (tipo == 'Visual') {
          final provider = Provider.of<ImagenVisualProvider>(context, listen: false);
          int count = provider.ImagenVisuals.where((img) => img.elementoId == widget.elementoId).length;
          final defaultTitle = "Imagen ${count + 1}";
          final newImage = ImagenVisual(
              elementoId: widget.elementoId,
              imagen: imagePath,
              titulo: defaultTitle);
          await provider.addImagenVisual(newImage);
        } else if (tipo == 'Medida') {
          final provider = Provider.of<ImagenMedidaProvider>(context, listen: false);
          int count = provider.ImagenMedidas.where((img) => img.elementoId == widget.elementoId).length;
          final defaultTitle = "Imagen ${count + 1}";
          final newImage = ImagenMedida(
              elementoId: widget.elementoId,
              imagen: imagePath,
              titulo: defaultTitle);
          await provider.addImagenMedida(newImage);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al seleccionar imagen')),
      );
    }
  }

  // Diálogo para editar el título
  Future<String?> _showEditTitleDialog(BuildContext context, String currentTitle) {
    final TextEditingController controller = TextEditingController(text: currentTitle);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar título"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: "Título"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmpaqueSection() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Imágenes de Empaque",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera),
                  label: const Text("Tomar Foto"),
                  onPressed: () async {
                    await _selectImage(context, true, 'Empaque');
                    setState(() {}); // refrescar la vista
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo),
                  label: const Text("Subir Imagen"),
                  onPressed: () async {
                    await _selectImage(context, false, 'Empaque');
                    setState(() {});
                  },
                ),
              ],
            ),
            FutureBuilder<List<ImagenEmpaque>>(
              future: Provider.of<ImagenEmpaqueProvider>(context, listen: false)
                  .fetchImagenEmpaqueByElementoId(widget.elementoId)
                  .then((_) => Provider.of<ImagenEmpaqueProvider>(context, listen: false)
                  .ImagenEmpaques
                  .where((img) => img.elementoId == widget.elementoId)
                  .toList()),
              builder: (context, AsyncSnapshot<List<ImagenEmpaque>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                final images = snapshot.data ?? [];
                if (images.isEmpty) {
                  return const Center(child: Text("No hay imágenes cargadas"));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final imagen = images[index];
                    return Card(
                      child: ListTile(
                        leading: Image.file(File(imagen.imagen)),
                        title: Row(
                          children: [
                            Expanded(child: Text(imagen.titulo ?? "Imagen ${index + 1}")),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final newTitle = await _showEditTitleDialog(context, imagen.titulo ?? "Imagen ${index + 1}");
                                if (newTitle != null && newTitle.trim().isNotEmpty && newTitle != imagen.titulo) {
                                  imagen.titulo = newTitle;
                                  await Provider.of<ImagenEmpaqueProvider>(context, listen: false).updateImagenEmpaque(imagen);
                                  setState(() {});
                                }
                              },
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await Provider.of<ImagenEmpaqueProvider>(context, listen: false)
                                .deleteImagenEmpaque(imagen.id!);
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualSection() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Imágenes Visuales",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera),
                  label: const Text("Tomar Foto"),
                  onPressed: () async {
                    await _selectImage(context, true, 'Visual');
                    setState(() {});
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo),
                  label: const Text("Subir Imagen"),
                  onPressed: () async {
                    await _selectImage(context, false, 'Visual');
                    setState(() {});
                  },
                ),
              ],
            ),
            FutureBuilder<List<ImagenVisual>>(
              future: Provider.of<ImagenVisualProvider>(context, listen: false)
                  .fetchImagenVisualByElementoId(widget.elementoId)
                  .then((_) => Provider.of<ImagenVisualProvider>(context, listen: false)
                  .ImagenVisuals
                  .where((img) => img.elementoId == widget.elementoId)
                  .toList()),
              builder: (context, AsyncSnapshot<List<ImagenVisual>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                final images = snapshot.data ?? [];
                if (images.isEmpty) {
                  return const Center(child: Text("No hay imágenes cargadas"));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final imagen = images[index];
                    return Card(
                      child: ListTile(
                        leading: Image.file(File(imagen.imagen)),
                        title: Row(
                          children: [
                            Expanded(child: Text(imagen.titulo ?? "Imagen ${index + 1}")),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final newTitle = await _showEditTitleDialog(context, imagen.titulo ?? "Imagen ${index + 1}");
                                if (newTitle != null && newTitle.trim().isNotEmpty && newTitle != imagen.titulo) {
                                  imagen.titulo = newTitle;
                                  await Provider.of<ImagenVisualProvider>(context, listen: false).updateImagenVisual(imagen);
                                  setState(() {});
                                }
                              },
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await Provider.of<ImagenVisualProvider>(context, listen: false)
                                .deleteImagenVisual(imagen.id!);
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedidaSection() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Imágenes de Medida",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera),
                  label: const Text("Tomar Foto"),
                  onPressed: () async {
                    await _selectImage(context, true, 'Medida');
                    setState(() {});
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo),
                  label: const Text("Subir Imagen"),
                  onPressed: () async {
                    await _selectImage(context, false, 'Medida');
                    setState(() {});
                  },
                ),
              ],
            ),
            FutureBuilder<List<ImagenMedida>>(
              future: Provider.of<ImagenMedidaProvider>(context, listen: false)
                  .fetchImagenMedidaByElementoId(widget.elementoId)
                  .then((_) => Provider.of<ImagenMedidaProvider>(context, listen: false)
                  .ImagenMedidas
                  .where((img) => img.elementoId == widget.elementoId)
                  .toList()),
              builder: (context, AsyncSnapshot<List<ImagenMedida>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                final images = snapshot.data ?? [];
                if (images.isEmpty) {
                  return const Center(child: Text("No hay imágenes cargadas"));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final imagen = images[index];
                    return Card(
                      child: ListTile(
                        leading: Image.file(File(imagen.imagen)),
                        title: Row(
                          children: [
                            Expanded(child: Text(imagen.titulo ?? "Imagen ${index + 1}")),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final newTitle = await _showEditTitleDialog(context, imagen.titulo ?? "Imagen ${index + 1}");
                                if (newTitle != null && newTitle.trim().isNotEmpty && newTitle != imagen.titulo) {
                                  imagen.titulo = newTitle;
                                  await Provider.of<ImagenMedidaProvider>(context, listen: false).updateImagenMedida(imagen);
                                  setState(() {});
                                }
                              },
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await Provider.of<ImagenMedidaProvider>(context, listen: false)
                                .deleteImagenMedida(imagen.id!);
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildEmpaqueSection(),
          _buildVisualSection(),
          _buildMedidaSection(),
        ],
      ),
    );
  }
}
