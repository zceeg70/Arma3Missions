/* 
    Filename: Simple ParaDrop Script v0.8 Beta eject.sqf
    Author: Beerkan:
    Additional contributions cobra4v320
    
    Description:
     A simple paradrop script that ejects all units assigned as cargo onboard, including players and AI (excluding crew) regardless of group assignments, side etc.
     If you're in the aircraft you're getting thrown out.

    Parameter(s):
    0: VEHICLE  - vehicle that will be doing the paradrop (object)
    1: ALTITUDE - (optional) the altitude where the group will open their parachute (number)

    Example:
    _drop = [vehicle, altitude] execVM "eject.sqf"
*/

if (!isServer && hasInterface) exitWith {};
private ["_vehicle","_paras","_dir"];
_vehicle = _this select 0;
// _vehicle limitSpeed 110;
_vehicleHeight = getPosATL _vehicle select 1;
// _chuteheight = if ( count _this > 1 ) then { _this select 1 } else { 250 }; 
_paras = assignedCargo _vehicle;
_dir = direction _vehicle;
[_paras] allowGetIn false; 
hintSilent "Stand Up";
sleep 6; 

paraLandSafe = 
{
    private ["_unit","_vehicle"];
	systemChat "parasLandSafe called";
    _unit = _this select 0;
	_vehicle = _this select 1;
    (vehicle _unit) allowDamage false;// Set parachute invincible to prevent damage on exit
	waitUntil {animationState _unit == "para_pilot"}; // Wait until parachute deployed
	
	_light = "Chemlight_red" createVehicle [0,0,0]; 
	_light attachTo [vehicle _unit,[0,-0.03,0.07],"LeftFoot"];  
	_light setVectorDirAndUp [[0,0,1],[0,1,0]]; // magic numbers?
	// Allow damamge whilst trooper is falling:
	_unit allowDamage true; 
	_vehicle allowDamage true; // not sure if needed? 
	
    waitUntil {getPosATL _unit select 2 < 4 }; // Wait until unit is x metres above terrain
    _unit allowDamage false; // disable damage on landing 
	
	waitUntil {isTouchingGround _unit || (position _unit select 2) < 1 }; // Wait until unit is on the ground
	detach _light; // chemlight falls off
    _unit action ["EJECT", vehicle _unit]; // Discard parachute.
    _unit setvelocity [0,0,0]; 
    sleep 1;// Para Units sometimes get damaged on landing. Wait to prevent this.
    _unit allowDamage true;
	// _null  = _player addAction ["<t color='#FF0000'>Turn OFF Light</t>","chemlightOff.sqf",[_light,_unit]];
};

DeployChute = 
{
	private["_unit","_altitude","_dir"];
	_x = _this select 0;
	_altitude = _this select 1;
	_dir = _this select 2;
	// systemChat "b called";
	// "static line jump":  - Chutes open after 10 metre fall from aircraft. 
	waitUntil {(position _x select 2) <= (_altitude - 10)}; 
	if (vehicle _x != _x) exitWith {};
	// _chute = createVehicle ["Steerable_Parachute_F", position _x, [], ((_dir)- 5 + (random 10)), 'FLY'];
	// _chute = createVehicle ["NonSteerable_Parachute_F", position _x, [], ((_dir)- 5 + (random 10)), 'FLY'];
	_chute = createVehicle ["NonSteerable_Parachute_F", position _x, [], ((_dir)- 5 + (random 10)), 'FLY'];
	//I_Parachute_02_F,O_Parachute_02_F,B_Parachute_02_F // DO NOT USE FOR TROOPS
	_chute setPos (getPos _x);
	
	if (isPlayer _x) then {
		[_chute, {player moveInDriver _this}] remoteExec ["bis_fnc_call", _x];
	} else {
		_x moveInDriver _chute;
	};
	// _x assignAsDriver _chute;
	// _x moveInDriver _chute;
	_x allowDamage true;
};

{
	systemChat "get out called";
    _x disableCollisionWith _vehicle;
    _x allowDamage false;
    unassignVehicle _x;
    _x action ["GETOUT", _vehicle];
    _x setDir ((_dir - 180) + 90);
	[_x, (position _vehicle select 2),_dir] spawn DeployChute;
    sleep 1.2;//So units are not too far spread out when they land.
} forEach _paras;


// } forEach _paras;

{ 
  [_x, _vehicle] spawn paraLandSafe;
} forEach _paras;