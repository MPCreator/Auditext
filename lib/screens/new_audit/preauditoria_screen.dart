import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/auditoria/auditoria.dart';
import '../../providers/auditoria/auditoria_provider.dart';
import '../../utils/routes/route_names.dart';

class PreAuditoriaScreen extends StatefulWidget {
  final int auditoriaId;

  const PreAuditoriaScreen({super.key, required this.auditoriaId});

  @override
  State<PreAuditoriaScreen> createState() => _PreAuditoriaScreenState();
}

class _PreAuditoriaScreenState extends State<PreAuditoriaScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _proveedorController;
  late TextEditingController _paisOrigenController;
  late TextEditingController _paisDestinoController;
  late TextEditingController _marcaController;
  late TextEditingController _fechaEntregaController;
  late TextEditingController _fechaAuditoriaController;
  late TextEditingController _auditoraController;
  late TextEditingController _poController;
  late TextEditingController _subgrupoController;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores vacíos
    _proveedorController = TextEditingController();
    _paisOrigenController = TextEditingController();
    _paisDestinoController = TextEditingController();
    _marcaController = TextEditingController();
    _fechaEntregaController = TextEditingController();
    _fechaAuditoriaController = TextEditingController();
    _auditoraController = TextEditingController();
    _poController = TextEditingController();
    _subgrupoController = TextEditingController();

    // Cargar datos de la auditoría al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AuditoriaProvider>(context, listen: false);
      final auditoria = provider.auditorias.firstWhere(
            (a) => a.id == widget.auditoriaId,
        orElse: () => Auditoria(proveedor: '', paisOrigen: '', paisDestino: '', marca: '', fechaEntrega: '', fechaAuditoria: '', auditora: '', po: '', subgrupo: '', resultado: ''),
      );

      if (auditoria.id != null) {
        _proveedorController.text = auditoria.proveedor;
        _paisOrigenController.text = auditoria.paisOrigen;
        _paisDestinoController.text = auditoria.paisDestino;
        _marcaController.text = auditoria.marca;
        _fechaEntregaController.text = auditoria.fechaEntrega;
        _fechaAuditoriaController.text = auditoria.fechaAuditoria;
        _auditoraController.text = auditoria.auditora;
        _poController.text = auditoria.po;
        _subgrupoController.text = auditoria.subgrupo;
      }
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      controller.text = formattedDate;
    }
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuditoriaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preauditoría'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Proveedor', _proveedorController),
              _buildTextField('País de Origen', _paisOrigenController),
              _buildTextField('País de Destino', _paisDestinoController),
              _buildTextField('Marca', _marcaController),
              _buildTextField('Fecha de Entrega', _fechaEntregaController, hint: 'YYYY-MM-DD', isDateField: true),
              _buildTextField('Fecha de Auditoría', _fechaAuditoriaController, hint: 'YYYY-MM-DD', isDateField: true),
              _buildTextField('Auditora', _auditoraController),
              _buildTextField('PO', _poController),
              _buildTextField('Subgrupo', _subgrupoController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _submitForm(provider),
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint, bool isDateField = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: isDateField
            ? () => _selectDate(context, controller)
            : null,
        child: AbsorbPointer(
          absorbing: isDateField,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es obligatorio';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }


  void _submitForm(AuditoriaProvider provider) {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedAuditoria = Auditoria(
        id: widget.auditoriaId,
        proveedor: _proveedorController.text,
        paisOrigen: _paisOrigenController.text,
        paisDestino: _paisDestinoController.text,
        marca: _marcaController.text,
        fechaEntrega: _fechaEntregaController.text,
        fechaAuditoria: _fechaAuditoriaController.text,
        auditora: _auditoraController.text,
        po: _poController.text,
        subgrupo: _subgrupoController.text,
        resultado: "Sin Auditar",
      );


      provider.updateAuditoria(updatedAuditoria).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Información actualizada con éxito')),
        );
        print("----------------");

        print('Información actualizada con éxito');
        print("auditoria id: ${updatedAuditoria.id}");
        Navigator.of(context).pushNamed(RouteNames.home);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar la información')),
        );
      });



    }
  }

  @override
  void dispose() {
    _proveedorController.dispose();
    _paisOrigenController.dispose();
    _paisDestinoController.dispose();
    _marcaController.dispose();
    _fechaEntregaController.dispose();
    _fechaAuditoriaController.dispose();
    _auditoraController.dispose();
    _poController.dispose();
    _subgrupoController.dispose();
    super.dispose();
  }
}
