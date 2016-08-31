private ["_light","_caller"];
hintSilent "Chemlight off called";
_light = _this select 3 select 0;
// hintFormat ["Light:%1",_light];
deleteVehicle _light;
// removeAction
// hintSilent "Chemlight deleted?"; 