import 'package:file_picker/file_picker.dart';

class PickerService {
  Future<String?> pickDirectory({String? dialogTitle}) async {
    return await FilePicker.platform.getDirectoryPath(
      dialogTitle: dialogTitle,
    );
  }
}
