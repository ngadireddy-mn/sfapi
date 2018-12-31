/*  
 *  License
 *  
 *  This file is part of The SeleniumFlex-API.
 *  
 *  The SeleniumFlex-API is free software: you can redistribute it and/or
 *  modify it  under  the  terms  of  the  GNU  General Public License as 
 *  published  by  the  Free  Software Foundation,  either  version  3 of 
 *  the License, or any later version.
 *
 *  The SeleniumFlex-API is distributed in the hope that it will be useful,
 *  but  WITHOUT  ANY  WARRANTY;  without  even the  implied  warranty  of
 *  MERCHANTABILITY   or   FITNESS   FOR  A  PARTICULAR  PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with The SeleniumFlex-API.
 *  If not, see http://www.gnu.org/licenses/
 *
 */
package sfapi.commands
{
import flash.events.Event;
import flash.events.MouseEvent;

import mx.controls.CheckBox;
import mx.controls.DataGrid;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.controls.listClasses.IListItemRenderer;
import mx.events.DataGridEvent;
import mx.events.ListEvent;
import mx.events.MenuEvent;
import mx.collections.IHierarchicalCollectionViewCursor;

import mx.utils.StringUtil;

import sfapi.core.AppTreeParser;
import sfapi.core.ErrorMessages;
import sfapi.core.ReferenceData;
import sfapi.core.Tools;

public class DataGridCommands extends AbstractCommand
	{
		public function DataGridCommands(aptObj:AppTreeParser, contextObj:Commands)
		{
			super(aptObj, contextObj);
		}

		
		/**
		 * Returns a value in a grid given the row and column
		 * <br/>
		 * Command: flexDataGridCell
		 * Target:  myGridControl
		 * Value:   1,2
		 * <br/>
		 * Breakdown:
		 * <br/>
		 * Command: <command>
		 * Target:  <grid id>
		 * Value:   <row>,<col>
		 * <br/>
		 * All fields are compulsory
		 * <br/>
		 * @param  id  id of the control
		 * @param  value  takes the form <row>,<col>
		 * @return  a string of the value set in the grid cell   
		 */
		public function getFlexDataGridCell(value:String):String
		{
			var args:Array = value.split(",");
			var id:String = args[0];
			var rowIndex:String = args[1];
			var colIndex:String = args[2];
			return rawFlexDataGridCell(id, rowIndex, colIndex);
		}
		
		/**
		 * Returns a value in a grid given the row and column
		 * @param  id  id of the control
		 * @param  rowIndex  index of the row of the cell
		 * @param  colIndex  index of the column of the cell
		 * @return  a string of the value set in the grid cell   
		 */
		public function rawFlexDataGridCell(id:String, rowIndex:String, colIndex:String):String {
			var result:String;
			try
			{
				var widget:Object = appTreeParser.getWidgetById(id);
				var row:Object = widget.dataProvider[parseInt(rowIndex)];
				var col:Object = widget.columns[parseInt(colIndex)];
				result = col.itemToLabel(row);
			}
			catch (e:Error)
			{
				// todo use standard err
				result = "ERROR: Widget '" + id + "': " + e.message;
			}
			return result;
		}
		
		/**
		 * Sets a text value in a datagrid cell
		 * <br/>
		 * Command: flexSetDataGridCell
		 * Target:  myDataGridItem
		 * Value:   1,2,this data
		 * <br/>
		 * Breakdown:
		 * <br/>
		 * Command: <command>
		 * Target:  <datagrid id>
		 * Value:   <rowIndex>,<colIndex>,<data value>
		 * <br/>
		 * All fields are compulsory
		 * <br/>
		 * @param  value  takes the form <rowIndex>,<colIndex>,<data>
		 * @return  'true' if successfully set, error if not  
		 */
		public function doFlexSetDataGridCell(target:String, value:String):String
		{
			var args:Array = target.split(",");
			var id:String = args[0];
			var rowIndex:String = args[1];
			var colIndex:String = args[2];
			return rawFlexSetDataGridCell(id, rowIndex, colIndex, value);
		}
		
		/**
		 * Sets a text value in a datagrid cell
		 * @param  id  Id of the data grid
		 * @param  rowIndex  index of the row of the cell
		 * @param  colIndex  index of the column of the cell
		 * @param  data  The value to set in cell
		 * @return  'true' if successfully set, error if not  
		 */
		public function rawFlexSetDataGridCell(id:String, rowIndex:String, colIndex:String, data:String):String
		{
			var result:String;
			try
			{
				var widget:Object = appTreeParser.getWidgetById(id);
				var row:Object = widget.dataProvider[parseInt(rowIndex)];
				var col:Object = widget.columns[parseInt(colIndex)];
				row[col.dataField] = data;
				result = String(widget.dataProvider.dispatchEvent(new Event(Event.CHANGE)));
			}
			catch(e:Error)
			{
				// todo use standard err
				result = "ERROR: Widget '" + id + "': " + e.message;
			}
			return result;
		}	

		/**
		 * Returns the row index of a given value in a certain field on a grid
		 * <br/>
		 * Command: flexDataGridRowIndexForFieldValue
		 * Target:  myGridControl
		 * Value:   theField,hello
		 * <br/>
		 * Breakdown:
		 * <br/>
		 * Command: <command>
		 * Target:  <grid id>
		 * Value:   <fieldName>,<data>
		 * <br/>
		 * All fields are compulsory
		 * <br/>
		 * @param  id  id of the control
		 * @param  value  takes the form "<fieldName>,<data>"
		 * @return  a string of row index for cell containing the data
		 */
		public function getFlexDataGridRowIndexForFieldValue(value:String):String
		{
			var args:Array = value.split(",");
			var id:String = args[0];
			var fieldName:String = args[2];
			var data:String = args[3];
			
			return rawFlexDataGridRowIndexForFieldValue(id, fieldName, data);
		}
		
		/**
		 * Returns the row index of a given value in a certain field on a grid
		 * @param  id  id of the control
		 * @param  fieldName  Name of the field/column
		 * @param  data  The value to look for in field
		 * @return  a string of row index for cell containing the data
		 */
		public function rawFlexDataGridRowIndexForFieldValue(id:String, fieldName:String, data:String):String
		{
			var result:String;
			try
			{
				var widget:Object = appTreeParser.getWidgetById(id);
				var provider:Object = widget.dataProvider;
				var index:int = -1;
				var i:int = 0;
				for each (var row:Object in provider)
				{
					if(row.hasOwnProperty(fieldName))
					{
						if(row[fieldName].toString() == data)
						{
							index = i;
							break;
						}
					} 
					i++;			
				}		
				result = String(index);
			}
			catch (e:Error)
			{
				// todo use standard err
				result = "ERROR: Widget '" + id + "': " + e.message;
			}
			return result;
		}

		/**
		 * Returns the row index of a given label in a certain field on a grid
		 * <br/>
		 * Command: flexDataGridRowIndexForFieldLabel
		 * Target:  myGridControl,theField,myLabelValue
		 * <br/>
		 * Breakdown:
		 * <br/>
		 * Command: <command>
		 * target:  <grid id>, <fieldName>,<value>
		 * value:  args
		 * <br/>
		 * All fields are compulsory
		 * <br/>
		 * @param  target  takes the form "<id><fieldName>,<value>"
		 * @param  args
		 * @return  a string of row index for cell containing the label
		 */
		public function getFlexDataGridRowIndexForFieldLabel(target:String, value:String):String
		{
			var args:Array = target.split(",");
			var id:String = args[0];
			var fieldName:String = args[1];
			var value:String = args[2];

			return rawFlexDataGridRowIndexForFieldLabel(id, fieldName, value);
		}

        public function getFlexDataGridRowDataForRowIndex(target:String, rowIdx:String):String
		{
			var id:String = target;
			var rowIndex:int = parseInt(rowIdx);
			return rawFlexDataGridRowDataForRowIndex(id, rowIndex);
		}

        public function rawFlexDataGridRowDataForRowIndex(id:String, rowIndex:int):String
		{
			var result:Array = new Array();
			var itemSeparator:String = "##ITEM##";
			try
			{
				var widget:Object = appTreeParser.getWidgetById(id);
				var provider:Object = widget.dataProvider;
				var rowItem:Object = provider[rowIndex];
				for each (var column:Object in widget.columns)
				{
                    var item:String = column.itemToLabel(rowItem);
                    if (!item)
                    {
                        item = " ";
                    }
                    result.push(item);
				}
			}
			catch (e:Error)
			{
				return "ERROR: Widget '" + id + "': " + e.message;
			}
			return result.join(itemSeparator);
		}


        /**
		 * Returns the row index of given labels in fields on a grid (custom code)
		 * <br/>
		 * Command: getFlexDataGridRowIndexForColumns
		 * Target:  myGridControl,columnNames,columnValues
		 * <br/>
		 * Breakdown:
		 * <br/>
		 * Command: <command>
		 * target:  <grid id>, <fieldName>,<value>
		 * value:  args
		 * <br/>
		 * All fields are compulsory
		 * <br/>
		 * @param  target  takes the form "<id>"
		 * @param  args takes the form "<fieldName1>|<fieldName2>...,<value1>|<value2>..."
		 * @return  a string of row index for cell containing the label
		 */
        public function getFlexDataGridRowIndexForColumns(target:String, value:String):String
		{
			var id:String = target;
			var args:Array = value.split(",");
			var columnNames:String = args[0];
			var columnValues:String = args[1];
			return rawFlexDataGridRowIndexForMatchedColumnValues(id, columnNames, columnValues);
		}

        public function rawFlexDataGridRowIndexForMatchedColumnValues(id:String, columnNames:String, columnValues:String):String
		{
			var names:Array = columnNames.split('|');
			var data:Array = columnValues.split('|');
			var columnObjects:Array = new Array();
			var result:String;
			var index:int = -1;
			try
			{
				var widget:Object = appTreeParser.getWidgetById(id);
				for each (var columnName:String in names){
					for each (var candidate:Object in widget.columns)
					{
						if (candidate.dataField == columnName)
						{
							columnObjects.push(candidate);
							break;
						}
					}
				}
				if(columnObjects.length == 0)
				{
					// todo use standard err
					throw new Error("No columns for fields found");
				}
				var rowIndex:int = 0;
				var provider:Object = widget.dataProvider;
				for each(var row:Object in provider)
				{
					var indexValue:int = 0;
					var matchedColumnIndex:int = 0;
					for each(var columnObject:Object in columnObjects){
						var value:String = columnObject.itemToLabel(row);
						if (value == data[indexValue])
						{
							matchedColumnIndex++;
						}
						indexValue++;
					}
					if(matchedColumnIndex === columnObjects.length){
						index = rowIndex;
						break;
					}
					else
					{
						rowIndex++;
					}
				}
				result = String(index);
			}
			catch (e:Error)
			{
				// todo use standard err
				result = "ERROR: Widget '" + id + "': " + e.message;
			}
			return result;
		}

		/**
		 * Returns the row index of a given label in a certain field on a grid
		 * @param  id  id of the control
		 * @param  fieldName  Name of the field/column
		 * @param  data  The label to look for in field
		 * @return  a string of row index for cell containing the label
		 */
		public function rawFlexDataGridRowIndexForFieldLabel(id:String, fieldName:String, data:String):String
		{
			var result:String;
			try
			{
				var widget:Object = appTreeParser.getWidgetById(id);
				var column:Object;
				for each (var candidate:Object in widget.columns)
				{
					if (candidate.dataField == fieldName)
					{
						column = candidate;
						break;
					}
				}
				if(! column)
				{
					// todo use standard err
					throw new Error("No column for field '" + fieldName + "'");
				}
				
				var index:int = -1;
				var i:int = 0;
				var provider:Object = widget.dataProvider;
				for each(var row:Object in provider)
				{
					var value:String = column.itemToLabel(row);
					
					if (value == data)
					{
						index = i;
						break;
					}
					i++;
				}
				result = String(index);
			}
			catch (e:Error)
			{
				// todo use standard err
				result = "ERROR: Widget '" + id + "': " + e.message;
			}
			return result;
		}
		
		/**
		 * Returns the data value of a field of the object that populates a row of a data grid.
		 * <br/>
		 * Command:	flexDataGridCell
		 * Target:	myGridControl
		 * Value:	fieldName,2
		 * <br/>
		 * Breakdown:
		 * <br/>
		 * Command:	<command>
		 * Target:	<grid id>
		 * Value:	<field>,<row>
		 * <br/>
		 * All fields are compulsory
		 * <br/>
		 * @param  id  id of the control
		 * @param  value  takes the form "<field>,<row>"
		 * @return  a string of the value set in the grid cell   
		 */
		public function getFlexDataGridFieldValueForGridRow(value:String):String
		{
			var args:Array = value.split(",");
			var id:String = args[0];
			var field:String = args[1];
			var rowNum:String = args[2];
			
			return rawFlexDataGridFieldValueForGridRow(id, field, rowNum);
		}
		
		/**
		 * Returns the data value of a field of the object that populates a row of a data grid.
		 * @param id the id of the Data Grid
		 * @param field the name of the field in the object whose data is required
		 * @param rowNum the required row number (numbering starts at 0)
		 */
		public function rawFlexDataGridFieldValueForGridRow(id:String, field:String, rowNum:String) : String 
		{
			var result:String = "";
			try
			{
				var widget:Object = appTreeParser.getWidgetById(id);
				var provider:Object = widget.dataProvider;
				var index:int = parseInt(rowNum);
				if((index < 0) || (index >= provider.length))
				{
					// todo use standard err
					throw new Error("Row index '" + index + "' out of bounds for dataProvider");
				}
				
				var row:Object = provider[index];
				var val:Object = row[field];
				if (val is Date)
				{
					val = (val as Date).getTime();
				} 
				result = val.toString();
			}
			catch (e:Error)
			{
				// todo use standard err
				result = "ERROR: Widget '" + id + "': " + e.message;
			}
			return result;
		}
		
		/**
		 * Returns the label value of a field of the object that populates a row of a data grid.
		 * <br/>
		 * Command:	flexDataGridCell
		 * Target:	myGridControl
		 * Value:	myFiels,2
		 * <br/>
		 * Breakdown:
		 * <br/>
		 * Command:	<command>
		 * Target:	<grid id>
		 * Value:	<field>,<row>
		 * <br/>
		 * All fields are compulsory
		 * <br/>
		 * @param  id  id of the control
		 * @param  value  takes the form "<field>,<row>"
		 * @return  a string of the label set in the grid cell   
		 */
		public function getFlexDataGridFieldLabelForGridRow(value:String):String
		{
			var args:Array = value.split(",");
			var id:String = args[0];
			var field:String = args[1];
			var rowNum:String = args[2];
			
			return rawFlexDataGridFieldLabelForGridRow(id, field, rowNum);
		}
		
		/**
		 * Returns the label value of a field of the object that populates a row of a data grid.
		 * @param  id  id of the control
		 * @param  field  name of the field
		 * @param  rowNum  number of the row
		 * @return  a string of the label set in the grid cell   
		 */
		public function rawFlexDataGridFieldLabelForGridRow(id:String, field:String, rowNum:String):String
		{
			var result:String = "";
			try
			{
				var widget:Object = appTreeParser.getWidgetById(id);
				var provider:Object = widget.dataProvider;
				var index:int = parseInt(rowNum);
				if ((index < 0) || (index >= provider.length))
				{
					// todo use standard err
					throw new Error("Row index '" + index + "' out of bounds for dataProvider");
				}
				var column:Object;
				for each (var candidate:Object in widget.columns)
				{
					if (candidate.dataField == field)
					{
						column = candidate;
						break;
					}
				}
				if(! column)
				{
					// todo use standard err
					throw new Error("No column for field '" + field + "'");
				}
				
				var row:Object = provider[index];
				
				result = column.itemToLabel(row);
			}
			catch (e:Error)
			{
				// todo use standard err
				result = "ERROR: Widget '" + id + "': " + e.message;
			}
			return result;
		}
		
		/**
		 * Get row count in a datagrid
		 * <br/>
		 * Command:  getFlexDataGridRowCount
		 * Target:   myDataGridItem
		 * Value:  args - not used
		 * <br/>
		 * Breakdown:
		 * <br/>
		 * Command:  <command>
		 * Target:   <datagrid id>
		 * <br/>
		 * All fields are compulsory
		 * <br/>
		 * @param  target  takes the form <datagrid id>
		 * @return  row count
		 */
		public function getFlexDataGridRowCount(id:String, args:String):String
		{
			var result:String;
			try
			{
				var widget:Object = appTreeParser.getWidgetById(id);
				if (widget == null)
				{
					return ErrorMessages.getError(ErrorMessages.ERROR_ELEMENT_NOT_FOUND, [id]);
				}
				var provider:Object = widget.dataProvider;
				if (provider == null)
				{
					return "0";
				}
				result = String(provider.length);
			}
			catch (e:Error)
			{
				// todo use standard err
				result = "ERROR: Widget '" + id + "': " + e.message;
			}
			return result;
		}

		/**
		 * Sets a date value in a datagrid cell
		 * <br/>
		 * Command: flexDataGridDate
		 * Target:  myDataGridItem
		 * Value:   1,2,this data
		 * <br/>
		 * Breakdown:
		 * <br/>
		 * Command: <command>
		 * Target:  <menubar id>
		 * Value:   <rowIndex>,<colIndex>,<data value>
		 * <br/>
		 * All fields are compulsory
		 * <br/>
		 * @param  value  takes the form <rowIndex>,<colIndex>,<data>
		 * @return  'true' if successfully set, error if not
		 */
		public function doFlexDataGridDate(target:String, value:String):String
		{
			var args:Array = value.split(",");
			var dataGridRowIndex:String = args[0];
			var dataGridColIndex:String = args[1];
			var date:String = args[2];
			var datagrid:Object = appTreeParser.getElement(target);
			if (datagrid == null || !datagrid is DataGrid)
			{
				return ErrorMessages.getError(ErrorMessages.ERROR_ELEMENT_NOT_FOUND, [target]);
			}
			var object:Object = getDataGridCellComponent(target, dataGridRowIndex, dataGridColIndex);
			if (object == null) {
				return ErrorMessages.getError(ErrorMessages.ERROR_NO_CHILD_UICOMPONENT, [target, dataGridRowIndex, dataGridColIndex]);
			}
			else if (object is String){
				return String(object);
			}
						
			var columnIndex:int = getColumnIndexFromDisplayableColumnIndex(DataGrid(datagrid) ,dataGridColIndex);
			if (columnIndex == -1){
				return ErrorMessages.getError(ErrorMessages.ERROR_NO_CHILD_UICOMPONENT, [target, dataGridRowIndex, dataGridColIndex]);
			}
			var row:Object = datagrid.dataProvider[int(dataGridRowIndex)];
			var col:Object = datagrid.columns[int(columnIndex)];
			row[col.dataField] = context.dateCommands.compileDateValue(date, object.formatString);
			return String(datagrid.dataProvider.dispatchEvent(new Event(Event.CHANGE)));			
		}

		private function getColumnIndexFromDisplayableColumnIndex(datagrid:DataGrid, displayColumnIndex:String):int{
			// Not able to use displayableColumns because it's not public
			// datagrid.displayableColumns[displayColumnIndex].colNum
			var index:int = 0;
			for (var columnNo:int = 0; columnNo < datagrid.columns.length ; columnNo++){
				var column:DataGridColumn = datagrid.columns[columnNo];
				if (column.visible){
					index++;
				}
				if (index-1  == int(displayColumnIndex)){					
					return columnNo;
				}
			}
			return -1;
		}
		
		/**
		 * Sets checkbox state in a datagrid cell
		 * <br/>
		 * Command: flexDataGridCellCheckbox
		 * Target:  myDataGridItem
		 * Value:   1,2,this data
		 * <br/>
		 * Breakdown:
		 * <br/>
		 * Command: <command>
		 * Target:  <datagrid id>
		 * Value:   <rowIndex>,<colIndex>,<check box state>
		 * <br/>
		 * All fields are compulsory
		 * <br/>
		 * @param  value  takes the form <rowIndex>,<colIndex>,<check box state>
		 * @return  'true' if successfully set, error if not
		 */
		public function doFlexDataGridCheckBox(target:String, value:String):String
		{
			var args:Array = value.split(",");
			var dataGridRowIndex:String = args[0];
			var dataGridColIndex:String = args[1];
			var checkBoxState:String = args[2];
			var object:Object = getDataGridCellComponent(target, dataGridRowIndex, dataGridColIndex);
			if (object == null) {
				return ErrorMessages.getError(ErrorMessages.ERROR_ELEMENT_NOT_FOUND, [target]);
			}

			return context.checkBoxCommands.rawFlexCheckBox(object, checkBoxState);
		}

		/**
		 * Get checkbox state in a datagrid cell
		 * <br/>
		 * Command: getFlexDataGridCheckBoxChecked
		 * Target:  myDataGridItem,1,2
		 * Value:   args - not used
		 * <br/>
		 * Breakdown:
		 * <br/>
		 * Command:  <command>
		 * Target:   <datagrid id>,<rowIndex>,<colIndex>
		 * <br/>
		 * All fields are compulsory
		 * <br/>
		 * @param  target  takes the form <datagrid id>,<rowIndex>,<colIndex>
		 * @return  'checkbox state
		 */
		public function getFlexDataGridCheckBoxChecked(target:String, value:String):String
		{
			var args:Array = target.split(",");
			var dataGridId:String = args[0];
			var dataGridRowIndex:String = args[1];
			var dataGridColIndex:String = args[2];
			var object:Object = getDataGridCellComponent(dataGridId, dataGridRowIndex, dataGridColIndex);
			if (object == null) {
				return ErrorMessages.getError(ErrorMessages.ERROR_ELEMENT_NOT_FOUND, [dataGridId]);
			}

			return context.checkBoxCommands.getFlexCheckBoxStatus(object);
		}

		/**
		 * Select combo box by label in a datagrid cell
		 * <br/>
		 * Command: doFlexDataGridSelectComboByLabel
		 * Target:  myDataGridItem
		 * Value:   1,2,label
		 * <br/>
		 * Breakdown:
		 * <br/>
		 * Command: <command>
		 * Target:  <datagrid id>
		 * Value:   <rowIndex>,<colIndex>,label
		 * <br/>
		 * All fields are compulsory
		 * <br/>
		 * @param  value  takes the form <rowIndex>,<colIndex>,<label>
		 * @return  'true' if successfully set, error if not
		 */
		public function doFlexDataGridSelectComboByLabel(target:String, value:String):String
		{
			var args:Array = value.split(",");
			var dataGridRowIndex:String = args[0];
			var dataGridColIndex:String = args[1];
			var comboBoxLabel:String = args[2];
			var object:Object = getDataGridCellComponent(target, dataGridRowIndex, dataGridColIndex);
			if (object == null) {
				return ErrorMessages.getError(ErrorMessages.ERROR_ELEMENT_NOT_FOUND, [target]);
			}

			return context.comboCommands.rawFlexSelectComboByLabel(object, comboBoxLabel);
		}

		/**
		 * Click header in a datagrid cell
		 * <br/>
		 * Command: flexDataGridClickColumnHeader
		 * Target:  myDataGridItem
		 * Value:   1
		 * <br/>
		 * Breakdown:
		 * <br/>
		 * Command:  <command>
		 * Target:   <datagrid id>
		 * colIndex: <colIndex>
		 * <br/>
		 * All fields are compulsory
		 * <br/>
		 * @param  colIndex  takes the form <colIndex>
		 * @return  'true' if successfully set, error if not
		 */
		public function doFlexDataGridClickColumnHeader(target:String, colIndex:String):String
		{
			var child:Object = appTreeParser.getElement(target);
			if (child == null)
			{
				return ErrorMessages.getError(ErrorMessages.ERROR_ELEMENT_NOT_FOUND, [target]);
			}
			return child.dispatchEvent(new DataGridEvent(DataGridEvent.HEADER_RELEASE, false, false,
					int(colIndex), child.columns[int(colIndex)].dataField));

		}


		/**
		 * Return the component in a datagrid cell
		 * @param  id  - Data grid id
		 * @param  rowIndex  - row index
		 * @param  colIndex  - column index
		 * @param  componentIndexInCell  - component index in cell. 
		 *   Default to -1, returns cell itself
		 *   0 , returns the first component in cell 
		 * @return  component if successfully found, ERROR_NO_CHILD_UICOMPONENT error if not found.
		 */ 
		public function getDataGridCellComponent(id:String, rowIndex:String, colIndex:String, componentIndexInCell:String = "-1"):Object
		{
			var child:Object = appTreeParser.getElement(id);
			if (child == null)
			{
				return ErrorMessages.getError(ErrorMessages.ERROR_ELEMENT_NOT_FOUND, [id]);
			}

			// Assumes the DataGrid has only one ListBaseContentHolder
			var dgContentList:Object = Tools.getChildrenOfTypeFromContainer(child,
					ReferenceData.LISTBASECONTENTHOLDER_DESCRIPTION)[0];

			if (dgContentList.listItems.length > int(rowIndex) && dgContentList.listItems[int(rowIndex)].length > int(colIndex)) 
			{
				if (componentIndexInCell != null && int(componentIndexInCell) > -1)
				{
					var cell:Object = dgContentList.listItems[int(rowIndex)][int(colIndex)];
					var cellChildren:Array = cell.getChildren();
					if (cellChildren.length > int(componentIndexInCell))
					{
						return cellChildren[componentIndexInCell];
					}
				}
				else
				{
					return dgContentList.listItems[int(rowIndex)][int(colIndex)];
				}
			}
			return ErrorMessages.getError(ErrorMessages.ERROR_NO_CHILD_UICOMPONENT, [id,rowIndex,colIndex,componentIndexInCell]);
		}
	
		/**
		 * Dispatches a ListEvent.ITEM_DOUBLE_CLICK Event on the UIComponent of a Datagrid at a given
		 * row and column index.  If the cell at the given row and column has multiple
		 * UIComponents provid the componentIndexInCell in the function signature.
		 *
		 * @param  datagridId  The ID of the Datagrid object
		 * @param  rowIndex	The row index of the Component in the Datagrid
		 * @param  columnIndex The colum index of the Component in the Datagrid
		 * @return  'true' if the button was clicked. An error message if the call fails.
		 */
		public function rawFlexDoubleClickDataGridUIComponent(datagridId:String, rowIndex:String, columnIndex:String):String
		{
			var child:Object = appTreeParser.getElement(datagridId);

			if (child == null) {
				return ErrorMessages.getError(ErrorMessages.ERROR_ELEMENT_NOT_FOUND, [datagridId]);
			}

			// Assumes the DataGrid has only one ListBaseContentHolder
			var dgContentList:Object = Tools.getChildrenOfTypeFromContainer(child, ReferenceData.LISTBASECONTENTHOLDER_DESCRIPTION)[0];

			// Make certain the rowIndex and colIndex do not exceed the length of the
			// Datagrid ListBaseContentHolders rows and columns.
			if (dgContentList.listItems.length > int(rowIndex) && dgContentList.listItems[int(rowIndex)].length > int(columnIndex)) {
				// var event:ListEvent = new ListEvent(ListEvent.ITEM_DOUBLE_CLICK, false, false, int(columnIndex), int(rowIndex));
				// return String(child.dispatchEvent(event));
				var cell:Object = dgContentList.listItems[int(rowIndex)][int(columnIndex)];
				return String(cell.dispatchEvent(new MouseEvent(MouseEvent.DOUBLE_CLICK)));
			}
			return ErrorMessages.getError(ErrorMessages.ERROR_NO_CHILD_UICOMPONENT, [datagridId,rowIndex,columnIndex]);
		}

		/**
		 * Returns the data values of a column. The values are separated with "#;#"
		 * @param id the id of the Data Grid
		 * @param field the name of the column/field
		 */
		public function rawFlexDataGridFieldValuesForColumn(id:String, colIndex:String) : String {
			var result:String = "";
			try
			{
				var widget:Object = appTreeParser.getWidgetById(id);
				var provider:Object = widget.dataProvider;
				var values:Array = new Array();
				for (var row:int = 0; row<provider.length; row++) {
					var rowValues:Object = provider[row];
					var col:Object = widget.columns[parseInt(colIndex)];
					var value:Object = col.itemToLabel(rowValues);
					if ((value == null) || (value == "")) 
					{
						// col.itemToLabel might return empty string, thought it is reasonable to return empty datagrid cells too,
						// since there is a row in the provider.
						value = " ";
					}
					values.push(value);
				}
				result = values.join("#;#");
			}
			catch (e:Error)
			{
				// todo use standard err
				result = "ERROR: Widget '" + id + "': " + e.message;
			}
			return result;
		}

		/**
		 * Expand all elements in a tree
		 * @param id  the id of the Data Grid
		 * @return
		 */
		public function doFlexDataGridExpandAll(id:String):String {
			try {
				var widget:Object = appTreeParser.getWidgetById(id);
				var provider:Object = widget.dataProvider;
				
				var dp:Object=provider;
				var cursor:IHierarchicalCollectionViewCursor=dp.createCursor();
				var allOpen:Boolean = false;
				var maxDepth:Number = 4;
				while (!allOpen) {
					widget.validateNow();
					cursor=widget.dataProvider.createCursor();
					allOpen = true;
					while (!cursor.afterLast)
					{
						if (!widget.isItemOpen(cursor.current)) {
							widget.expandItem(cursor.current, true);
							allOpen = false;
						}
						cursor.moveNext();
					}
					maxDepth--;
					if (maxDepth <= 0)
						break;
				}
			}
			catch (e:Error) {
				trace("SFAPI-ERROR: Widget '" + id + "': " + e.message);
				return "ERROR: Widget '" + id + "': " + e.message;
			}
			return "";
		}

		/**
		 * Expands all tree items and searches for item with specified name and property value
		 * @param	id  The id of the Data Grid
		 * @param	args  Tree item name, item property, property value
		 * @return  True if item is found, false if not.
		 */
		public function doFlexDataGridSearchValue(id:String, args:String):String
		{
			try
			{
				var argsAr:Array = args.split(",");
				var searchWord:String = argsAr[0];
				var propertyName:String = argsAr[1];
				var propertyValue:String = argsAr[2];
				var checked:Array = new Array();
				var myTree:Object = appTreeParser.getWidgetById(id);
				// Clear selection and start from the start:
				myTree.selectedIndex = -1;
				while (checked.indexOf(myTree.selectedIndex) < 0)
				{
					// Not found, lets push the selected index to checked
					// array and continue if plausible.
					checked.push(myTree.selectedIndex);
					var found:Boolean = myTree.findString(searchWord);
					if (!found) 
					{
						// Nothing matched, all hope is lost:
						return "false";
					}
					var candidate:Object = myTree.selectedItem;
					if (candidate.hasOwnProperty(propertyName))
					{
						if (candidate[propertyName] == propertyValue)
						{
							// All matches and the item has been selected already
							return "true";
						}
					}
				}
			}
			catch (e:Error)
			{
				// TODO use error standard
				return "ERROR: Widget '" + id + "': " + e.message;
			}
			return "false";
		}

		/**
		 * Returns all the data of one (Advanced)DataGrid column.
		 * The returned value will have the following syntax for every row:
		 * If addExtraRowData = true: parentName#;#itemName#;#index
		 * If addExtraRowData = false: itemName
		 * String "#,#" will mark line break (= new row start)
		 * @param	id  Data grid id
		 * @param	field  Field index
		 * @param	addExtraRowData  Return extra data for each row
		 * @return
		 */
		public function rawFlexDataGridFieldAllValues(id:String, field:String, addExtraRowData:String):String {
			var result:String = "";
			try
			{
				var widget:Object = appTreeParser.getWidgetById(id);
				var provider:Object = widget.dataProvider;
				var dp:Object=provider;
				var cursor:IHierarchicalCollectionViewCursor=dp.createCursor(); // IViewCursor ?
				var itemName:String = "";
				var rowData:Array = new Array();
				var currentRow:String = "";
				var index:Number = 0;
				var fieldColumn:Object;
				if (field)
				{
					for each (var column:Object in widget.columns)
					{
						if (column.dataField == field)
						{
							fieldColumn = column;
							break;
						}
					}
					if (!fieldColumn)
					{
						return "FATAL ERROR: Could not find column for field '" + field + "' from widget '" + id + "'.";
					}
				}
				while (!cursor.afterLast)
				{
					currentRow = "";
					if (fieldColumn)
					{
						itemName = fieldColumn.itemToLabel(cursor.current);
					}
					else
					{
						itemName = widget.itemToLabel(cursor.current);
					}
					if (addExtraRowData == "true")
					{
						// Select only child nodes, not the branches. Get the parent name also
						if (!widget.isItemOpen(cursor.current)) 
						{
							currentRow = getParents(widget, fieldColumn, cursor.current) + itemName + "#;#" + index;
						}
					}
					else 
					{
						currentRow = itemName;
					}
					// Put the data to the array (if it contains something)
					if (currentRow.length > 0)
					{
						rowData.push(currentRow);
					}
					cursor.moveNext();
					index++;
				}
				// If the rowData contains something, join the values together using #,# as separator
				if (rowData.length > 0)
				{
					result = rowData.join("#,#");
				}
			}
			catch (e:Error)
			{
				result = result + " FATAL ERROR: Widget '" + id + "': " + e.message;
			}
			return result;
		}
		
		private function getParents(widget:Object, column:Object, element:Object):String
		{
			var parent:Object = widget.getParentItem(element);
			var parentName:String;
			if (column)
			{
				// Use column widget to label:
				parentName = column.itemToLabel(parent);
			}
			if (!parentName)
			{
				// Column not set or no label, let's try the widget:
				parentName = widget.itemToLabel(parent);
			}
			if (StringUtil.trim(parentName) == "") 
			{
				// No parents.. Sad :(
				return "";
			}
			if (parent == widget) 
			{
				// Reached the wanted "root element":
				return parentName + "#;#";
			}
			return getParents(widget, column, parent) + parentName + "#;#";
		}
		
		/**
		 * Get all values from a data grid
		 * @param	id  Data grid id
		 * @param	onlyVisible  Only values that are visible to user
		 * @return
		 */
		public function getFlexDataGridValues(id:String, onlyVisible:String="false"):String
		{
			var result:Array = new Array();
			var rowSeparator:String = "##ROW##";
			var itemSeparator:String = "##ITEM##";
			try
			{
				var widget:Object = appTreeParser.getWidgetById(id);
				var provider:Object = widget.dataProvider;
				for (var row:int = 0; row<provider.length; row++) 
				{
					var rowItem:Object = provider[row];
					for each (var column:Object in widget.columns) 
					{
						if (column.visible || onlyVisible == "false") 
						{
							var item:String = column.itemToLabel(rowItem);
							if (!item)
							{
								item = " ";
							}
							result.push(item);
						} 
						else 
						{
							break;
						}
					}
					result.push(rowSeparator);
				}
				if (result.length > 0) 
				{
					// Remove last rowSeparator to make parsing more sane:
					result.pop();
				}
			}
			catch (e:Error)
			{
				return "ERROR: Widget '" + id + "': " + e.message;
			}
			return result.join(itemSeparator);
		}
		
		/**
		 * Returns the count of columns in a data grid
		 * @param	id  Data grid id
		 * @param	onlyVisible  Only visible columns
		 * @return
		 */
		public function getFlexDataGridColCount(id:String, onlyVisible:String = "true"):String
		{
			var result:String;
			try
			{
				var widget:Object = appTreeParser.getWidgetById(id);
				var colCount:int = 0;
				for each (var candidate:Object in widget.columns)
				{
					if (onlyVisible == "true") {
						if (candidate.visible == true)
						{
							colCount = colCount + 1;
						}
					}
					else {
						colCount = colCount + 1;
					}
				}
				result = String(colCount);
			}
			catch (e:Error)
			{
				result = "ERROR: Widget '" + id + "': " + e.message;
			}
			return result;
		}
		
		/**
		 * Get list of column data fields
		 * @param	id  Data grid id
		 * @param	onlyVisible  Only visible columns
		 * @return
		 */
		public function getFlexDataGridColDataFields(id:String, onlyVisible:String = "true"):String
		{
			var result:String;
			result = "";
			try
			{
				var widget:Object = appTreeParser.getWidgetById(id);
				for each (var candidate:Object in widget.columns)
				{
					if (onlyVisible == "true") {
						if (candidate.visible == true)
						{
							result = result+String(candidate.dataField)+"|";
						}
					}
					else {
						result = result+String(candidate.dataField)+"|";
					}
				}
			}
			catch (e:Error)
			{
				result = "ERROR: Widget '" + id + "': " + e.message;
			}
			
			if (result.charAt(result.length-1) == "|") {
				result = result.substr(0, (result.length-1));
			}
			return result;
		}
	}
}
