import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:grid_guide/core/sudoku_detector_async.dart';
import 'package:grid_guide/providers/board_provider_models.dart';
import 'package:grid_guide/providers/progress_indicator_provider.dart';
import 'package:grid_guide/utils/camera_page/check_unvalid_places.dart';
import 'package:path_provider/path_provider.dart';

import '../core/get_boxes.dart';

class CameraProvider with ChangeNotifier {
  void imageCaptureButtonClicked() {
    isImageCaptureButttonClicked = true;
    notifyListeners();
  }

  void solutionButtonClicked() {
    isSolutionButtonClicked = true;
    notifyListeners();
  }

  void detectBoard(
    CameraImage image,
    SudokuDetectorAsync sudokuDetector,
    int camFrameRotation,
    double camFrameToScreenScale,
  ) async {
    _image = image;
    var res = await sudokuDetector.detectBoard(_image, camFrameRotation);
    if (res == null) return;
    bbox = res.map((x) => x * camFrameToScreenScale).toList(growable: false);
    notifyListeners();
  }

  void discardCurrentClickedImage() {
    isImageCaptureButttonClicked = false;
    bbox = List.empty();
    isSnackBarShown = false;
    isSolutionButtonClicked = false;
    isDoneProcessing = false;
    notifyListeners();
  }

  List<BoardCell> _makeBoard(List<int> digits, List<int> unvalidPlaces) {
    var sudokuBoard = List.filled(81, BoardCell(0));
    for (int i = 0; i < 81; i++) {
      if (unvalidPlaces[i] == 1) {
        digits[i] = 0;
      }
      sudokuBoard[i] = BoardCell(digits[i],
          isSolution: false,
          isDigitValid: digits[i] == 0 ? null : true,
          isMarked: false,
          isDetection: true);
    }
    return sudokuBoard;
  }

  Future<List<BoardCell>?> captureBoard(
    SudokuDetectorAsync sudokuDetector,
    BuildContext context,
    ProgressIndicatorProvider progressIndicatorProvider,
  ) async {
    if (bbox.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(getSnackBar("Couldn't detect, Take new picture!!"));
      return null;
    }
    Directory? tempDir = await getExternalStorageDirectory();
    externalStorageDirectory = tempDir!.path;
    sudokuDetector.extractBoxes(externalStorageDirectory);
    List<int> boxDigits =
        await getBoxes(externalStorageDirectory, progressIndicatorProvider);
    List<int> unvalidPlaces = checkUnvalidPlaces(boxDigits);
    var sudokuBoard = _makeBoard(boxDigits, unvalidPlaces);
    progressIndicatorProvider.doneCurrentPrediction();
    isDoneProcessing = true;
    notifyListeners();
    return sudokuBoard;
  }

  List<double> bbox = List.empty();
  bool isImageCaptureButttonClicked = false;
  bool isSnackBarShown = false;
  bool isSolutionButtonClicked = false;
  bool isDoneProcessing = false;
  late String externalStorageDirectory;
  late CameraImage _image;
  void showSnackBarAfterDetection(BuildContext context) {
    isSnackBarShown = true;
    ScaffoldMessenger.of(context).showSnackBar(
      getSnackBar('Take new picture if detection is not correct'),
    );
  }
}

SnackBar getSnackBar(String title) => SnackBar(
      content: Text(title),
      duration: const Duration(seconds: 5),
    );
