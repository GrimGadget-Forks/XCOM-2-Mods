class UnitPsiUtilties extends Object;

//this lets us check if a soldier has already trained in the psi lab
static function XComGameState_Unit_Psi GetPsiComponent(XComGameState_Unit Unit)
{
	if (Unit != none)
		return XComGameState_Unit_Psi(Unit.FindComponentObject(class'XComGameState_Unit_Psi'));
	
	return none;
}
