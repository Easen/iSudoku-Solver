/******************************************************************************
 * File: AppController.m
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
#import "AppController.h"

@implementation AppController

#pragma mark Init functions

- (id) init {
	self = [super init];
	if (self != nil) {
		fTimer = nil;
	}
	return self;
}

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(applicationDidFinishLaunching:)
	 name:NSApplicationDidFinishLaunchingNotification
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(windowDidResize:)
	 name:NSWindowDidResizeNotification
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(sudokuViewUserSelectedNewCell:)
	 name:@"SudokuViewUserSelectedNewCell"
	 object:nil];
} 

- (void) dealloc {
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self];
	
	if (!fTimer)
		[fTimer release];
	
	[super dealloc];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app
{
	return YES;
}

#pragma mark NSNotifications

- (void) applicationDidFinishLaunching:(NSNotification*) aNotification
{
	//App Loaded
	[startSolvingBtn setAction:nil];
}

- (void) windowDidResize:(NSNotification*) aNotification
{
	[sudokuGrid setUpGrid];
}

- (void) sudokuViewUserSelectedNewCell:(NSNotification *) aNotification
{
	NSNumber *selectedRow, *selectedCol;
	selectedRow = [[aNotification userInfo] objectForKey:@"selectedRow"];
	selectedCol = [[aNotification userInfo] objectForKey:@"selectedCol"];
	
	[insertFixedValueSelectedCol setPlaceholderString:[selectedCol stringValue]];
	[insertFixedValueSelectedCol setIntValue:[selectedCol intValue]];
	[insertFixedValueSelectedRow setPlaceholderString:[selectedRow stringValue]];
	[insertFixedValueSelectedRow setIntValue:[selectedRow intValue]];
	SSCell *tempCell = [fSudokuSolver getCellForRow:[selectedRow intValue]
											 Column:[selectedCol intValue]];
	if (tempCell)
	{
		[fSudokuSolver getPossibleValuesForCell:tempCell];
		
		int i;
		for(i = 0; i < tempCell->numberOfPossibleValues; i++){
			[insertFixedValueSelectedVal addItemWithObjectValue:[NSNumber numberWithInt:tempCell->possibleValues[i]]];
		}
		[insertFixedValueSelectedVal addItemWithObjectValue:[NSNumber numberWithInt:0]];
		[insertFixedValueSelectedVal selectItemAtIndex:0];
		[insertFixedValueAdd highlight:YES];
		
		[NSApp beginSheet: insertFixedValue modalForWindow: window modalDelegate: self
		   didEndSelector: nil contextInfo: nil];		
	}	
}
#pragma mark IBActions for Main Window

- (IBAction)resetGrid:(id)sender
{
	[fSudokuSolver release];
	[self createNewGrid];
	[startSolvingBtn setEnabled:YES];
	[sudokuGrid setNeedsDisplay:YES];
}

- (IBAction)startSolving:(id)sender
{
	
	[NSThread detachNewThreadSelector:@selector(sudokuSolverWrapper:) 
							 toTarget:self 
						   withObject:nil];

	//Set up the draw timer
	fTimer = [NSTimer scheduledTimerWithTimeInterval:0.001 
											  target:self 
											selector:@selector(timerUpdateGrid:) 
											userInfo:nil repeats:YES];
	
	[startSolvingBtn setEnabled:NO];
}

#pragma mark IBAction for Set Up Grid

- (IBAction) setUpGridSheetEndOk: (id) sender
{
	[setUpGrid orderOut: nil];
    [NSApp endSheet: setUpGrid];
	
	// Set grid values
	if([setUpGridRadio9x9 intValue])
	{
		fSudokuSolver = [[SudokuSolver alloc] initWithNumberOfRows:9
												   NumberOfColumns:9
												 NumberOfInnerRows:3 
											 NumberOfInnerColumns:3];
	} else if([setUpGridRadio16x16 intValue]) {
		fSudokuSolver = [[SudokuSolver alloc] initWithNumberOfRows:16
												   NumberOfColumns:16
												 NumberOfInnerRows:4 
											 NumberOfInnerColumns:4];
    }
    
    sudokuGrid.sudokuSolverObj = fSudokuSolver;
    
    [sudokuGrid setInnerGridHSize:fSudokuSolver.numberOfInnerCols];
    [sudokuGrid setInnerGridVSize:fSudokuSolver.numberOfInnerRows];
    [sudokuGrid setGridHSize:fSudokuSolver.numberOfRows];
    [sudokuGrid setGridVSize:fSudokuSolver.numberOfCols];
    
    [sudokuGrid.outputTextAttributes setObject:[NSFont fontWithName:@"Helvetica"
                                                               size:25 - ((fSudokuSolver.numberOfRows - 9)  * 1.7) ]
                                        forKey:NSFontAttributeName];
	
	[sudokuGrid setBorderSize:5];
	
	[startSolvingBtn setAction:@selector(startSolving:)];
}

- (IBAction)setUpGridSheetEndCancel:(id)sender
{
	[setUpGrid orderOut: nil];
    [NSApp endSheet: setUpGrid];
}
#pragma mark IBAction for Insert Fixed Value
- (IBAction)insertFixedValueAdd:(id)sender
{
	NSNumber *selectedCol, *selectedRow, *selectedVal;
	
	selectedRow = [[NSNumber alloc]
				   initWithInt:[[insertFixedValueSelectedRow placeholderString] intValue]];
	selectedCol = [[NSNumber alloc] 
				   initWithInt:[[insertFixedValueSelectedCol placeholderString] intValue]];
	selectedVal = [[NSNumber alloc]
				   initWithInt:[[insertFixedValueSelectedVal stringValue] intValue]];
	
	// Close the window
	[insertFixedValue orderOut: nil];
    [NSApp endSheet: insertFixedValue];
	int returnVal;
	if ([selectedVal intValue] == 0)
		returnVal = [fSudokuSolver insertValueForRow:[selectedRow intValue]
											  Column:[selectedCol intValue]
											   Value:[selectedVal intValue]];
	else
		returnVal = [fSudokuSolver insertFixedValueForRow:[selectedRow intValue]
												   Column:[selectedCol intValue]
											        Value:[selectedVal intValue]];
	if (returnVal == OK){
		// Show it
		[sudokuGrid setNeedsDisplay:YES];
	}else{
		
		// Show error?
	}
	
	[insertFixedValueSelectedVal removeAllItems];
	
	[selectedCol release];
	[selectedRow release];
	[selectedVal release];
}

- (IBAction)insertFixedValueCancel:(id)sender
{
	[insertFixedValue orderOut: nil];
    [NSApp endSheet: insertFixedValue];
}
#pragma mark Obj Class Functions
- (void)createNewGrid
{
	[NSApp beginSheet: setUpGrid modalForWindow: window modalDelegate: self
	   didEndSelector: nil contextInfo: nil];
}

- (void)sudokuSolverWrapper: (id)sender
{
	NSAutoreleasePool*  pool = [[NSAutoreleasePool alloc] init];
	
	NSLog(@"ss_solve Called");
	
	[fSudokuSolver solve];
	
	[pool release];
	
	if ([NSThread isMainThread] == NO){
		// Need to close this thread
		fKillTimer = YES;
		[NSThread exit];
	}
}

- (void)timerUpdateGrid:(NSTimer*)aTimer
{
	[sudokuGrid setNeedsDisplay:YES];
	
	if (fKillTimer){
		[fTimer invalidate];
		
		NSAlert *alert;
		switch(fSudokuSolver.sudokuFinishValue)
		{
			case SS_COMPLETED:
				alert = [NSAlert alertWithMessageText:@"Your soduko is solved!" 
										defaultButton:@"Ok" 
									  alternateButton:nil 
										  otherButton:nil
							informativeTextWithFormat:@"Your soduko is solved!" ];
				[startSolvingBtn setAction:nil];
				break;
			case SS_RESET:
			case SS_CANNOT_COMPLETE:
                alert = [NSAlert alertWithMessageText:@"There was an error, perhaps your soduku seems to be impossible." 
										defaultButton:@"Ok" 
									  alternateButton:nil 
										  otherButton:nil
							informativeTextWithFormat:@"Impossible" ];
				break;
		} 
		[alert runModal];
		[alert release];
		
		fKillTimer = NO;
	}	
}
@synthesize setUpGridRadio16x16;
@synthesize setUpGridRadio9x9;
@synthesize fKillTimer;
@synthesize fTimer;
@synthesize insertFixedValueSelectedCol;
@synthesize window;
@synthesize startSolvingBtn;
@synthesize insertFixedValue;
@synthesize setUpSudokuSolver;
@synthesize newGridBtn;
@synthesize fSudokuSolver;
@synthesize insertFixedValueSelectedRow;
@synthesize setUpGrid;
@synthesize insertFixedValueSelectedVal;
@synthesize sudokuGrid;
@synthesize insertFixedValueAdd;
@end
