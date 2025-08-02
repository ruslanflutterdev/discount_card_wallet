import 'dart:io';
import 'package:discount_card_wallet/providers/supabase_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/discount_card_model.dart';
import '../providers/discount_cards_provider.dart';
import '../widgets/image_preview.dart';

class AddCardScreen extends ConsumerStatefulWidget {
  final DiscountCardModel? cardToEdit;

  const AddCardScreen({super.key, this.cardToEdit});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _storeNameController;
  late final TextEditingController _notesController;

  File? _storeLogoFile;
  File? _frontImageFile;
  File? _backImageFile;

  String? _storeLogoUrl;
  String? _frontImageUrl;
  String? _backImageUrl;

  bool _isLoading = false;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController(
      text: widget.cardToEdit?.storeName,
    );
    _notesController = TextEditingController(text: widget.cardToEdit?.notes);

    _storeLogoUrl = widget.cardToEdit?.storeLogoUrl;
    _frontImageUrl = widget.cardToEdit?.frontImageUrl;
    _backImageUrl = widget.cardToEdit?.backImageUrl;
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
      final fileName = '${const Uuid().v4()}_${file.path.split('/').last}';
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

  Future<void> _deleteOldImage(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      final supabase = ref.read(supabaseProvider);
      final path = url.split('user_uploads/')[1];
      await supabase.storage.from('cards').remove(['user_uploads/$path']);
    } on Exception catch (e) {
      debugPrint('Ошибка удаления файла: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_frontImageFile == null && _frontImageUrl == null) {
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
      final logoUrl = _storeLogoFile != null
          ? await _uploadFile(label: 'логотип магазина', file: _storeLogoFile)
          : _storeLogoUrl;
      final frontUrl = _frontImageFile != null
          ? await _uploadFile(label: 'лицевая сторона', file: _frontImageFile)
          : _frontImageUrl;
      final backUrl = _backImageFile != null
          ? await _uploadFile(label: 'обратная сторона', file: _backImageFile)
          : _backImageUrl;

      if (frontUrl == null) {
        return;
      }

      if (_storeLogoFile != null && _storeLogoUrl != null) {
        await _deleteOldImage(_storeLogoUrl);
      }
      if (_frontImageFile != null && _frontImageUrl != null) {
        await _deleteOldImage(_frontImageUrl);
      }
      if (_backImageFile != null && _backImageUrl != null) {
        await _deleteOldImage(_backImageUrl);
      }
      final supabase = ref.read(supabaseProvider);
      final data = {
        'store_name': _storeNameController.text,
        'store_logo_url': logoUrl ?? '',
        'front_image_url': frontUrl,
        'back_image_url': backUrl ?? '',
        'notes': _notesController.text,
      };

      if (widget.cardToEdit == null) {
        await supabase.from('discount_cards').insert(data);
      } else {
        await supabase
            .from('discount_cards')
            .update(data)
            .eq('id', widget.cardToEdit!.id);
      }

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
    final isEditing = widget.cardToEdit != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактировать карту' : 'Создать карту'),
      ),
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
                file: _storeLogoFile,
                imageUrl: _storeLogoUrl,
                label: 'Логотип магазина (можно пропустить)',
                onClear: () => setState(() {
                  _storeLogoFile = null;
                  _storeLogoUrl = null;
                }),
              ),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _pickImage(
                        ImageSource.gallery,
                        (f) => setState(() => _storeLogoFile = f),
                      ),
                child: Text('Выбрать логотип из галереи'),
              ),
              SizedBox(height: 16),

              ImagePreview(
                file: _frontImageFile,
                imageUrl: _frontImageUrl,
                label: 'Лицевая сторона карты *',
                onClear: () => setState(() {
                  _frontImageFile = null;
                  _frontImageUrl = null;
                }),
              ),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _pickImage(
                        ImageSource.camera,
                        (f) => setState(() => _frontImageFile = f),
                      ),
                child: Text('Сфотографировать лицевую'),
              ),
              SizedBox(height: 16),

              ImagePreview(
                file: _backImageFile,
                imageUrl: _backImageUrl,
                label: 'Обратная сторона (можно пропустить)',
                onClear: () => setState(() {
                  _backImageFile = null;
                  _backImageUrl = null;
                }),
              ),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _pickImage(
                        ImageSource.camera,
                        (f) => setState(() => _backImageFile = f),
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
