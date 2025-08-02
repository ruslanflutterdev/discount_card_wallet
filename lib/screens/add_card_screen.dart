import 'dart:io';
import 'package:discount_card_wallet/providers/supabase_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../providers/discount_cards_provider.dart';
import '../widgets/image_preview.dart';

class AddCardScreen extends ConsumerStatefulWidget {
  const AddCardScreen({super.key});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _storeNameController;
  late final TextEditingController _notesController;

  File? _storeLogo;
  File? _frontImage;
  File? _backImage;

  bool _isLoading = false;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, Function(File?) setter) async {
    try {
      final picked = await _picker.pickImage(source: source);
      if (picked != null) {
        setState(() {
          setter(File(picked.path));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка выбора изображения: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _uploadFile({
    required String label,
    required File? file,
  }) async {
    if (file == null) return null;

    try {
      final supabase = ref.read(supabaseProvider);
      final fileName = '${Uuid().v4()}_${file.path.split('/').last}';
      final fullPath = 'user_uploads/$fileName';

      await supabase.storage.from('cards').upload(fullPath, file);
      final publicUrl = supabase.storage.from('cards').getPublicUrl(fullPath);

      return publicUrl;
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка загрузки "$label": $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_frontImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Лицевая сторона карты обязательна'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final logoUrl = await _uploadFile(
        label: 'логотип магазина',
        file: _storeLogo,
      );
      final frontUrl = await _uploadFile(
        label: 'лицевая сторона',
        file: _frontImage,
      );

      if (frontUrl == null) {
        return;
      }

      final backUrl = await _uploadFile(
        label: 'обратная сторона',
        file: _backImage,
      );

      final supabase = ref.read(supabaseProvider);
      await supabase.from('discount_cards').insert({
        'store_name': _storeNameController.text,
        'store_logo_url': logoUrl ?? '',
        'front_image_url': frontUrl,
        'back_image_url': backUrl ?? '',
        'notes': _notesController.text,
      });

      if (!mounted) return;

      ref.invalidate(discountCardsProvider);

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при сохранении данных: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Создать карту')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _storeNameController,
                decoration: InputDecoration(labelText: 'Название магазина *'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Введите название' : null,
              ),
              SizedBox(height: 16),

              ImagePreview(
                file: _storeLogo,
                label: 'Логотип магазина (можно пропустить)',
                onClear: () => setState(() => _storeLogo = null),
              ),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _pickImage(
                        ImageSource.gallery,
                        (f) => setState(() => _storeLogo = f),
                      ),
                child: Text('Выбрать логотип из галереи'),
              ),
              SizedBox(height: 16),

              ImagePreview(
                file: _frontImage,
                label: 'Лицевая сторона карты *',
                onClear: () => setState(() => _frontImage = null),
              ),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _pickImage(
                        ImageSource.camera,
                        (f) => setState(() => _frontImage = f),
                      ),
                child: Text('Сфотографировать лицевую'),
              ),
              SizedBox(height: 16),

              ImagePreview(
                file: _backImage,
                label: 'Обратная сторона (можно пропустить)',
                onClear: () => setState(() => _backImage = null),
              ),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _pickImage(
                        ImageSource.camera,
                        (f) => setState(() => _backImage = f),
                      ),
                child: Text('Сфотографировать обратную'),
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: 'Заметки'),
                maxLines: 3,
              ),
              SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
