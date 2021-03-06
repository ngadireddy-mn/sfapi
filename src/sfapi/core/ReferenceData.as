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
package sfapi.core
{
	public class ReferenceData
	{
		public static const SELENIUM_FLEX_API_VERSION:String = "0.28";
		
		public static const TRUE_STRING:String = "true";
		public static const FALSE_STRING:String = "false";
		
		public static const TODAY:Array = ["", "", "today"];
		
		public static const CHECKSTATE_UNCHECKED:int = 0;
		public static const CHECKSTATE_CHECKED:int = 1;
		public static const CHECKSTATE_NO_CHANGE:int = -1;
		public static const CHECKSTATE_UNKNOWN:int = 2;
		
		public static const ALERT_DESCRIPTION:String = "mx.controls::Alert";
		public static const CHECKBOX_DESCRIPTION:String = "mx.controls::CheckBox";
		public static const TRI_CHECKBOX_DESCRIPTION:String = "::ThreeStateCheckBox";
		public static const RADIOBUTTON_DESCRIPTION:String = "mx.controls::RadioButton";
		public static const BUTTON_DESCRIPTION:String = "mx.controls::Button";
		public static const COMBO_BOX_DESCRIPTION:String = "com.modeln.mx.controls::CMnComboBox";
		public static const CMNBUTTON_DESCRIPTION:String = "com.modeln.mx.controls::CMnButton";
		public static const CMNPOPUP_BUTTON_DESCRIPTION:String = "com.modeln.mx.controls::CMnPopUpButton";
		public static const ADVANCED_COMBO_BOX:String = "com.modeln.uix.controls::CMnAdvancedComboBox";
		public static const ACCORDION_DESCRIPTION:String = "mx.containers::Accordion";
		public static const BUTTONBAR_DESCRIPTION:String = "mx.controls::ButtonBar";
		public static const LINKBAR_DESCRIPTION:String = "mx.controls::LinkBar";
		public static const TOGGLEBUTTONBAR_DESCRIPTION:String = "mx.controls::ToggleButtonBar";
		public static const DATEFIELD_DESCRIPTION:String = "mx.controls::DateField";
		public static const DATECHOOSER_DESCRIPTION:String = "mx.controls::DateChooser";
		public static const TABNAVIGATOR_DESCRIPTION:String = "mx.containers::TabNavigator";
		public static const LISTBASECONTENTHOLDER_DESCRIPTION:String = "mx.controls.listClasses::ListBaseContentHolder";
		public static const MENUBAR_DESCRIPTION:String = "mx.controls::MenuBar";
		
		public static const MILLISECONDS_IN_DAY:int = 86400000;
		
		public function ReferenceData()
		{
		}
	}
}