/*
	1:position
	2:radius
	3:higher
	*lowest building base
	
	return:
	0:[] enterable buildings(include 2positions over)
	1:[] higher buildings
	2:most ASL lower building(non:objNull)
	3:most ASL higher building(non:objNull)
	4:Difference in height
*/
private ["_c_pos","_c_radius","_c_high"];

_c_pos = _this select 0;
_c_radius = _this select 1;
_c_high = _this select 2;

private ["_ret","_r_buildingshigh","_r_buildings","_r_mostlower","_r_mosthigher","_r_diff"];
_r_buildingshigh = [];
_r_buildings = [];
_r_mostlower = objNull;
_r_mosthigher = objNull;
_r_diff = -1;

private ["_ok","_bpos","_positions","_pos","_bl","_low","_high","_ASLlow","_ASLhigh","_exitpos"];
_ASLlow = 10000;
_ASLhigh = -10000;
_low = 0;
_high = 0;
_house = [_c_pos select 0,_c_pos select 1] nearObjects ["house",_c_radius];
{
	_bl = _x;
	if([_bl] call BIS_fnc_isBuildingEnterable)then
	{
		_exitpos = _bl buildingExit 0;
		if !(isNil"_exitpos" or _exitpos isEqualTo [0,0,0])then
		{
			_bpos = _bl buildingPos -1;
			_positions = 0;
			// search low/higher position
			_low = 100;
			_high = -100;
			{
				if(_x select 2 < _low)then
				{
					_low = _x select 2;
				};
				if(_x select 2 > _high)then
				{
					_high = _x select 2;
				};
				_pos = (AGLToASL(_x));
				if(_pos select 2 < _ASLlow)then
				{
					_ASLlow = _pos select 2;
					_r_mostlower = _bl;
				};
				if(_pos select 2 > _ASLhigh)then
				{
					_ASLhigh = _pos select 2;
					_r_mosthigher = _bl;
				};
				_positions = _positions + 1;
			}foreach _bpos;

			// building check
			_ok = false;
			//*lowest buildding,Watching tower is OK
			//*no ruins
			if(_high - _low < 1 and _positions >= 2)then{_ok = true;};
			if(_high - _low >= 2 and _positions >= 1)then{_ok = true;};

			if(_ok)then
			{
				_r_buildings pushBack _bl;
			};
		};
	};
}foreach _house;

// choice higher building
{
	_bl = _x;
	_pos = (AGLToASL(getPos _bl));
	if((_pos select 2) - _ASLlow > _c_high)then
	{
		_r_buildingshigh pushBack _bl;
	};
}foreach _r_buildings;

if(!isnil"_r_mostlower" and !isnil"_r_mosthigher" )then
{
	_r_diff = ((getPos _r_mosthigher)select 2) - ((getPos _r_mostlower)select 2);
};

//[format["findBuildings(%1 %2 %3 %4)",_r_buildingshigh,_r_mostlower,_r_mosthigher,_r_diff]] call LB_fnc_log;

[_r_buildings,_r_buildingshigh,_r_mostlower,_r_mosthigher,_r_diff]