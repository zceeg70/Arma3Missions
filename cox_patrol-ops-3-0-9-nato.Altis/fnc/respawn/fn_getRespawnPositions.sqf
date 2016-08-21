/*
	Author: Eightysix

	Description:

*/
private ["_player","_varName","_positions","_objectPositions","_groupPositions","_sidePositions","_globalPositions"];

_positions = [];
_varName = "PO3_respawn_positions_";
_g = missionnamespace getvariable [_varName + "global",[]];
// [[WEST,"redeploy_west","b_hq","Base"],[WEST,"redeploy_west_marine","b_naval","Aircraft section"],[WEST,"redeploy_west_marine_1","b_naval","Helicopter section"],[EAST,"redeploy_east","o_hq","Base"],[EAST,"redeploy_east_marine","o_naval","Marina Base South"],[EAST,"redeploy_east_marine_1","o_naval","Marina Base North"],[GUER,"redeploy_guerrila","n_hq","Base"],[GUER,"redeploy_guerrila_marine","n_naval","Marina Base South"],[GUER,"redeploy_guerrila_marine_1","n_naval","Marina Base North"]]
_l = missionnamespace getvariable [_varName + "local",[]];
// systemChat _l;
_r = missionnamespace getvariable [_varName + "rallypoints",[]];
_h = missionnamespace getvariable [_varName + "halo",[]];

{
	_isMHQ = _x getVariable ["PO3_mhq",nil];
	if(!isNil "_isMHQ") then {
		if( _x getVariable ["PO3_mhq_state",false] ) then {
			_text = [_dest] call PO3_fnc_getCfgText;
			_l set [count _l,[ _isMHQ, _x, "", format["%1 (MHQ)",_text] ] ];
		};
	};
}forEach vehicles;

{
	_positions = _positions - [_x];
	if( [player,(_x select 0)] call PO3_fnc_checkObjCondition ) then {
		_positions set [count _positions,_x];
	};
} foreach (_g+_l+_r+_h);

_positions = _positions - [""];
PO3_respawn_positions_list = _positions;

_positions;