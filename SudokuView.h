/******************************************************************************
 * File: SudokuView.h
 *
 * Copyright (c) 2008 Marc Easen (marc@easen.co.uk)
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

#ifndef SUDOKU_VIEW
#define SUDOKU_VIEW 

#import <Cocoa/Cocoa.h>
#import "SudokuSolver.h"

@class SudokuSolver;

@interface SudokuView : NSView
{
	NSBezierPath *gridLines;
	NSBezierPath *innerGridLines;
	// Attribute for outputting text
	NSMutableDictionary *outputTextAttributes;
	// An array to show what text to show
	NSMutableArray *arrayOfOutputText;
	// Internal Int's
	int gridVSize;
	int gridHSize;
	int innerGridVSize;
	int innerGridHSize;
	int borderSize;
	int xOffSet, yOffSet;
	int sizeOfGrid;
	
	SudokuSolver *sudokuSolverObj;
}
//Functions
- (void)drawRect:(NSRect)rect;
- (void)drawText;
- (void)setUpGrid;
// Accessors
/* New Objc 2.0 */
@property(assign) SudokuSolver *sudokuSolverObj;
/* Old Objc 1.0*/
- (void)setGridVSize:(int)aGridVSize;
- (int)gridVSize;
- (void)setGridHSize:(int)aGridHSize;
- (int)gridHSize;
- (void)setInnerGridHSize:(int)aInnerGridHSize;
- (int)innerGridHSize;
- (void)setInnerGridVSize:(int)aInnerGridVSize;
- (int)innerGridVSize;
- (void)setBorderSize:(int)aBorderSize;
- (int)borderSize;
@property (getter=innerGridVSize,setter=setInnerGridVSize:) int innerGridVSize;
@property (getter=gridVSize,setter=setGridVSize:) int gridVSize;
@property int sizeOfGrid;
@property (retain) NSBezierPath *innerGridLines;
@property (retain) NSMutableArray *arrayOfOutputText;
@property (retain) NSBezierPath *gridLines;
@property (getter=innerGridHSize,setter=setInnerGridHSize:) int innerGridHSize;
@property (getter=gridHSize,setter=setGridHSize:) int gridHSize;
@property (getter=borderSize,setter=setBorderSize:) int borderSize;
@property (retain) NSMutableDictionary *outputTextAttributes;
@end

#endif
