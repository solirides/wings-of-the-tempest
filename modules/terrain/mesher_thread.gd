class_name MesherThread

static var thread: Thread;
static var mutex: Mutex;
static var semaphore: Semaphore;

static var do_kill: bool;
static var input: Array[ MesherInput ];
static var output: Signal;

class MesherInput:
	
	var vertices: PackedVector3Array;
	var primitive_type: Mesh.PrimitiveType;
	
	@warning_ignore("shadowed_variable")
	func _init( vertices: PackedVector3Array, primitive_type: Mesh.PrimitiveType ) -> void:
		self.vertices = vertices;
		self.primitive_type = primitive_type;



static func _static_init() -> void:
	
	thread = Thread.new();
	mutex = Mutex.new();
	semaphore = Semaphore.new();
	
	( MesherThread as Object ).add_user_signal( "output", [ { "name" : "id", "type" : TYPE_INT }, { "name" : "mesh", "type" : TYPE_OBJECT } ] );
	output = Signal( MesherThread, "output" );
	
	thread.start( run_thread, Thread.PRIORITY_LOW );

static func run_thread() -> void:
	
	while true:
		
		semaphore.wait();
		
		mutex.lock();
		if do_kill: break;
		var current: MesherInput = input.pop_front();
		mutex.unlock();
		
		var mesh = generate_mesh( current.vertices, current.primitive_type );
		
		mutex.lock();
		output.emit( current.get_instance_id(), mesh );
		mutex.unlock();

static func generate_mesh( vertices: PackedVector3Array, primitive_type: Mesh.PrimitiveType ) -> Mesh:
	
	#Create surface
	var surface_tool: = SurfaceTool.new();
	surface_tool.begin( primitive_type );
	surface_tool.set_smooth_group( -1 );
	
	#Add vertices
	for vertex in vertices:
		surface_tool.add_vertex( vertex );
	
	#Finalize surface
	if primitive_type == Mesh.PrimitiveType.PRIMITIVE_TRIANGLES:
		surface_tool.generate_normals();
	surface_tool.index();
	
	#Return mesh
	return surface_tool.commit();

static func generate_mesh_on_thread( vertices: PackedVector3Array, primitive_type: Mesh.PrimitiveType ) -> Mesh:
	
	var new_input: = MesherInput.new( vertices, primitive_type );
	var input_id: = new_input.get_instance_id();
	
	input.push_back( new_input );
	semaphore.post();
	
	while true:
		var new_output: Array = await output;
		if new_output[0] == input_id:
			return new_output[1];
	
	return null;
