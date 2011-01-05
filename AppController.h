/******************************************************************************
 * File: AppController.h
 *
 * Copyright (c) 2008 Marc Easen (mr.easen@gmail.com)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *****************************************************************************/

#ifndef APP_CONTROLLER
#define APP_CONTROLLER 

#import <Cocoa/Cocoa.h>
#import "SudokuSolver.h"
#import "SudokuView.h"

@class SudokuSolver;
@class SudokuView;

@interface AppController : NSObject
{
    // Main Window
	IBOutlet NSToolbarItem *newGridBtn;
    IBOutlet NSToolbarItem *startSolvingBtn;
    IBOutlet SudokuView *sudokuGrid;
    IBOutlet NSWindow *window;
	// Set Up Grid Sheet
	IBOutlet NSWindow *setUpGrid;
	IBOutlet NSButtonCell *setUpGridRadio9x9;
	IBOutlet NSButtonCell *setUpGridRadio16x16;
	// Insert Fixed Value
	IBOutlet NSWindow *insertFixedValue;
	IBOutlet NSButton *insertFixedValueAdd;
	IBOutlet NSFormCell *insertFixedValueSelectedCol;
	IBOutlet NSFormCell *insertFixedValueSelectedRow;
	IBOutlet NSComboBox *insertFixedValueSelectedVal;
	bool setUpSudokuSolver;
	// Timer
	NSTimer *fTimer;
	bool fKillTimer;
	// SudokuSolver
	SudokuSolver *fSudokuSolver;
}
// Main Window
- (IBAction)resetGrid:(id)sender;
- (IBAction)startSolving:(id)sender;
- (IBAction)setUpGridSheetEndOk:(id)sender;
- (IBAction)setUpGridSheetEndCancel:(id)sender;
- (IBAction)insertFixedValueAdd:(id)sender;
- (IBAction)insertFixedValueCancel:(id)sender;

// Class Functions
- (void)createNewGrid;
- (void)sudokuSolverWrapper: (id)sender;
- (void)timerUpdateGrid:(NSTimer*)aTimer;
@property (retain) NSWindow *insertFixedValue;
@property (retain) SudokuView *sudokuGrid;
@property (retain) NSButtonCell *setUpGridRadio16x16;
@property 	bool fKillTimer;
@property (retain) NSButtonCell *setUpGridRadio9x9;
@property (retain) NSToolbarItem *newGridBtn;
@property (retain) NSWindow *window;
@property (retain) SudokuSolver *fSudokuSolver;
@property (retain) NSToolbarItem *startSolvingBtn;
@property (retain) NSFormCell *insertFixedValueSelectedRow;
@property (retain) NSFormCell *insertFixedValueSelectedCol;
@property (retain) NSWindow *setUpGrid;
@property 	bool setUpSudokuSolver;
@property (retain) NSComboBox *insertFixedValueSelectedVal;
@property (retain) NSTimer *fTimer;
@property (retain) NSButton *insertFixedValueAdd;
@end

#endif