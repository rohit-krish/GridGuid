import 'package:flutter/material.dart';
import 'package:grid_guid/utils/get_corresponding_element_utils.dart';
import 'package:grid_guid/widgets/sudoku_play_page/sudoku_board_widget.dart';
import 'package:provider/provider.dart';

import '../providers/board_provider.dart';
import '../widgets/sudoku_play_page/digit_input_button.dart';
import '../utils/alert_dialog_sudoku_play_page.dart';

class SudokuPlay extends StatefulWidget {
  const SudokuPlay({super.key});

  @override
  State<SudokuPlay> createState() => _SudokuPlayState();
}

class _SudokuPlayState extends State<SudokuPlay> {
  int currentPressedCount = -1;

  int getCurrentPressedCount() {
    return currentPressedCount;
  }

  updateCurrentPressedCount(int newVal) {
    currentPressedCount = newVal;
  }

  updateBoard(String value, BoardProvider boardProvider) {
    bool isBoardCompletelySolvedbyUser = boardProvider.updateBoard(
      value,
      getCorrespondingIndex(currentPressedCount),
    );
    print(isBoardCompletelySolvedbyUser);

  }


  @override
  Widget build(BuildContext context) {
    var boardProvider = Provider.of<BoardProvider>(context, listen: false);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.all(width * .05),
      height: double.maxFinite,
      width: double.maxFinite,
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          const Spacer(),
          SudokuBoardWidget(getCurrentPressedCount, updateCurrentPressedCount),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  boardProvider.getSolutions;
                },
                icon: const Icon(Icons.auto_fix_high_outlined),
              ),
              SizedBox(width: width * .07),
              IconButton(
                onPressed: () {
                  showAlertDialogForRefreshingBoard(boardProvider, context);
                },
                icon: const Icon(Icons.refresh),
              )
            ],
          ),
          const Spacer(),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DigitInputButton('1', () => updateBoard('1', boardProvider)),
                  DigitInputButton('2', () => updateBoard('2', boardProvider)),
                  DigitInputButton('3', () => updateBoard('3', boardProvider)),
                  DigitInputButton('4', () => updateBoard('4', boardProvider)),
                  DigitInputButton('5', () => updateBoard('5', boardProvider)),
                ],
              ),
              SizedBox(height: height * .02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DigitInputButton('6', () => updateBoard('6', boardProvider)),
                  DigitInputButton('7', () => updateBoard('7', boardProvider)),
                  DigitInputButton('8', () => updateBoard('8', boardProvider)),
                  DigitInputButton('9', () => updateBoard('9', boardProvider)),
                  DigitInputButton('X', () => updateBoard('X', boardProvider)),
                ],
              ),
            ],
          ),
          const Spacer()
        ],
      ),
    );
  }
}
