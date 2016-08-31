//if (!isMultiplayer) exitWith {};

private ["_puntos","_jugador","_puntosJ","_dineroJ"];
_puntos = _this select 0;
_jugador = _this select 1;

if (!isPlayer _jugador) exitWith {};

//if (rank _jugador == "COLONEL") exitWith {};
_jugador = _jugador getVariable ["owner",_jugador];
//if (typeName _jugador == typeName "") exitWith {diag_log format ["Antistasi Error: Intento de asignar puntos a un %1 siendo en realidad %2",_jugador, _this select 1]};
if (isMultiplayer) exitWith
	{
	_puntosJ = _jugador getVariable ["score",0];
	_dineroJ = _jugador getVariable ["dinero",0];
	if (_puntos > 0) then
		{
		_dineroJ = round (_dineroJ + _puntos);
		_jugador setVariable ["dinero",_dineroJ,true];
		_currentBounty = _jugador getVariable ["bounty",0]; 
		_nextBounty = _currentBounty + _puntos;
		_jugador setVariable ["bounty", _nextBounty, true];
		// _texto = format ["<br/><br/><br/><br/><br/><br/>Money +%1 €",_puntos*10];
		// [petros,"income",_texto] remoteExec ["commsMP",_jugador];
		};
	_puntos = _puntos + _puntosJ;
	_jugador setVariable ["score",_puntos,true];
	};

if (_puntos > 0) then
	{
	[0,(_puntos * 10)] remoteExec ["resourcesFIA",2];
	};

