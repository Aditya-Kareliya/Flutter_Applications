import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/qr_code_model.dart';
import '../data/repositories/qr_repository.dart';

class QRProvider extends ChangeNotifier {
  final QRRepository _repository = QRRepository();

  // Controllers
  final nameController = TextEditingController();
  final contentController = TextEditingController();
  
  // Validation State
  bool _isNameValid = true;
  bool _isContentValid = true;

  bool get isNameValid => _isNameValid;
  bool get isContentValid => _isContentValid;

  QRProvider() {
    nameController.addListener(_resetNameValidation);
    contentController.addListener(_resetContentValidation);
  }

  void _resetNameValidation() {
    if (!_isNameValid && nameController.text.isNotEmpty) {
      _isNameValid = true;
      notifyListeners();
    }
  }

  void _resetContentValidation() {
    if (!_isContentValid && contentController.text.isNotEmpty) {
      _isContentValid = true;
      notifyListeners();
    }
  }

  // State
  List<QRCodeModel> _qrCodes = [];
  QRCodeModel? activeQR;
  QRCodeDesign _currentDesign = const QRCodeDesign();
  QRType selectedType = QRType.url;

  // Undo / Redo
  final _undoStack = ListQueue<QRCodeDesign>();
  final _redoStack = ListQueue<QRCodeDesign>();

  QRCodeDesign get currentDesign => _currentDesign;

  List<QRCodeModel> get qrCodes => _qrCodes;
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String value) {
    _searchQuery = value.trim().toLowerCase();
    notifyListeners();
  }

  List<QRCodeModel> get filteredQRCodes {
    if (_searchQuery.isEmpty) return _qrCodes;

    return _qrCodes.where((qr) {
      return qr.name.toLowerCase().contains(_searchQuery) || qr.contentData.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  // ---------------- Active QR ----------------
  void setActiveQR(QRCodeModel? qr) {
    initializeEditor(qr: qr);
  }

  // ---------------- Selection ----------------
  final Set<String> _selectedIds = {};

  bool get isSelectionMode => _selectedIds.isNotEmpty;

  int get selectedCount => _selectedIds.length;

  bool isSelected(String id) => _selectedIds.contains(id);

  void toggleSelection(String id) {
    _selectedIds.contains(id) ? _selectedIds.remove(id) : _selectedIds.add(id);
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    final ids = [..._selectedIds];
    clearSelection();
    for (final id in ids) {
      await deleteQR(id);
    }
  }

  // ---------------- CRUD ----------------
  Future<void> createQR(String name, QRType type, String content) async {
    final qr = QRCodeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      contentData: content,
      design: _currentDesign,
      createdDate: DateTime.now(),
    );

    _qrCodes.add(qr);
    notifyListeners();

    final created = await _repository.createQRCode(qr);
    _qrCodes[_qrCodes.length - 1] = created;
    notifyListeners();
  }

  Future<void> updateQR(QRCodeModel updated) async {
    final index = _qrCodes.indexWhere((e) => e.id == updated.id);
    if (index == -1) return;

    _qrCodes[index] = updated.copyWith(design: _currentDesign);
    notifyListeners();
    await _repository.updateQRCode(updated);
  }

  Future<void> deleteQR(String id) async {
    _qrCodes.removeWhere((e) => e.id == id);
    notifyListeners();
    await _repository.deleteQRCode(id);
  }

  Future<void> fetchQRCodes() async {
    _qrCodes = await _repository.getAllQRCodes();
    _searchQuery = '';
    notifyListeners();
  }

  // ---------------- Editor ----------------
  void initializeEditor({QRCodeModel? qr}) {
    activeQR = qr;

    nameController.text = qr?.name ?? '';
    contentController.text = qr?.contentData ?? '';
    selectedType = qr?.type ?? QRType.url;

    _currentDesign = qr?.design ?? const QRCodeDesign();

    _undoStack.clear();
    _redoStack.clear();
    notifyListeners();
  }

  void setSelectedType(QRType type) {
    selectedType = type;
    notifyListeners();
  }

  void updateDesign(QRCodeDesign design) {
    if (design == _currentDesign) return;
    _undoStack.addLast(_currentDesign);
    _redoStack.clear();
    _currentDesign = design;
    notifyListeners();
  }

  bool validate() {
    _isNameValid = nameController.text.trim().isNotEmpty;
    
    switch (selectedType) {
      case QRType.url:
        final url = contentController.text.trim();
        _isContentValid = url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true;
        break;
      case QRType.text:
      case QRType.pdf:
      case QRType.image:
      case QRType.video:
      default:
        _isContentValid = contentController.text.trim().isNotEmpty;
    }
    
    notifyListeners();
    return _isNameValid && _isContentValid;
  }

  Future<void> pickFileForType(QRType type, {ImageSource source = ImageSource.gallery}) async {
    if (type == QRType.pdf) {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null) {
        contentController.text = result.files.single.name;
        notifyListeners();
      }
    } else if (type == QRType.image) {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source);
      if (image != null) {
        contentController.text = image.name;
        notifyListeners();
      }
    } else if (type == QRType.video) {
        final picker = ImagePicker();
        final video = await picker.pickVideo(source: source);
        if (video != null) {
            contentController.text = video.name;
            notifyListeners();
        }
    }
  }

  @override
  void dispose() {
    nameController.removeListener(_resetNameValidation);
    contentController.removeListener(_resetContentValidation);
    nameController.dispose();
    contentController.dispose();
    super.dispose();
  }
}
