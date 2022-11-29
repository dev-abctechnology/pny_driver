import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:camera/camera.dart';

class EntregaNaoRealizada extends StatefulWidget {
  const EntregaNaoRealizada({super.key});

  @override
  State<EntregaNaoRealizada> createState() => _EntregaRealizadaState();
}

class _EntregaRealizadaState extends State<EntregaNaoRealizada> {
  List<CameraDescription> cameras = [];
  CameraController? _cameraController;
  XFile? _imageFile;
  Size? _screenSize;

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      _startCamera();
    } on CameraException catch (e) {
      snackBarError('Error: ${e.code}\nError Message: ${e.description}');
    }
  }

  void snackBarError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error),
      backgroundColor: Colors.red,
    ));
  }

  void _startCamera() {
    if (cameras.isEmpty) {
      snackBarError('No camera found');
    } else {
      _previewCamera(cameras.first);
    }
  }

  FlashMode _flashMode = FlashMode.auto;
  Future<void> _previewCamera(CameraDescription camera) async {
    final CameraController cameraController = CameraController(
      camera,
      ResolutionPreset.ultraHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    cameraController.setFlashMode(_flashMode);

    _cameraController = cameraController;
    _cameraController!.setFlashMode(_flashMode);
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      snackBarError('Error: ${e.code}\nError Message: ${e.description}');
    }

    if (mounted) {
      setState(() {});
    }
  }

  bool? _flashOn = false;

  void _takePicture() async {
    setState(() {
      _captureInProgress = true;
    });
    try {
      final XFile imageFile = await _cameraController!.takePicture();
      setState(() {
        _imageFile = imageFile;
        _flashOn = false;
        _cameraController!.setFlashMode(FlashMode.off);
        _captureInProgress = false;
      });
    } on CameraException catch (e) {
      setState(() {
        _captureInProgress = false;
      });
      snackBarError('Error: ${e.code}\nError Message: ${e.description}');
    }
  }

  bool _captureInProgress = false;
  _cameraPreviewWidget() {
    return Container(
      color: Colors.grey[900],
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[900],
              child: _cameraController == null
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : CameraPreview(
                      _cameraController!,
                    ),
            ),
          ),
          Container(
            color: Colors.grey[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: _captureInProgress ? null : _takePicture,
                  child: Container(
                    width: 50,
                    height: 50,
                    child: Icon(
                      _captureInProgress ? Icons.timelapse : Icons.camera_alt,
                      color: Colors.white,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _flashOn = !_flashOn!;
                    });
                    _cameraController!.setFlashMode(
                        _flashOn! ? FlashMode.torch : FlashMode.off);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    child: Icon(
                      _flashOn! ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _arquivoWidget() {
    return Container(
        width: _screenSize!.width,
        height: _screenSize!.height,
        child: _imageFile == null ? _cameraPreviewWidget() : _confirmarFoto());
  }

  _confirmarFoto() {
    return Container(
      color: Colors.grey[900],
      alignment: Alignment.center,
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Image.file(
            File(
              _imageFile!.path,
            ),
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context, _imageFile!.path);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _imageFile = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initializeCamera();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _cameraController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    bool _isReady = false;
    return WillPopScope(
      onWillPop: () async {
        if (_imageFile != null) {
          setState(() {
            _imageFile = null;
          });
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('Camera'),
            backgroundColor: Colors.grey[900],
            centerTitle: true,
            elevation: 0,
          ),
          body: _arquivoWidget()),
    );
  }
}
