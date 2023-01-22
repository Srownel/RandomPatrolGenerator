disableSerialization;
#include "..\database\factionParameters.sqf"
#include "..\database\missionParameters.sqf"
#include "..\database\arsenalLibrary.sqf"

//Create GUI
createDialog "PlayerLoadoutSetup";

//Specify all GUI items
//Define a comboBox foreach faction
private _mainDisplay = (findDisplay 7000);
private _comboBoxClassSelection = _mainDisplay displayCtrl 7100;
private _buttonArsenal = _mainDisplay displayCtrl 7201;
private _buttonSave = _mainDisplay displayCtrl 7202;
private _buttonLoad = _mainDisplay displayCtrl 7203;

//Faction params
bluFaction = missionNamespace getVariable "bluforFaction";
indFaction = missionNamespace getVariable "independentFaction";

//Function params
firstOpen = true;

//Specify all GUI content and button actions
_comboBoxClassSelection ctrlAddEventHandler[ "LBSelChanged", 
	{
		if (!firstOpen) then 
		{
			_mainDisplay = (findDisplay 7000);
			_comboBoxClassSelection = _mainDisplay displayCtrl 7100;

			_listOfAvalaibleRole =[];
		
			if (player getVariable "sideBeforeDeath" == "independent") then 
			{
				//Independent
				_listOfAvalaibleRole = [indFaction] call setupRoleSwitchToList;
				_role = (_listOfAvalaibleRole select parseNumber ((_comboBoxClassSelection lbData (lbCurSel _comboBoxClassSelection))));
				[VA1, player, indFaction ,_role] call switchToRole;
			} else 
			{
				//Blufor
				_listOfAvalaibleRole = [bluFaction] call setupRoleSwitchToList;
				_role = (_listOfAvalaibleRole select parseNumber ((_comboBoxClassSelection lbData (lbCurSel _comboBoxClassSelection))));
				[VA2, player, bluFaction , _role] call switchToRole;
			};
		}
		else 
		{
			//Allow player to change stuff
			firstOpen = false;
		};
	}];

_buttonArsenal ctrlAddEventHandler[ "ButtonClick", 
	{ 
		hint "ButtonClicked";
		(findDisplay 7000) closeDisplay 1;
		[] execVM 'database\openArsenal.sqf';
	}];

_buttonSave ctrlAddEventHandler[ "ButtonClick", 
	{ 
		player setVariable ["spawnLoadout", getUnitLoadout player];
		cutText ["Loadout saved", "PLAIN", 0.3];
	}];

_buttonLoad ctrlAddEventHandler[ "ButtonClick", 
	{ 
		player setUnitLoadout (player getVariable "spawnLoadout");
		cutText ["Loadout loaded", "PLAIN", 0.3];
	}];


//get list of avalaible role for player's faction
_listOfAvalaibleRole =[];
if (player getVariable "sideBeforeDeath" == "independent") then 
{
	//Independent
	_listOfAvalaibleRole = [indFaction] call setupRoleSwitchToList;

} else 
{
	//Blufor
	_listOfAvalaibleRole = [bluFaction] call setupRoleSwitchToList;
};

//Define list of role in the combo box
_currentComboBox = _comboBoxClassSelection;
{
	_currentComboBox lbAdd format ["%1", _x];
	_currentComboBox lbSetData [(lbSize _currentComboBox)-1, format ["%1",(lbSize _currentComboBox)-1]];
} foreach _listOfAvalaibleRole;

//Default value of role combo box 
_comboBoxClassSelection lbSetCurSel (_listOfAvalaibleRole find (player getVariable "role")); //Actual Warfare

//Disable space button in dialog
waituntil {!(IsNull (findDisplay 7000))};
_keyDown = (findDisplay 7000) displayAddEventHandler ["KeyDown", {
	params ["_control", "_dikCode", "_shift", "_ctrl", "_alt"];

	private _handled = false;

	switch (_dikCode) do {
		case 57: {
			// case 1 for ESC -> https://community.bistudio.com/wiki/DIK_KeyCodes
			// open your dialog
			_control closeDisplay 1;
			[[], 'GUI\initPlayerLoadoutSetup.sqf'] remoteExec ['BIS_fnc_execVM', player];
		};
	};

	_handled
}];