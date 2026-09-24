@tool
extends ChunkDecTreeGroup
class_name ChunkDecTreeGroupPriority

func pick( state: ChunkGenState ) -> ChunkDefinition:
	
	#For each branch...
	for child in children:
		
		#Pick it
		var picked = child.pick( state );
		
		#If passes, stop here and use it
		if picked:
			return picked;
	
	#Fail if no branches pass
	return null;
