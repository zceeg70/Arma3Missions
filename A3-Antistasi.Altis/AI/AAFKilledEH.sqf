private ["_muerto","_killer","_coste","_enemy","_grupo"];
_muerto = _this select 0;
_killer = _this select 1;
if (_muerto getVariable ["OPFORSpawn",false]) then {_muerto setVariable ["OPFORSpawn",nil,true]};
[_muerto] spawn postmortem;
if (side _killer == side_blue) then
	{
	_grupo = group _muerto;
	if (isPlayer _killer) then
		{
		_coste = server getVariable (typeOf _muerto);
		if (isNil "_coste") then {diag_log format ["Falta incluir a %1 en las tablas de coste",typeOf _muerto]; _coste = 10};
		_bountyReward = 10 + ( _coste / 10 );
		_bountyReward = round _bountyReward;
		if (_bountReward > 40) then {
			_bountyReward = 40;
		}
		
		[_bountyReward, _killer] call playerScoreAdd;
		if (captive _killer) then
			{
			[_killer,false] remoteExec ["setCaptive",_killer];
			};
		};
	else
		{
		_skill = skill _killer;
		[_killer,_skill + 0.05] remoteExec ["setSkill",_killer];
		};
	if (vehicle _killer isKindOf "StaticMortar") then
		{
		if (isMultiplayer) then
			{
			{
			if ((_x distance _muerto < 300) and (captive _x)) then {[_x,false] remoteExec ["setCaptive",_x]};
			} forEach playableUnits;
			}
		else
			{
			if ((player distance _muerto < 300) and (captive player)) then {player setCaptive false};
			};
		};
	if (count weapons _muerto < 1) then
		{
		_nul = [-1,0] remoteExec ["prestige",2];
		_nul = [2,0,getPos _muerto] remoteExec ["citySupportChange",2];
		if (isPlayer _killer) then {_killer addRating 1000};
		}
	else
		{
		_coste = server getVariable (typeOf _muerto);
		if (isNil "_coste") then {diag_log format ["Falta incluir a %1 en las tablas de coste",typeOf _muerto]; _coste = 0};
		[-_coste] remoteExec ["resourcesAAF",2];
		_nul = [-0.5,0.05,getPos _muerto] remoteExec ["citySupportChange",2];
		};

	{
	if (alive _x) then
		{
		if (fleeing _x) then
			{
			if !(_x getVariable ["surrendered",false]) then
				{
				if (([100,1,_x,"BLUFORSpawn"] call distanceUnits) and (vehicle _x == _x)) then
					{
					[_x] spawn surrenderAction;
					}
				else
					{
					if (_x == leader group _x) then
						{
						if (random 1 < 0.1) then
							{
							_enemy = _x findNearestEnemy _x;
							if (!isNull _enemy) then
								{
								[position _enemy] remoteExec ["patrolCA",HCattack];
								};
							};
						};
					[_x,_x] spawn cubrirConHumo;
					};
				};
			}
		else
			{
			//_x allowFleeing (0.5-(_x skill "courage") + (0.2*({(_x getVariable ["surrendered",false]) or (!alive _x)} count (units group _x))));
			if (random 1 < 0.5) then {_x allowFleeing (0.5 -(_x skill "courage") + (({(!alive _x) or (_x getVariable ["surrendered",false])} count units _grupo)/(count units _grupo)))};
			};
		};
	} forEach units _grupo;
	};