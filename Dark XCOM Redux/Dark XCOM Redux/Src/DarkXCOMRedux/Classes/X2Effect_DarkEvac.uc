class X2Effect_DarkEvac extends X2Effect_Persistent;
//
//var int UnitID;
//
//function RegisterForEvents(XComGameState_Effect EffectGameState)
//{
	//local X2EventManager EventMgr;
	//local Object EffectObj;
//
	//EventMgr = `XEVENTMGR;
	//EffectObj = EffectGameState;
//
	//EventMgr.RegisterForEvent(EffectObj, 'RM_TeleportOut', class'X2Effect_DarkEvac'.static.OnEvacOut, ELD_OnStateSubmitted, 45);
//}
//
//
////Must be static. Will be associated, in the event manager, with a XComGameState_Effect, rather than this object.
//static function EventListenerReturn OnEvacOut(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
//{
	//local XComGameState NewGameState;
//
	//NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Visualizing Evac Out");
	//default.UnitID = XComGameState_Unit(EventSource).GetReference().ObjectID;
	//XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = TeleportOut_BuildVisualization;
	//`GAMERULES.SubmitGameState(NewGameState);
//
//
	//return ELR_NoInterrupt;
//}
//
//
//
//function TeleportOut_BuildVisualization(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
//{
	//local XComGameState_Unit SpawnedUnit;
	//local TTile SpawnedUnitTile;
	//local int i;
	//local VisualizationTrack BuildTrack, EmptyBuildTrack;
	//local X2Action_PlayAnimation PsiWarpInEffectAnimation;
	//local X2Action_PlayEffect PsiWarpInEffectAction;
	//local XComWorldData World;
	//local XComContentManager ContentManager;
	//local XComGameStateHistory History;
	//local bool bUsingATTTransport;
	//local X2Action_ShowSpawnedUnit ShowSpawnedUnitAction;
	//local X2Action_ATT ATTAction;
	//local float ShowSpawnedUnitActionTimeout;
//
	//History = `XCOMHISTORY;
	//ContentManager = `CONTENT;
	//World = `XWORLD;
//
		//SpawnedUnit = XComGameState_Unit(History.GetGameStateForObjectID(default.UnitID));
//
//
		//BuildTrack = EmptyBuildTrack;
		//BuildTrack.StateObject_OldState = SpawnedUnit;
		//BuildTrack.StateObject_NewState = SpawnedUnit;
		//BuildTrack.TrackActor = History.GetVisualizer(SpawnedUnit.ObjectID);
//
		//SpawnedUnit.GetKeystoneVisibilityLocation(SpawnedUnitTile);
//
		//PsiWarpInEffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTrack(BuildTrack, VisualizeGameState.GetContext()));
		//PsiWarpInEffectAction.EffectName = ContentManager.PsiWarpInEffectPathName;
		//PsiWarpInEffectAction.EffectLocation = World.GetPositionFromTileCoordinates(SpawnedUnitTile);
		//PsiWarpInEffectAction.bStopEffect = false;
//
//
		//OutVisualizationTracks.AddItem(BuildTrack);
	//
//}
//