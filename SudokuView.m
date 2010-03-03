/******************************************************************************
 * File: SudokuView.m
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

#import "SudokuView.h"
#import "SudokuSolver.h"

@class SudokuSolver;

@implementation SudokuView
#pragma mark Init & Dealloc

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		[self setGridHSize:0];
		[self setGridVSize:0];
		[self setBorderSize:5];
		outputTextAttributes = [[NSMutableDictionary alloc]  init];
		[outputTextAttributes setObject:[NSFont fontWithName:@"Helvetica"
														size:18]
								 forKey:NSFontAttributeName];
		
		NSMutableParagraphStyle *pS = [[NSParagraphStyle defaultParagraphStyle]mutableCopy];
		[pS setAlignment:NSCenterTextAlignment];
		[outputTextAttributes setObject:pS
								 forKey:NSParagraphStyleAttributeName];
		[outputTextAttributes setObject:[NSColor blackColor]
								 forKey:NSForegroundColorAttributeName];
		arrayOfOutputText = [[NSMutableArray alloc] init];
		
	}
	return self;
}
- (void) dealloc {
	[arrayOfOutputText release];
	[outputTextAttributes release];
	[gridLines release];
	[innerGridLines release];
	[super dealloc];
}

#pragma mark Functions

- (void)drawRect:(NSRect)rect
{
	NSRect bounds = [self bounds];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:bounds];
	if (gridLines){
		[[NSColor blackColor] set];
		[gridLines stroke];
		[innerGridLines stroke];
	}
	[self drawText];	
}

- (void)drawText
{								 	
	if (sudokuSolverObj)
	{
		NSRect r;
		NSRect windowSize = [self bounds];
		SSCell *tempCell;
		int row, col;
		for (row = gridVSize; row > 0; row--){
			for (col = 1; col <= gridHSize; col++){
				NSString *outputStr;
				tempCell = [sudokuSolverObj getCellForRow:row
												 Column:col];
				if(tempCell->value > 0){
					outputStr = [[NSString alloc] initWithFormat:@"%d", tempCell->value];
					
					r.origin.x = xOffSet + 10 + ((windowSize.size.width - 2 * xOffSet - 10) / gridHSize) * (col -1);
					r.origin.y = yOffSet + 10 + ((windowSize.size.height - 2 * yOffSet - 10) / gridVSize) * (((row - (gridVSize + 1)) * - 1)  - 1);
					r.size.width = ((windowSize.size.width - 2 * xOffSet) / gridHSize) - 5;
					r.size.height = ((windowSize.size.height - 2 * yOffSet) / gridVSize) * 0.75;
					
					[outputStr drawInRect:r withAttributes:outputTextAttributes];
					[outputStr release];
				}
			}
		}
	}
	
}

- (void) setUpGrid
{
	NSRect newRect;
	xOffSet = 0;
	yOffSet = 0;
	newRect = [self bounds];
	
	if (newRect.size.width > newRect.size.height){
		xOffSet = (newRect.size.width - newRect.size.height) / 2;
		newRect.size.width = newRect.size.height;
	}
	if (newRect.size.height > newRect.size.width){
		yOffSet = (newRect.size.height - newRect.size.width) / 2;
		newRect.size.height = newRect.size.width;
	}
	
	if (!gridLines)
		gridLines = [[NSBezierPath alloc] init];
	if (!innerGridLines)
		innerGridLines = [[NSBezierPath alloc] init];
	// Set thickness
	[innerGridLines setLineWidth:4.0];
	// Draw the veritcal lines
	[gridLines removeAllPoints];
	[innerGridLines removeAllPoints];
	int i;
	if (gridVSize > 0) {
		for (i = 0; i < gridVSize + 1; i++){
			if (i % innerGridVSize == 0)
			{
				[innerGridLines moveToPoint:NSMakePoint((i * ((newRect.size.width - (borderSize * 2)) / gridVSize) + borderSize) + xOffSet, borderSize + yOffSet)];
				[innerGridLines lineToPoint:NSMakePoint((i * ((newRect.size.width - (borderSize * 2)) / gridVSize) + borderSize) + xOffSet, (newRect.size.height - borderSize) + yOffSet)];
				[innerGridLines closePath];
			}else{
				[gridLines moveToPoint:NSMakePoint((i * ((newRect.size.width - (borderSize * 2)) / gridVSize) + borderSize) + xOffSet, borderSize + yOffSet)];
				[gridLines lineToPoint:NSMakePoint((i * ((newRect.size.width - (borderSize * 2)) / gridVSize) + borderSize) + xOffSet, (newRect.size.height - borderSize) + yOffSet)];
				[gridLines closePath];
			}			 
		}
	}
	//Draw the horizontal lines
	if (gridHSize > 0){
		for (i = 0; i < gridHSize + 1; i++){
			if (i % innerGridHSize == 0)
			{
				[innerGridLines moveToPoint:NSMakePoint(borderSize + xOffSet, (i * ((newRect.size.width - (borderSize * 2)) / gridHSize) + borderSize) + yOffSet)];
				[innerGridLines lineToPoint:NSMakePoint((newRect.size.height - borderSize) + xOffSet, (i * ((newRect.size.width - (borderSize * 2)) / gridHSize) + borderSize) + yOffSet)];
				[innerGridLines closePath];
			}else{			
				[gridLines moveToPoint:NSMakePoint(borderSize + xOffSet, (i * ((newRect.size.width - (borderSize * 2)) / gridHSize) + borderSize) + yOffSet)];
				[gridLines lineToPoint:NSMakePoint((newRect.size.height - borderSize) + xOffSet, (i * ((newRect.size.width - (borderSize * 2)) / gridHSize) + borderSize) + yOffSet)];
				[gridLines closePath];
			}
		}
	}
	sizeOfGrid = (newRect.size.height - borderSize) + yOffSet;
	// DRAW!
	[self setNeedsDisplay:TRUE];
	//[gridLines stroke];
}

#pragma mark Delegates

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint mousePoint = [NSEvent mouseLocation];
	NSRect windowRect = [[self window] frame];
	NSRect sudokuRect = [self frame];
	NSPoint mouseOnForm;
	mouseOnForm.x = mousePoint.x - windowRect.origin.x; 
	mouseOnForm.y = mousePoint.y - windowRect.origin.y; 
	
	int totalX = sudokuRect.origin.x;
	int totalY = sudokuRect.origin.y;
	NSView *temp;
	temp = [self superview];
	while (temp != nil){
		NSRect tempRect = [temp frame];
		totalX = totalX + tempRect.origin.x;
		totalY = totalY + tempRect.origin.y;
		temp = [temp superview];
	}
	mouseOnForm.x = mouseOnForm.x - totalX - borderSize;
	mouseOnForm.y = mouseOnForm.y - totalY - borderSize;
	
	int selectedRow = 0;
	int selectedCol = 0;
	if (mouseOnForm.x >= 0 && mouseOnForm.y >= 0){
		int i;
		for (i = 0; i < gridVSize + 1; i++){
			if (mouseOnForm.x < ((i + 1) * (sizeOfGrid / gridVSize ) + xOffSet)){
				selectedCol = i + 1;
				break;
			}
		}
		for (i = 0; i < gridHSize + 1; i++){
			if (mouseOnForm.y < ((i + 1) * (sizeOfGrid / gridHSize) + yOffSet)){
				selectedRow = (i + 1) - (gridHSize + 1);
				if (selectedRow < 0)
					selectedRow = selectedRow * -1;
				break;
			}
		}
	}
	
	// mmm.. after alll of that I have got my 2 need values! YEY!
	if (selectedCol > 0 && selectedRow > 0){
		// now this object need to create a notification for the app controller to pick up
		NSDictionary *d = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:selectedRow], [NSNumber numberWithInt:selectedCol], nil]
													  forKeys:[NSArray arrayWithObjects:@"selectedRow", @"selectedCol", nil]];
		NSNotificationCenter *nc;
		nc = [NSNotificationCenter defaultCenter];
		NSLog(@"Sending notification about the new selected row (%d) and col (%d)",
			  selectedRow, selectedCol);
		[nc postNotificationName:@"SudokuViewUserSelectedNewCell" 
						  object:self 
						userInfo:d];
	}
}

#pragma mark Accessors

- (void)setGridVSize:(int)aGridVSize
{
	gridVSize = aGridVSize;
	[self setUpGrid];
}

- (int)gridVSize
{
	return gridVSize;
}

- (void)setGridHSize:(int)aGridHSize
{
	gridHSize = aGridHSize;
	[self setUpGrid];	
}

- (int)gridHSize
{
	return gridHSize;
}

- (void)setInnerGridHSize:(int)aInnerGridHSize
{
	innerGridHSize = aInnerGridHSize;
	[self setUpGrid];
}

- (int)innerGridHSize
{
	return innerGridHSize;
}
- (void)setInnerGridVSize:(int)aInnerGridVSize
{
	innerGridVSize = aInnerGridVSize;
	[self setUpGrid];
}
- (int)innerGridVSize
{
	return innerGridVSize;
}

- (void)setBorderSize:(int)aBorderSize
{
	borderSize = aBorderSize;
	[self setUpGrid];
}

- (int)borderSize
{
	return borderSize;
}
// Accessors
@synthesize sudokuSolverObj;
@synthesize innerGridLines;
@synthesize gridLines;
@synthesize outputTextAttributes;
@synthesize arrayOfOutputText;
@synthesize sizeOfGrid;
@end
