private["_location","_position","_locaname"];
// =========================================================================================================
//	Define Random Location
// =========================================================================================================

_location = "town" call PO3_fnc_getNewPos;

PO3_TASK__DIF	= PO3_param_missionskill;
PO3_TASK__POS	= _location select 0;
PO3_TASK__IDD	= format["%1%2:%3",round(PO3_TASK__POS select 0),round(PO3_TASK__POS select 1),(round random 99)];

_position = [PO3_TASK__POS,0,0,false] call PO3_fnc_getPos;
_locaname = _location select 1;
_locRadis = _location select 2;

// =========================================================================================================
//	Create Tasks
// =========================================================================================================

[ format["TASK%1",PO3_TASK__IDD],
	format[localize "STR_PO3_M15_TITLE",_locaname],
	format[localize "STR_PO3_M15_DESCR",PO3_TASK__IDD,_locaname,(PO3_side_3 select 2)],
	(PO3_side_1 select 0),
	[format["MRKR%1",PO3_TASK__IDD],_position,"mil_objective",(PO3_side_1 select 0) call PO3_fnc_getUnitMarkerColour,format[localize "STR_PO3_M15_TITLE",_locaname]],
	"assigned",
	_position,
	format[localize "STR_PO3_M15_TITLE",_locaname]
] call PO3_fnc_addTask;

// =========================================================================================================
//	WAIT UNTIL ARRIVAL
// =========================================================================================================
PO3_TOTAL_UNITS = [];
PO3_TOTAL_VEHICLES = [];

for "_i" from 1 to 2 do {
	_grp = nil;
	_grp = [ _position, (PO3_side_3 select 0), "EN_PatrolGroup0", 20 ] call PO3_fnc_createGroup;
	if !(isNil "_grp") then {
		[ _position, _grp ] spawn PO3_fnc_groupDefendPos;
		PO3_TOTAL_UNITS = PO3_TOTAL_UNITS + (units _grp);
		sleep 1;
	};
};

waitUntil{ sleep 1; count([_position,100,(PO3_side_3 select 0),["CAManBase"]] call PO3_fnc_getNearbyUnits) <= 3 };

[(PO3_side_1 select 0),"SIDE",format[localize "STR_PO3_M15_MSG_1",(PO3_side_3 select 2)]] call PO3_fnc_sendChat;

// =========================================================================================================
//	Create Hostiles
// =========================================================================================================

_spawnAmbush = {
	private["_position","_b","_ingress","_grp"];

	_position = _this select 0;
	_b = _this select 1;
	_ingress = [_position ,[400,500],random 360,false] call PO3_fnc_getPos;

	_minAngle = _infAttackAngle - 25;
	if(_minAngle < 0) then {_minAngle = 360 + _minAngle;};
	_maxAngle = (_infAttackAngle + 25) mod 360;
	_infAngles = [_minAngle,_infAttackAngle,_maxAngle];
	
	_vehClass = [];
	
	// <= 3 Is easy with high number or ultra with low player count
	// <= 6 Is High with 15 players or ultra with 10
	// >6 is high with large amount of players / ultra with 11 players
	
	if(_b <= 3) then { _vehClass set [count _vehClass,4]; };
	if(_b >= 3 && _b < 9)  then { _vehClass set [count _vehClass,5]; };
	if(_b >= 6) then { _vehClass set [count _vehClass,3]; };

	for "_i" from 0 to _b do {
		_grp = nil;
		_grp = [ _ingress, (PO3_side_3 select 0), format["EN_GroupForce_%1",round random 4], 50 ] call PO3_fnc_createGroup;
		if !(isNil "_grp") then {
			_nextIngressAngle = random _infAngles;
			_ingress set[2, _nextIngressAngle];
			[ _position, _grp ] spawn PO3_fnc_groupAttackPos;
			PO3_TOTAL_UNITS = PO3_TOTAL_UNITS + (units _grp);
			sleep 1;
		};
	};

	// Spawn vehicles
	// Count should be random, between 0 and a number dependent on _b
	// Random number at least 1, max 10.
	// minimum vehicles is difficulty dependent
	_minVehicles = round(_b / 4);
	_maxVehicles = ceil(_b);
	_midVehicles = ceil((_maxVehicles + _minVehicles)/2) min _maxVehicles;
	
	_vehicleCount = (floor(random [_minVehicles _maxVehicles _midVehicles])) min 10;
	
	for "_i" from 0 to _vehicleCount do {
		if(random 1 > 0.5 || _b > 6) then {
			_class = _vehClass call PO3_fnc_getVehicleTypes;
			if(count _class > 0) then {
				_ingress = [_position ,[1000,1200],random 360,false] call PO3_fnc_getPos;
				_veh = ([ _ingress,_class call PO3_fnc_getArrayRandom,random 360,100,(PO3_side_3 select 0)] call PO3_fnc_createVehicle) select 0;
				if !(isNil "_veh") then {
					[ _position, _veh ] spawn PO3_fnc_groupAttackPos;
					PO3_TOTAL_UNITS = PO3_TOTAL_UNITS + (units _veh);
					PO3_TOTAL_VEHICLES set [ count PO3_TOTAL_VEHICLES, vehicle (leader _veh) ];
				};
			};
		};
	};

	_equation = round(((playersNumber(PO3_side_1 select 0) max 1)*PO3_param_missionskill max 1) * abs(log(( (playersNumber(PO3_side_1 select 0) max 1)/2)/64)));
	if(random 1 > 0.6 || _equation >= 10) then { [_position,(PO3_side_3 select 0),([7] call PO3_fnc_getVehicleTypes) call PO3_fnc_getArrayRandom,format["EN_GroupForce_%1",round random 9]] call PO3_fnc_supportCreateHeloReinforcements; };
	if(random 1 > 0.3 && _equation >= 25) then { [_position,(PO3_side_3 select 0),([7] call PO3_fnc_getVehicleTypes) call PO3_fnc_getArrayRandom,format["EN_GroupForce_%1",round random 9]] call PO3_fnc_supportCreateHeloReinforcements; };
};

_intelpercent = 1;
_percentAlive = 1;
_fired1 = false;
_fired2 = false;
_fired3 = false;

_intel1 = 1 - ((round random[7, 16, 25])/100); // Lowest is 0.75, Highest is 0.93
_intel2 = (_intel1 - ((round random[15, 30, 40])/100)) max 0.5; // Lowest is 0.35, Highest is 0.78;
_intel3 = (_intel2 - ((round random[15, 35, 30])/100)) max 0.2; // Lowest is 0.2, Highest is 0.63;

_firedSmallAttack1 = false;
_firedSmallAttack2 = false;
_firedSmallAttack3 = false;

WaitUntil {
	sleep 3;

	_b = (4*(playersNumber(PO3_side_1 select 0)/40)*PO3_TASK__DIF) max 1;

	if( _percentAlive < _intel1 && !_fired1 ) then {
		[_position,_b] spawn _spawnAmbush;
		[(PO3_side_1 select 0),"SIDE",format[localize "STR_PO3_M15_MSG_2",(PO3_side_3 select 2)]] call PO3_fnc_sendChat;
		[(PO3_side_1 select 0),"HINT",format[localize "STR_PO3_M15_MSG_2",(PO3_side_3 select 2)]] call PO3_fnc_sendHint;
		_fired1 = true;
		_percentAlive = ({alive _x} count PO3_TOTAL_UNITS)/(count PO3_TOTAL_UNITS);
	};
	
	if( _percentAlive < 1 && !_fired1 && !_firedSmallAttack1) then { // spawns 1 group of ai
		[_position,1] spawn _spawnAmbush;
		_firedSmallAttack1 = true;
	};

	if( _percentAlive < _intel2 && !_fired2 ) then {
		[_position,_b*2] spawn _spawnAmbush;
		[(PO3_side_1 select 0),"SIDE",format[localize "STR_PO3_M15_MSG_3",(PO3_side_3 select 2)]] call PO3_fnc_sendChat;
		[(PO3_side_1 select 0),"HINT",format[localize "STR_PO3_M15_MSG_3",(PO3_side_3 select 2)]] call PO3_fnc_sendHint;
		_fired2 = true;
		_percentAlive = ({alive _x} count PO3_TOTAL_UNITS)/(count PO3_TOTAL_UNITS);
	};
	
	if( _percentAlive < 0.7 && _firedSmallAttack1 && _fired1 && !_firedSmallAttack2) then { // spawns 1 group of ai
		[_position,2] spawn _spawnAmbush;
		_firedSmallAttack2 = true;
	};

	if( _percentAlive < _intel3 && !_fired3 ) then {
		[_position,_b*3] spawn _spawnAmbush;
		[(PO3_side_1 select 0),"SIDE",format[localize "STR_PO3_M15_MSG_4",(PO3_side_3 select 2)]] call PO3_fnc_sendChat;
		[(PO3_side_1 select 0),"HINT",format[localize "STR_PO3_M15_MSG_4",(PO3_side_3 select 2)]] call PO3_fnc_sendHint;
		_fired3 = true;
		_percentAlive = ({alive _x} count PO3_TOTAL_UNITS)/(count PO3_TOTAL_UNITS);
	};

	if( _percentAlive < 0.3 && _firedSmallAttack2 && _fired2 && !_firedSmallAttack3) then { // spawns 1 group of ai
		[_position,3] spawn _spawnAmbush;
		_firedSmallAttack3 = true;
	};	
	
	_nearByUnits = [_position,100,(PO3_side_1 select 0),["CAManBase","LandVehicles"]] call PO3_fnc_getNearbyPlayers;
	_increment = 0.03 / (PO3_TASK__DIF*3) / 3;
	_intelpercent = _intelpercent - _increment;
	_percentAlive = ({alive _x} count PO3_TOTAL_UNITS)/(count PO3_TOTAL_UNITS);
	_percentAlive = _percentAlive max _intelpercent;
	["player == leader group player",[_percentAlive - 0.15] ] call PO3_fnc_progressBar;

	_percentAlive < 0.10 && count([_position,300,(PO3_side_1 select 0),["CAManBase","LandVehicles"]] call PO3_fnc_getNearbyPlayers) > 0
};

// =========================================================================================================
//	WAIT UNTIL COMPLETE/FAIL
// =========================================================================================================

sleep 1;
if(_percentAlive <= 0.10) then {
	[format["TASK%1",PO3_TASK__IDD],"succeeded"] call PO3_fnc_updateTask;
}else{
	[format["TASK%1",PO3_TASK__IDD],"failed"] call PO3_fnc_updateTask;
};

// =========================================================================================================
//	Cleanup
// =========================================================================================================

[_position,PO3_TOTAL_UNITS,PO3_TOTAL_VEHICLES] spawn {
	private["_target","_units","_vehicles"];

	_target = _this select 0;
	_units = _this select 1;
	_vehicles = _this select 2;

	waitUntil { count ([_target,500,(PO3_side_1 select 0),["CAManBase"]] call PO3_fnc_getNearbyPlayers) == 0 };

	{ if(alive _x) then { _x setDamage 1 }; }forEach _units;
	{ if( {isPlayer _x} count (crew _x) == 0 ) then { _x setDamage 1 }; }forEach _vehicles;
};

if(true) exitWith {};