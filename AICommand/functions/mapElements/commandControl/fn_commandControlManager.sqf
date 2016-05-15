#include "..\..\functions.h"

/*
	Author: [SA] Duda

	Description:
	Command Control Manager

	Parameter(s):
	None
		
	Returns: 
	Nothing
*/

["ALL_EAST"] call AIC_fnc_createCommandControl;
["ALL_WEST"] call AIC_fnc_createCommandControl;
["ALL_GUER"] call AIC_fnc_createCommandControl;


AIC_fnc_addWaypointsActionHandler = {
	params ["_group","_groupControlId","_params"];
	AIC_fnc_setGroupControlAddingWaypoints(_groupControlId,true);
};

["Add Waypoints",[],AIC_fnc_addWaypointsActionHandler] call AIC_fnc_addCommandMenuAction;


// Manage updates to group color

[] spawn {
	private ["_currentControlColor","_waypoints","_currentWpRevision","_groupControls","_group","_groupControlId"];
	while {true} do {
		_groupControls = AIC_fnc_getGroupControls();
		{
			_groupControlId = _x;
			_group = AIC_fnc_getGroupControlGroup(_groupControlId);
			_currentControlColor = AIC_fnc_getGroupControlColor(_groupControlId);  
			_currentGroupColor = [_group] call AIC_fnc_getGroupColor;
			if((_currentControlColor select 0) != (_currentGroupColor select 0)) then {
				[_groupControlId,"COLOR_CHANGED",[]] call AIC_fnc_groupControlEventHandler;
			};
			
			_currentGroupType = AIC_fnc_getGroupControlType(_groupControlId); 
			_groupType = _group call AIC_fnc_getGroupIconType;
			if(_groupType != _currentGroupType) then {
				[_groupControlId,"REFRESH_GROUP_ICON",[]] call AIC_fnc_groupControlEventHandler;
			};
			
		} forEach _groupControls;
		sleep 2;
	};
};

AIC_fnc_setGroupColorActionHandler = {
	params ["_group","_groupControlId","_params"];
	_params params ["_color"];
	[_group,_color] call AIC_fnc_setGroupColor;
	AIC_fnc_setGroupControlColor(_groupControlId,_color);
	[_groupControlId,"REFRESH_GROUP_ICON",[]] call AIC_fnc_groupControlEventHandler;
	[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;
	[_groupControlId,"REFRESH_ACTIONS",[]] call AIC_fnc_groupControlEventHandler;
	hint ("Color set to " + toLower (_color select 0));
};

["Red",["Set Group Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_RED]] call AIC_fnc_addCommandMenuAction;
["Blue",["Set Group Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_BLUE]] call AIC_fnc_addCommandMenuAction;
["Green",["Set Group Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_GREEN]] call AIC_fnc_addCommandMenuAction;
["Black",["Set Group Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_BLACK]] call AIC_fnc_addCommandMenuAction;
["White",["Set Group Color"],AIC_fnc_setGroupColorActionHandler,[AIC_COLOR_WHITE]] call AIC_fnc_addCommandMenuAction;


AIC_fnc_setGroupBehaviourActionHandler = {
	params ["_group","_groupControlId","_params"];
	_params params ["_mode"];
	[_group,_mode] remoteExec ["setBehaviour", leader _group]; 
	hint ("Behaviour set to " + toLower _mode);
};

["Careless",["Set Group Behaviour"],AIC_fnc_setGroupBehaviourActionHandler,["CARELESS"]] call AIC_fnc_addCommandMenuAction;
["Safe",["Set Group Behaviour"],AIC_fnc_setGroupBehaviourActionHandler,["SAFE"]] call AIC_fnc_addCommandMenuAction;
["Aware",["Set Group Behaviour"],AIC_fnc_setGroupBehaviourActionHandler,["AWARE"]] call AIC_fnc_addCommandMenuAction;
["Combat",["Set Group Behaviour"],AIC_fnc_setGroupBehaviourActionHandler,["COMBAT"]] call AIC_fnc_addCommandMenuAction;
["Stealth",["Set Group Behaviour"],AIC_fnc_setGroupBehaviourActionHandler,["STEALTH"]] call AIC_fnc_addCommandMenuAction;
		
AIC_fnc_setGroupCombatModeActionHandler = {
	params ["_group","_groupControlId","_params"];
	_params params ["_mode","_modeLabel"];
	[_group,_mode] remoteExec ["setCombatMode", leader _group]; 
	hint ("Combat mode set to " + toLower _modeLabel);
};

["Never fire",["Set Group Combat Mode"],AIC_fnc_setGroupCombatModeActionHandler,["BLUE","Never fire"]] call AIC_fnc_addCommandMenuAction;
["Hold fire - defend only",["Set Group Combat Mode"],AIC_fnc_setGroupCombatModeActionHandler,["GREEN","Hold fire - defend only"]] call AIC_fnc_addCommandMenuAction;
["Hold fire, engage at will",["Set Group Combat Mode"],AIC_fnc_setGroupCombatModeActionHandler,["WHITE","Hold fire, engage at will"]] call AIC_fnc_addCommandMenuAction;
["Fire at will",["Set Group Combat Mode"],AIC_fnc_setGroupCombatModeActionHandler,["YELLOW","Fire at will"]] call AIC_fnc_addCommandMenuAction;
["Fire at will, engage at will",["Set Group Combat Mode"],AIC_fnc_setGroupCombatModeActionHandler,["RED","Fire at will, engage at will"]] call AIC_fnc_addCommandMenuAction;
		
AIC_fnc_clearAllWaypointsActionHandler = {
	params ["_group","_groupControlId","_params"];
	[_group] call AIC_fnc_disableAllWaypoints;	
	[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;
	hint ("All waypoints cleared");
};

["Confirm Cancel All",["Clear All Waypoints"],AIC_fnc_clearAllWaypointsActionHandler] call AIC_fnc_addCommandMenuAction;		

AIC_fnc_remoteControlActionHandler = {
	params ["_group","_groupControlId","_params"];
	private ["_keyDownHandler","_rcUnit"];
	_rcUnit = leader _group;
	player remoteControl _rcUnit;
	(vehicle _rcUnit) switchCamera "External";
	player setVariable ["AIC_Remote_Control_Unit",_rcUnit];
	openMap false;
	["RemoteControl",["","Press DELETE to Exit Remote Control"]] call BIS_fnc_showNotification;
	_keyDownHandler = AIC_MAIN_DISPLAY displayAddEventHandler ["KeyDown", "if(_this select 1 == 211) then { player setVariable ['AIC_Remote_Control_Unit',objNull] }" ];
	while {!isNull (player getVariable ["AIC_Remote_Control_Unit",objNull])} do {
		private ["_rcUnit"];
		_rcUnit = player getVariable ["AIC_Remote_Control_Unit",objNull];
		if(!alive _rcUnit || !alive player) then {
			player setVariable ['AIC_Remote_Control_Unit',objNull]
		} else {
			sleep 1;
		};
	};
	AIC_MAIN_DISPLAY displayRemoveEventHandler ["KeyDown",_keyDownHandler];
	player remoteControl objNull;
	(vehicle player) switchCamera cameraView;
	objNull remoteControl _rcUnit;
	["RemoteControl",["","Remote Control Terminated"]] call BIS_fnc_showNotification;
};

["Remote Control",[],AIC_fnc_remoteControlActionHandler,[],"NONE",{
	params ["_group"];
	private ["_canControl"];
	_canControl = true;
	{
		if( _x != vehicle _x ) then {
			_canControl = false;
		};
		if( isPlayer _x ) then {
			_canControl = false;
		};
	} forEach (units _group);
	_canControl;
}] call AIC_fnc_addCommandMenuAction;

AIC_fnc_assignVehicleActionHandler = {
	params ["_group","_groupControlId","_selectedVehicle","_params"];
	if(!isNull _selectedVehicle) then {
		private ["_vehicleName","_assignedVehicles","_vehicleSlotsToAssign","_maxSlots","_vehicleRoles"];
		private ["_unitIndex","_countOfSlots","_vehicleToAssign"];
		[_group,_selectedVehicle] remoteExec ["addVehicle", leader _group];
		_assignedVehicles = [_group] call AIC_fnc_getGroupAssignedVehicles;
		_assignedVehicles pushBack _selectedVehicle;
		[_group,_assignedVehicles] call AIC_fnc_setGroupAssignedVehicles;
		_vehicleSlotsToAssign = [];
		_maxSlots = 0;
		{
			_vehicleRoles = [_x] call BIS_fnc_vehicleRoles;
			if(count _vehicleRoles > _maxSlots) then {
				_maxSlots = count _vehicleRoles;
			};
		} forEach _assignedVehicles;
		if(_maxSlots > 0) then {
			for "_i" from 0 to (_maxSlots-1) do {
				{
					_vehicleRoles = [_x] call BIS_fnc_vehicleRoles;
					if(count _vehicleRoles > _i) then {
						_vehicleSlotsToAssign pushBack [_x,_vehicleRoles select _i];
					};
				} forEach _assignedVehicles;
			};
		};
		_unitIndex = 0;
		_countOfSlots = count _vehicleSlotsToAssign;
		{
			if(_countOfSlots > _unitIndex) then {
				_vehicleToAssign = (_vehicleSlotsToAssign select _unitIndex) select 0;
				_role = (_vehicleSlotsToAssign select _unitIndex) select 1;
				[_x,_vehicleToAssign,_role] remoteExec ["AIC_fnc_getInVehicle", _x];
			};
			_unitIndex = _unitIndex + 1;
		} forEach (units _group);
		_vehicleName = getText (configFile >> "CfgVehicles" >> typeOf _selectedVehicle >> "displayName");
		hint ("Vehicle assigned: " + _vehicleName);
	} else {
		hint ("No vehicle assigned");
	};
};

["Assign Vehicle",[],AIC_fnc_assignVehicleActionHandler,[],"VEHICLE"] call AIC_fnc_addCommandMenuAction;		

AIC_fnc_unassignVehicleActionHandler = {
	params ["_group"];
	{
		[_group,_x] remoteExec ["leaveVehicle", leader _group];
	} forEach ([_group] call AIC_fnc_getGroupAssignedVehicles);
	[_group,nil] call AIC_fnc_setGroupAssignedVehicles;
	hint ("All vehicles unassigned");
};

["Unassign All Vehicle(s)",[],AIC_fnc_unassignVehicleActionHandler,[],"NONE",{
	params ["_group"];
	private ["_canUnassign"];
	_canUnassign = false;
	_canUnassign = (count ([_group] call AIC_fnc_getGroupAssignedVehicles) > 0);
	{
		if( _x != vehicle _x ) then {
			_canUnassign = true;
		};
	} forEach (units _group);
	_canUnassign;
}] call AIC_fnc_addCommandMenuAction;		

AIC_fnc_landActionHandler = {
	params ["_group","_groupControlId","_selectedPosition"];
	if(count _selectedPosition > 0) then {
		_hasAir = false;
		{
			if(_x isKindOf "Air") then {
				_hasAir = true;
			};
		} forEach ([_group] call AIC_fnc_getGroupAssignedVehicles);
		if(_hasAir) then {
			[_group] call AIC_fnc_disableAllWaypoints;	
			[_group, [_selectedPosition,false,"MOVE","{ if((vehicle _x) isKindOf 'Air') then { (vehicle this) land 'LAND'; }; } forEach (units (group this))"]] call AIC_fnc_addWaypoint;
			[_groupControlId,"REFRESH_WAYPOINTS",[]] call AIC_fnc_groupControlEventHandler;
		};
	};
};

["Land",[],AIC_fnc_landActionHandler,[],"POSITION",{
	params ["_group"];
	_hasAir = false;
	{
		if(_x isKindOf "Air") then {
			if(((position _x) select 2) > 1) then {
				_hasAir = true;
			};
		};
	} forEach ([_group] call AIC_fnc_getGroupAssignedVehicles);
	_hasAir;	
}] call AIC_fnc_addCommandMenuAction;



if(hasInterface) then {
		
	AIC_fnc_commandControlDrawHandler = {
	
		//_temp = diag_tickTime;
		
		private ["_commandControls","_inputControls","_actionControlShown"];
		
		_commandControls = AIC_fnc_getCommandControls();
		_inputControls = AIC_fnc_getInputControls();
		
		// Draw all visible input controls
		{
			if(AIC_fnc_getMapElementVisible(_x)) then {
				[_x] call AIC_fnc_drawInputControl;
			};
		} forEach _inputControls;
		
		// Draw command controls
		
		{
			// Move all command controls to the background if an action control is visible
		
			/*
			if(_actionControlShown) then {
					if(AIC_fnc_getMapElementForeground(_x)) then {
						[_x,false] call AIC_fnc_setMapElementForeground;
						[_x,false] call AIC_fnc_setMapElementEnabled;
					};
			} else {
					if(!(AIC_fnc_getMapElementForeground(_x))) then {
						[_x,true] call AIC_fnc_setMapElementForeground;
						[_x,true] call AIC_fnc_setMapElementEnabled;
					};
			};
			*/
			
			[_x] call AIC_fnc_drawCommandControl;
		} forEach _commandControls;
		
		//_temp2 = diag_tickTime;
		
	    // hint str (_temp2 - _temp);
			
	};

	// Setup UI event handlers

	[] spawn {
		waitUntil {!isNull AIC_MAP_CONTROL};
		AIC_MAP_CONTROL ctrlAddEventHandler ["Draw", "_this call AIC_fnc_commandControlDrawHandler" ];
	};
	
	// Check for command control group controls revision changes
	[] spawn {
		private ["_commandControls","_groupsRevision","_currentRevision"];
		while {true} do {
			_commandControls = AIC_fnc_getCommandControls();
			{
				_groupsRevision = AIC_fnc_getCommandControlGroupsRevision(_x);
				_currentRevision = AIC_fnc_getCommandControlGroupsControlsRevision(_x);
				if(_groupsRevision != _currentRevision) then {
					[_x,"REFRESH_GROUP_CONTROLS",[]] call AIC_fnc_commandControlEventHandler;
				};
			} forEach _commandControls;
			sleep 2;
		};
	};
	
};

if(!isDedicated && hasInterface) then {
	[] spawn {
		while {true} do {
			if(!isNull player && isPlayer player) then {
				if!( player getVariable ["AIC_Command_Control_Added",false] ) then {
					if(side player == west) then {
						["ALL_WEST",true] call AIC_fnc_showCommandControl;
					};
					if(side player == east) then {
						["ALL_EAST",true] call AIC_fnc_showCommandControl;
					};
					if(side player == resistance) then {
						["ALL_GUER",true] call AIC_fnc_showCommandControl;
					};
					player setVariable ["AIC_Command_Control_Added",true];
				};
			};
			sleep 2;
		};
	};
};

if(isServer) then {
	
	[] spawn {

		while {true} do {
			{
				if(side _x == east) then {
					["ALL_EAST",_x] call AIC_fnc_commandControlAddGroup;
				};
				if(side _x == west) then {
					["ALL_WEST",_x] call AIC_fnc_commandControlAddGroup;
				};
				if(side _x == resistance) then {
					["ALL_GUER",_x] call AIC_fnc_commandControlAddGroup;
				};
			} forEach allGroups;
			sleep 10;
		};
		
	};

	// Check for empty groups associated with command controls and remove them
	
	[] spawn {
		private ["_commandControls","_commandControlId","_groups","_groupControls","_group","_units"];
		while {true} do {
			_commandControls = AIC_fnc_getCommandControls();
			{
				_commandControlId = _x;
				_groups = AIC_fnc_getCommandControlGroups(_commandControlId);
				{
					_group = _x;
					_units = [];
					{if (alive _x) then {_units = _units + [_x]}} foreach (units _group);
					if(count _units == 0) then {
						[_commandControlId, _group] call AIC_fnc_commandControlRemoveGroup;
					};			
				} forEach _groups;
			} forEach _commandControls;
			sleep 10;
		};
	};
	
	// Manage group waypoints

	[] spawn {
		while {true} do {
			private ["_group","_groupControl","_lastWpRevision","_groupWaypoints","_groupControlWaypoints","_currentWpRevision","_groupControlWaypointArray","_wp","_goCodeWpFound","_wpType","_waitForCode","_wpActionScript"];
			{
				_group = _x;

				_lastWpRevision = _group getVariable ["AIC_Server_Last_Wp_Revision",0];
				_groupWaypoints = waypoints _group;
				_groupControlWaypoints = [_group] call AIC_fnc_getAllActiveWaypoints;
				_currentWpRevision = _groupControlWaypoints select 0;
				_groupControlWaypointArray = _groupControlWaypoints select 1;
				
				_waitForCode = _group getVariable ["AIC_Wait_For_Go_Code","NONE"];
				if(_waitForCode == "NONE") then {
					
					if( _currentWpRevision != _lastWpRevision) then {
						//hint "changing waypoints";
						while {(count (waypoints _group)) > 0} do { deleteWaypoint ((waypoints _group) select 0); };
						_goCodeWpFound = false;
						{
							if(!_goCodeWpFound) then {
								_wpType = _x select 3;
								if(count _x > 4) then {
									_wpActionScript = _x select 4;
								} else {
									_wpActionScript = "";
								};
								_wp = _group addWaypoint [_x select 1, 0];
								if(_wpType == "ALPHA" || _wpType == "BRAVO") then {
									_goCodeWpFound = true;
									_wp setWaypointStatements ["true", "[group this, "+str (_x select 0)+"] call AIC_fnc_disableWaypoint; [group this,'"+_wpType+"'] call AIC_fnc_waitForWaypointGoCode;"];
								} else {
									_wp setWaypointStatements ["true", "[group this, "+str (_x select 0)+"] call AIC_fnc_disableWaypoint;" + _wpActionScript];
								};
							};
						} forEach _groupControlWaypointArray;
						if(count (waypoints _group)==0) then {
							_group addWaypoint [position leader _group, 0];
						};
						_group setVariable ["AIC_Server_Last_Wp_Revision",_currentWpRevision];
					};
					
				};

			} forEach allGroups;
			sleep 2;
		};
	};
};

