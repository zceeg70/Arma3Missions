waitUntil {!(isNull player)};
waitUntil {player==player};
switch (side player) do
{
case WEST:
{
};
case EAST:
{
};
case RESISTANCE:
{
};
case CIVILIAN:
{
};
};

_testtt = player createDiarySubject ["tipsNtricks","Tips n Tricks"];
_test1 = player creatediaryRecord ["tipsNtricks",[ "Autorifleman","
<br/>
1. You are not a sniper
<br/>
2. Try firing short bursts at a target (3 - 5 rounds)
<br/>
3. Ask the team leader or assistant gunner to spot the fall of your rounds,
  and act on their suggested adjustments
<br/>
4. The first burst at a target should be the longest. Executed effectively, this 'fixes'
  the enemy in position, allowing the rest of the squad to have static targets to engage
<br/>
5. You are not a sniper
<br/>
"]];
_test2 = player creatediaryRecord ["tipsNtricks",[ "General","
<br/>
1. If you spot a target that is not firing, say 'enemy sighted' + left' or 'right'. Then give a bearing, approximate range,
 and your position in the formation.  
<br/>
2. If you hear the words 'enemy sighted': STOP. Do help the squad locate enemy. It is the leaders role to find the enemy
and give orders. 
<br/>
3. The phrase to use when being fired at - if there is time is 'contact'. Otherwise, you firing 
means the same thing.
<br/>
4. Use your ears. A lot of confusion/deaths are caused by failing to listen to others when they provide information
<br/>
5. Move from cover to cover when possible, even if you are not under fire. 
<br/>
"]];

// F3 - Briefing
// Credits: Please see the F3 online manual (http://www.ferstaberinde.com/f3/en/)
// ====================================================================================

// FACTION: NATO

// ====================================================================================

// NOTES: CREDITS
// The code below creates the administration sub-section of notes.

_cre = player createDiaryRecord ["diary", ["Credits","
<br/>
*** Insert mission credits here. ***
<br/><br/>
Made with F3 (http://www.ferstaberinde.com/f3/en/)
"]];

// ====================================================================================

// ====================================================================================

// NOTES: ADMINISTRATION
// The code below creates the administration sub-section of notes.

_adm = player createDiaryRecord ["diary", ["Administration",""]];

// ====================================================================================

// NOTES: EXECUTION
// The code below creates the execution sub-section of notes.

_exe = player createDiaryRecord ["diary", ["Execution","
<br/>
<font size='18'>COMMANDER'S INTENT</font>
<br/>
<br/><br/>
<font size='18'>MOVEMENT PLAN</font>
<br/>
<br/><br/>
<font size='18'>FIRE SUPPORT PLAN</font>
<br/>
None
<br/><br/>
<font size='18'>Extraction</font>
<br/>
"]];

// ====================================================================================

// NOTES: MISSION
// The code below creates the mission sub-section of notes.

_mis = player createDiaryRecord ["diary", ["Mission",""]];

// ====================================================================================

// NOTES: SITUATION
// The code below creates the situation sub-section of notes.

_sit = player createDiaryRecord ["diary", ["Situation",""]];

// ====================================================================================