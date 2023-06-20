disableSerialization;
#include "..\..\database\factionParameters.sqf"

//Create GUI
cutText ["", "BLACK FADED", 100];
createDialog "playerRespawnMenu";

//Specify all GUI items
//Define a comboBox foreach faction
private _mainDisplay = (findDisplay 8000);
private _buttonRespawnStart = _mainDisplay displayCtrl 8200;
private _buttonRespawnLeader = _mainDisplay displayCtrl 8201;

//Faction params
bluFaction = missionNamespace getVariable "bluforFaction";
indFaction = missionNamespace getVariable "independentFaction";

//Function params
_buttonRespawnStart ctrlAddEventHandler[ "ButtonClick", 
	{ 
		if (player getVariable "sideBeforeDeath" == "independent") then 
		{
			//Independent
			player setPos ([getPos initCityLocation, 1, 10, 3, 0, 20, 0] call BIS_fnc_findSafePos);
		} else 
		{
			//Blufor
			player setPos ([initBlueforLocation, 1, 10, 3, 0, 20, 0] call BIS_fnc_findSafePos);
		};
		["Respawn on start position", format ["Year %1", date select 0], mapGridPosition player] spawn BIS_fnc_infoText;

		//Initialize player
		[] call doInitializePlayer;
		
		//Close dialog
		(findDisplay 8000) closeDisplay 1;
	}];

_buttonRespawnLeader ctrlAddEventHandler[ "ButtonClick", 
	{ 
		
		//teleport player to another player with same side
		//Respawn on teamleader
		_tempLeader = ((allPlayers - [player]) select {alive _x && side _x isEqualTo (side player) && _x getVariable "role" == "leader"});
		
		//If no teamleader is avalaible respawn on another player
		if (count _tempLeader == 0) then 
		{
			_tempLeader = ((allPlayers - [player]) select {alive _x && side _x isEqualTo (side player)});
		};

		//SetPlayer position
		_tempPos = getPos (_tempLeader select 0);
		player setPos [_tempPos select 0, _tempPos select 1];
		["Respawn on teamleader", format ["Year %1", date select 0], mapGridPosition player] spawn BIS_fnc_infoText;

		//Initialize player
		[] call doInitializePlayer;
		
		//Close dialog
		(findDisplay 8000) closeDisplay 1;
	}];


//Disable space button in dialog
waituntil {!(IsNull (findDisplay 8000))};
_keyDown = (findDisplay 8000) displayAddEventHandler ["KeyDown", {
	params ["_control", "_dikCode", "_shift", "_ctrl", "_alt"];

	private _handled = false;

	switch (_dikCode) do {
		case 1;
		case 57: {
			// case 57 for SPACE -> https://community.bistudio.com/wiki/DIK_KeyCodes
			// open your dialog
			_control closeDisplay 1;
			
			//Respawn on start position by default
			if (player getVariable "sideBeforeDeath" == "independent") then 
			{
				//Independent
				player setPos ([getPos initCityLocation, 1, 10, 3, 0, 20, 0] call BIS_fnc_findSafePos);
			} else 
			{
				//Blufor
				player setPos ([initBlueforLocation, 1, 10, 3, 0, 20, 0] call BIS_fnc_findSafePos);
			};
			["Respawn on start position", format ["Year %1", date select 0], mapGridPosition player] spawn BIS_fnc_infoText;

			//Initialize player
			[] call doInitializePlayer;
		};
	};

	_handled
}];

doInitializePlayer = {
		//Enable gameplay for player
		player allowdamage true;
		player enableSimulationGlobal true;
		player hideObjectGlobal false;
		cutText ["", "BLACK IN", 5];

		//Remove player name from the dead player's list
		_deadPlayerList = missionNamespace getVariable "deadPlayer";
		_deadPlayerList = _deadPlayerList - [name player];
		missionNamespace setVariable ["deadPlayer", _deadPlayerList, true];
};