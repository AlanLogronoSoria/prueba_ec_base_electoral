import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/image_quality_checker.dart';
import '../bloc/veedor_bloc.dart';
import '../bloc/veedor_event.dart';
import '../bloc/veedor_state.dart';
import 'package:image_picker/image_picker.dart';

class FotoActaPage extends StatefulWidget {
  final String actaId;

  const FotoActaPage({super.key, required this.actaId});

  @override
  State<FotoActaPage> createState() => _FotoActaPageState();
}

class _FotoActaPageState extends State<FotoActaPage> {
  File? _imageFile;
  bool _isChecking = false;

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
    );

    if (photo == null) return;

    setState(() => _isChecking = true);

    final file = File(photo.path);
    final isSharp = await ImageQualityChecker.isSharp(file);

    setState(() => _isChecking = false);

    if (!isSharp) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Foto Borrosa'),
            content: const Text(
              'La foto no tiene la nitidez suficiente. '
              'Por favor, toma otra foto con mejor enfoque.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
      return;
    }

    setState(() => _imageFile = file);
  }

  void _subirFoto() {
    if (_imageFile == null) return;
    context.read<VeedorBloc>().add(
          SubirFotoActa(
            filePath: _imageFile!.path,
            actaId: widget.actaId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foto del Acta')),
      body: BlocConsumer<VeedorBloc, VeedorState>(
        listener: (context, state) {
          if (state is FotoSubida) {
            if (state.fotoUrl.startsWith('local:')) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Foto guardada localmente — se subirá al sincronizar',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Foto subida exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          if (state is VeedorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Toma una foto del acta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'La foto debe ser nítida y legible.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    if (_imageFile != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Presiona para tomar foto',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (_isChecking)
                      const Center(child: CircularProgressIndicator())
                    else if (_imageFile == null)
                      FilledButton.icon(
                        onPressed: _tomarFoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Tomar Foto'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton.icon(
                            onPressed: _subirFoto,
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('Subir Foto'),
                            style: FilledButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _tomarFoto,
                            child: const Text('Tomar otra foto'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (state is VeedorLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
