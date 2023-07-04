extends RoutineGOAP
class_name MINER_routine

var debug = true

func startRoutine():
	for ship in groupData:
		#Assign an Officer
		print("starting MINER ",groupData[ship]["symbol"])
		var officer = goapOFFICER.new()
		officer._relevant_data["ship"] = groupData[ship]["symbol"]
		#officer._relevant_data["shipData"] = ship
		officer.name = str(groupData[ship]["symbol"],"_","CO") #COMMANDING_OFFICER
		self.add_child(officer)
		officer.connect("requestStateUpdate",self,"stateUpdate")
		if Automation._FleetData[ship]["cargo"]["units"] == Automation._FleetData[ship]["cargo"]["capacity"]:
			officer._ship_state["cargo_is_full"] = true
			officer._ship_state["cargo_is_empty"] = false
		elif Automation._FleetData[ship]["cargo"]["units"] > 0:
			officer._ship_state["cargo_is_full"] = false
			officer._ship_state["cargo_is_empty"] = false
		else:
			officer._ship_state["cargo_is_full"] = false
			officer._ship_state["cargo_is_empty"] = true
		
		#initiate goals
		var LUG = LOAD_UPgoal.new()
		officer.add_child(LUG)
		var PG = PURGEgoal.new()
		officer.add_child(PG)
		officer._goals = [LUG,PG]
		
		#initiate actions and action_planner
		var planner = goapACTION_PLANNER.new()
		officer.add_child(planner)
		
		var a0 = Devise_Extract_Site_Flight_Plan_Action.new()
		planner.add_child(a0)
		var a1 = Devise_Market_Site_Flight_Plan_Action.new()
		planner.add_child(a1)
		var a2 = Devise_Refuel_Site_Flight_Plan_Action.new()
		planner.add_child(a2)
		var a3 = Ensure_fuel_to_extract_site_Action.new()
		planner.add_child(a3)
		var a4 = Ensure_fuel_to_market_site_Action.new()
		planner.add_child(a4)
		var a5 = Extract_Cycle_Action.new()
		a5.focusList.push_back(a5.possibleFocus[0])
		a5.focusList.push_back(a5.possibleFocus[21])
		a5.focusList.push_back(a5.possibleFocus[22])
		planner.add_child(a5)
		var a6 = Get_Survey_Action.new()
		a6.focusList.push_back(a6.possibleFocus[0])
		a6.focusList.push_back(a6.possibleFocus[21])
		a6.focusList.push_back(a6.possibleFocus[22])
		planner.add_child(a6)
		var a7 = Navigate_to_extract_site_Action.new()
		planner.add_child(a7)
		var a8 = Navigate_to_market_site_Action.new()
		planner.add_child(a8)
		var a9 = Navigate_to_refuel_site_Action.new()
		planner.add_child(a9)
		var a10 = Purge_Cycle_Action.new()
		planner.add_child(a10)
		
		planner._symbol = groupData[ship]["symbol"]
		planner._officer = self.name
		planner._officerOBj = self
		planner._debug = debug
		#yield(get_tree(),"idle_frame")
		planner.set_actions([a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10])
		
		officer._action_planner = planner
		#yield(get_tree(),"idle_frame")
		officer.officer = officer.has.STARTED

func stateUpdate(officer):
	var ship = officer._relevant_data["ship"]
	if Automation._FleetData[ship]["cargo"]["units"] == Automation._FleetData[ship]["cargo"]["capacity"]:
		officer._ship_state["cargo_is_full"] = true
		officer._ship_state["cargo_is_empty"] = false
	elif Automation._FleetData[ship]["cargo"]["units"] > 0:
		officer._ship_state["cargo_is_full"] = false
		officer._ship_state["cargo_is_empty"] = false
	else:
		officer._ship_state["cargo_is_full"] = false
		officer._ship_state["cargo_is_empty"] = true
	
	officer.emit_signal("stateUpdated")
