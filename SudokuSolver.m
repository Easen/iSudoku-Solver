/******************************************************************************
 * File: SudokuSolver.m
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
 
#import <Cocoa/Cocoa.h>
#import "SudokuSolver.h" 

@implementation SudokuSolver

- (id) init 
{
	self = [super init];
	if (self != nil) {
		
	}
	return self;
}

- (id) initWithNumberOfRows: (int) rows 
			NumberOfColumns: (int) cols 
		  NumberOfInnerRows: (int) innerRows
	   NumberOfInnerColumns: (int) innerCols 
{
	self = [super init];
	if (self != nil) {
		// Reset the header and rears
		allHead = NULL;
		allRear = NULL;
		headRow = NULL;
		headCol = NULL;
		headInnerGrid = NULL;
		//delete[] mainStorage;
		mainStorage = NULL;
		
		// Set up the variables
		SSCell *nextCell = NULL;
		int i, j;
		
		// Save the sizes
		numberOfRows = rows;
		numberOfCols = cols;
		numberOfInnerRows = innerRows;
		numberOfInnerCols = innerCols;
		
		// Create the array	
		mainStorage = new SSCell*[numberOfRows];
		for (i = 0; i < numberOfCols; i++)
			mainStorage[i] = new SSCell[numberOfCols];
		
		// Create the row and col arrays
		headRow = new SSCell*[numberOfRows];	
		for (i = 0; i < numberOfRows; i++)
			headRow[i] = [self getCellForRow:(i+1) Column:1];
		headCol = new SSCell*[numberOfCols];
		for (i = 0; i < numberOfCols; i++)
			headCol[i] = [self getCellForRow:1 Column:(i+1)];
		
		// Link 'em up!	
		for (i = 0; i < numberOfRows; i++){ // Rows
			for (j = 0; j < numberOfCols; j++){ // Cols
				SSCell *newCell = &mainStorage[i][j];
				if (newCell != NULL){
					newCell->value = 0;
					newCell->possibleValues = NULL;
					newCell->row = i + 1;
					newCell->col = j + 1;
					newCell->possibleValues = NULL;
					newCell->isFixedValue = false;
					newCell->innerGridID = 0;
					newCell->nextCell = NULL;
					newCell->prevCell = NULL;
					// Set up the next row and col
					newCell->nextRow = [self getCellForRow:(i+1) Column:(j+2)];
					newCell->nextCol = [self getCellForRow:(i+2) Column:(j+1)]; 
					if (allHead == NULL){ // Insert the first cell
						allHead = newCell;
						nextCell = newCell;
						allRear = newCell;
					}else{
						nextCell->nextCell = newCell;
						nextCell = newCell;
						newCell->prevCell = allRear;
						allRear = newCell;
					}
				}
			}
		}
		
		headInnerGrid = new SSCell*[numberOfInnerCols * numberOfInnerRows];
		// Create the inner grid link lists
		for (i = 0; i < (innerRows * innerCols); i++){
			int startRow;
			int startCol;
			startRow = (i / innerRows) * innerRows;
			startCol = (i - startRow) * innerCols;
			headInnerGrid[i] = [self getCellForRow:(startRow + 1) Column:(startCol + 1)];
			for(j = 0; j < (innerRows * innerCols); j++){
				int offsetRow = j / innerCols;
				int offsetCol = j - (offsetRow * innerCols);
				SSCell *currentCell = &mainStorage[startRow + offsetRow][startCol + offsetCol];
				currentCell->innerGridID = i;
				if (j + 1 == innerRows * innerCols){
					currentCell->nextInnerCell = NULL;
				}else{
					int nextOffsetRow = (j + 1) / innerCols;
					int nextOffsetCol = (j + 1) - (nextOffsetRow * innerCols);
					currentCell->nextInnerCell = &mainStorage[startRow + nextOffsetRow][startCol + nextOffsetCol];
				}
			}
		}
		for (i = 0; i < numberOfRows; i++){
			for(j = 0; j < numberOfCols; j++){
				SSCell *tempCell;
				tempCell = &mainStorage[i][j];
				if (tempCell->row != (i+1) || tempCell->col != (j+1))
				{
					tempCell->row = i + 1;
					tempCell->col = j + 1;
				}
			}
		}
		
	}
	return self;
}
- (void) dealloc
{
	[self resetGrid];
	[super dealloc];
}

- (void) resetGrid
{
	if (allHead != NULL){
		SSCell *travellingPtr;
		travellingPtr = allHead;
		delete[] mainStorage;
		allHead = NULL;
		allRear = NULL;
		headRow = NULL;
		headCol = NULL;
		headInnerGrid = NULL;
		mainStorage = NULL;
		
		numberOfRows = 0;
		numberOfCols = 0;
		numberOfInnerRows = 0;
		numberOfInnerCols = 0;
		sudokuFinishValue = SS_RESET;
	}
}

- (SSCell*) getCellForRow:(int) row
				   Column: (int) col
{
	if (row > numberOfRows || col > numberOfCols)
		return NULL;
	else
		return &mainStorage[row - 1][col - 1];	
}

- (int) insertValueForCellForRow: (int) row
						  Column: (int) col
						   Value: (int) value
				   IsAFixedValue: (bool) fixedValue
{
	int returnVal = [self insertCellCheckForRow:row
										 Column:col
										  Value:value];
	if (returnVal == OK){
		SSCell *tempCell = [self getCellForRow:row
										Column:col];
		tempCell->value = value;
		tempCell->isFixedValue = fixedValue;	
		return returnVal;
	}else
		return returnVal;
}

- (int) insertFixedValueForRow: (int) row
						Column: (int) col
						 Value: (int) value
{
	return [self insertValueForCellForRow:row
								   Column:col
								    Value:value
							IsAFixedValue:true];	
}
- (int) insertValueForRow: (int) row
				   Column: (int) col
					Value: (int) value
{
	return [self insertValueForCellForRow:row
								   Column:col
								    Value:value
							IsAFixedValue:false];	
}
- (void) solve
{
	sudokuFinishValue = [self startAtRow:1 
							      Column:1];
}
- (int) startAtRow: (int) row
			Column: (int) col
{
	SSCell *currentCell = [self getCellForRow:row
									   Column:col];
	if (currentCell == NULL) // At the end (or an error!)
		return SS_COMPLETED;
	if (!currentCell->isFixedValue){
		if (currentCell->possibleValues == NULL && currentCell->value == 0){
			// A new Cell
			[self getPossibleValuesForCell:currentCell];
		}
		// A previous cell;
		if (currentCell->numberOfPossibleValues == 0){
			// A dead end, head back
			//currentCell->value = 0;
			return SS_CANNOT_COMPLETE;
		}
		
		// Take the first no. in the possibleValue list
		// And set it as the current cells value
		currentCell->value = currentCell->possibleValues[0];
		currentCell->numberOfPossibleValues--;
		if (currentCell->numberOfPossibleValues > 0){
			// if numberOfPossibleValues >  1 Create a new array for the new possibleValues list
			int *newPossibleValues = new int[currentCell->numberOfPossibleValues];
			// Copy across the old list except for the first no.
			int i;
			for (i = 0; i < currentCell->numberOfPossibleValues; i++)
				newPossibleValues[i] = currentCell->possibleValues[i+1];
			// Delete the old list
			delete[] currentCell->possibleValues;
			// Point possibleValues to the new array
			currentCell->possibleValues = newPossibleValues;
		}else{
			// Delete the possibleValues array
			delete[] currentCell->possibleValues;
			currentCell->possibleValues = NULL;
		}
	}
	
	if (currentCell->nextCell == NULL)
		return SS_COMPLETED; // Done!
	
	int returnedValue;
	returnedValue = [self startAtRow:currentCell->nextCell->row
							  Column:currentCell->nextCell->col];
	
	if (returnedValue == SS_CANNOT_COMPLETE){
		if (currentCell->nextCell != NULL)
			if (currentCell->nextCell->isFixedValue == false)
				currentCell->nextCell->value = 0;
		
		if(currentCell->isFixedValue == true)
			return SS_CANNOT_COMPLETE;
		else
			return [self startAtRow:row 
							 Column:col];
	}else{
		return returnedValue;
	}
	
}
- (void) getPossibleValuesForCell: (SSCell*) currentCell
{
	int i, counter;
	//int fullListOfValues[numberOfInnerRows * numberOfInnerCols];
	int fullListOfValues[(numberOfInnerRows * numberOfInnerCols)];
	SSCell *travellingPtr;
	
	if (currentCell->possibleValues){
		delete[] currentCell->possibleValues;
		currentCell->possibleValues = NULL;
		currentCell->numberOfPossibleValues = 0;
	}
	for (i = 0; i < (numberOfInnerRows * numberOfInnerCols) ; i++)
		fullListOfValues[i] = 0;
	
	travellingPtr = headRow[currentCell->row - 1];
	while(travellingPtr != NULL){
		if (travellingPtr->value > 0)
			fullListOfValues[travellingPtr->value - 1] = -1;
		travellingPtr = travellingPtr->nextRow;
	}
	
	travellingPtr = headCol[currentCell->col - 1];
	while(travellingPtr != NULL){
		if (travellingPtr->value > 0)
			fullListOfValues[travellingPtr->value - 1] = -1;
		travellingPtr = travellingPtr->nextCol;
	}
	
	travellingPtr = headInnerGrid[currentCell->innerGridID];
	while(travellingPtr != NULL){
		if (travellingPtr->value > 0)
			fullListOfValues[travellingPtr->value - 1] = -1;
		travellingPtr = travellingPtr->nextInnerCell;
	}
	
	if (currentCell->value > 0)
		fullListOfValues[currentCell->value - 1] = -1;
	counter=0;
	for(i = 0; i < (numberOfInnerRows * numberOfInnerCols) ; i++){
		if (fullListOfValues[i] == 0)
			counter++;
	}
	if (counter == 0){
		currentCell->possibleValues = NULL;
		currentCell->numberOfPossibleValues = 0;
	}else{
		currentCell->possibleValues = new int[counter + 1];
		currentCell->numberOfPossibleValues = 0;
		for(i = 1; i < (numberOfInnerRows * numberOfInnerCols) + 1; i++){
			if (fullListOfValues[i - 1] == 0){
				currentCell->possibleValues[currentCell->numberOfPossibleValues] = i;
				currentCell->numberOfPossibleValues++;
			}
		}
	}

}
- (int) insertCellCheckForRow: (int) row
					   Column: (int) col
					    Value: (int) value
{
	SSCell *tempCell = [self getCellForRow:row
								    Column:col];
	if (tempCell == NULL)
		return OUTOFBOUNDS;
	if(value == 0)
		return OK;
	if (tempCell->isFixedValue)
		return FIXEDVALUE;
	[self getPossibleValuesForCell:tempCell];
	int i;
	for (i = 0; i < tempCell->numberOfPossibleValues; i++)
		if (value == tempCell->possibleValues[i])
			return OK;
	return INVALIDVALUE;
}
// Accessors
@synthesize numberOfRows;
@synthesize numberOfCols;
@synthesize numberOfInnerRows;
@synthesize numberOfInnerCols;
@synthesize sudokuFinishValue;

@end