import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/widgets/keyboard_visibility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///
class DrishyaEditor extends StatefulWidget {
  ///
  const DrishyaEditor({
    Key? key,
    this.controller,
    this.hideOverlay = false,
  }) : super(key: key);

  ///
  final DrishyaEditingController? controller;

  ///
  final bool hideOverlay;

  /// Open drishya editor
  static Future<DrishyaEntity?> open(
    BuildContext context, {
    DrishyaEditingController? controller,
    bool hideOverlay = false,
  }) async {
    return Navigator.of(context).push<DrishyaEntity>(
      SlideTransitionPageRoute(
        builder: DrishyaEditor(
          controller: controller,
          hideOverlay: hideOverlay,
        ),
      ),
    );
  }

  @override
  State<DrishyaEditor> createState() => _DrishyaEditorState();
}

class _DrishyaEditorState extends State<DrishyaEditor> {
  late DrishyaEditingController _controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _controller = widget.controller ?? DrishyaEditingController();
  }

  // @override
  // void didUpdateWidget(covariant DrishyaEditor oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.controller != widget.controller) {
  //     _controller.dispose();
  //     _controller = widget.controller ?? DrishyaEditingController();
  //   }
  // }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        return true;
      },
      child: KeyboardVisibility(
        listener: (visible) {
          if (!visible) {
            FocusScope.of(context).unfocus();
            _controller.updateValue(
              hasFocus: false,
              isColorPickerVisible: false,
            );
          }
        },
        builder: (context, visible, child) => child!,
        child: Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          body: PhotoEditingControllerProvider(
            controller: _controller,
            child: ValueListenableBuilder<EditorValue>(
              valueListenable: _controller,
              builder: (context, value, child) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Captureable view that shows the background and stickers
                    RepaintBoundary(
                      key: _controller.editorKey,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Playground background
                          (value.background ??
                                  _controller.setting.backgrounds.first)
                              .build(context),

                          // Stickers
                          Opacity(
                            opacity: value.isStickerPickerOpen ? 0.0 : 1.0,
                            child: StickersView(controller: _controller),
                          ),

                          //
                        ],
                      ),
                    ),

                    // Textfield
                    if (value.hasFocus)
                      EditorTextfield(controller: _controller),

                    // Overlay
                    if (!widget.hideOverlay)
                      EditorOverlay(controller: _controller),

                    // Color picker
                    if (((value.hasFocus &&
                                value.background is! GradientBackground) ||
                            value.isColorPickerVisible) &&
                        !value.isEditing)
                      ColorPicker(controller: _controller),

                    //
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
