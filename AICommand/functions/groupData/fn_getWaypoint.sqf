/*
	Author: [SA] Duda

	Description:
	Get a waypoint for a group

	Parameter(s):
	_this select 0: GROUP - group to get waypoint
	_this select 1: NUMBER - waypoint index

	Returns: 
	ARRAY: [
		NUMBER: waypoint index
		POSITION: waypoint world position,
		BOOLEAN: waypoint disabled
	]
*/

private ["_group","_waypointIndex"];

_group = param [0];
_waypointIndex = param [1];

private ["_waypointsArray"];

_waypointsArray = (_group getVariable ["AIC_Waypoints",[0,[]]]) select 1;
_waypointsArray select _waypointIndex;