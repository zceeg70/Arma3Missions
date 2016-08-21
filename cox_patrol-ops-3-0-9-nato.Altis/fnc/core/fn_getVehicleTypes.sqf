private["_types"];
_types = _this;
_array = [];
// _types is an array which looks like:
// [number, number,...number], where the number is a difficulty.
{ _array = _array + (PO3_preDefinedEnemyVehicles select _x) }forEach _types;
_array;