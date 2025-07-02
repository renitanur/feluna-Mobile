// test/widgets/custom_text_field_unit_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TextEditingController should update text', () {
    final TextEditingController controller = TextEditingController();
    controller.text = 'initial text';

    // Verifikasi bahwa controller sudah diinisialisasi dengan benar
    expect(controller.text, 'initial text');

    // Ubah nilai teks pada controller
    controller.text = 'updated text';

    // Verifikasi bahwa nilai controller telah diperbarui
    expect(controller.text, 'updated text');
  });
}
