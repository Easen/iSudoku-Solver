 /******************************************************************************
 * File: SudokuSolver.h
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
 
#ifndef SUDOKU_SOLVER
#define SUDOKU_SOLVER 

#import <Cocoa/Cocoa.h>

// Data Structure
typedef struct _SSCell{
	int row;
	int col;
	int value;
	bool isFixedValue;
	int *possibleValues;
	int numberOfPossibleValues;
	int innerGridID;
	struct _SSCell *nextCell;
	struct _SSCell *prevCell;
	struct _SSCell *nextRow;
	struct _SSCell *nextCol;
	struct _SSCell *nextInnerCell;
}SSCell;

// Consts
enum SSErrors {OK, OUTOFBOUNDS, INVALIDVALUE, FIXEDVALUE,
			  SS_RESET, SS_COMPLETED, SS_CANNOT_COMPLETE};

@interface SudokuSolver : NSObject
{
	SSCell *allHead;
	SSCell *allRear;
	SSCell **headRow;
	SSCell **headCol;
	SSCell **headInnerGrid;
	// Cell Array
	SSCell **mainStorage;
	// Values
	int numberOfRows;
	int numberOfCols;
	int numberOfInnerRows;
	int numberOfInnerCols;
	int sudokuFinishValue;	
}
// Functions
- (id) init;
- (id) initWithNumberOfRows: (int) rows 
			  NumberOfColumns: (int) cols 
			NumberOfInnerRows: (int) innerRows
		 NumberOfInnerColumns: (int) innerCols;
- (void) dealloc;
- (void) resetGrid;
- (SSCell*) getCellForRow:(int) row
				   Column: (int) col;
- (int) insertValueForCellForRow: (int) row
						  Column: (int) col
						   Value: (int) value
				   IsAFixedValue: (bool) fixedValue;
- (int) insertFixedValueForRow: (int) row
						Column: (int) col
						 Value: (int) value;
- (int) insertValueForRow: (int) row
				   Column: (int) col
					Value: (int) value;
- (void) solve;
- (int) startAtRow: (int) row
			Column: (int) col;
- (void) getPossibleValuesForCell: (SSCell*) currentCell;
- (int) insertCellCheckForRow: (int) row
					   Column: (int) col
					    Value: (int) value;

// Accessors
@property int numberOfRows;
@property int numberOfCols;
@property int numberOfInnerRows;
@property int numberOfInnerCols;
@property(readonly) int sudokuFinishValue;  
@end

#endif