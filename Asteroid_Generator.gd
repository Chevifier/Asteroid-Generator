extends Spatial

#A multimesh instance with multimesh set and transform type set to 3D
export(PackedScene) var asteroid_chunk
#asteroids per mesh
export var asteroid_count = 25
#Grid size on X,Y, Z 
export var GRID_X = 10
export var GRID_Y = 10
export var GRID_Z = 10
#multimesh squared size on XYZ i.e Size of on Grid cell
export var multimesh_size = 100
# Called when the node enters the scene tree for the first time.
var thread : Thread
func _ready():
	#Use threads is you are creating thousands of asteroids and/or adding collisions
	thread = Thread.new()
	thread.start(self,"generate",0)
	#generate(0)

func generate(v):
	var pos = Vector3()
	for z in GRID_Z:
		#reset grid on Y
		pos.y = 0
		for y in GRID_Y:
			#reset grid on X
			pos.x = 0
			for x in GRID_X:
				#Multimesh Instance
				var mm = asteroid_chunk.instance()
				add_child(mm)
				#set the multimeshes instance count
				mm.multimesh.instance_count = asteroid_count
				#set the multimeshInstance position
				mm.global_transform.origin = pos
				#pass the multimesh to randomly place asteroids
				place_asteroids(mm)
				#increament grid on X
				pos.x += multimesh_size
			#increament grid on Y
			pos.y += multimesh_size
		#increament grid on Z
		pos.z += multimesh_size

func place_asteroids(mmeshI:MultiMeshInstance):
	#Loop though all instances and set their positions to a random local position
	#to the multimesh instance
	for instance in mmeshI.multimesh.instance_count:
		#Random local position within Multimesh instance
		var rpos = Vector3(rand_range(0,multimesh_size),rand_range(0,multimesh_size),\
				rand_range(0,multimesh_size))
		mmeshI.multimesh.set_instance_transform(instance,Transform(Basis(),rpos))
		#Use physics Server to Create Collision Shapes
		#Pass the global position of the multimesh instance plus the local position of the current instance
		create_collision(mmeshI.global_transform.origin + rpos)
		
func create_collision(pos:Vector3):
	#set Physics server to shorter variable name for convenience
	var ps = PhysicsServer
	#create body as Static 
	var as_col = ps.body_create(PhysicsServer.BODY_MODE_STATIC)
	#set the body to be of the same world space !IMPORTANT!
	ps.body_set_space(as_col,get_world().space)
	#create collision shape this case simple sphere use 
	#for custom shape use shape_create(PhysicsServer.SHAPE_CUSTOM)
	#then shape_set_data(shape,custom_mesh)	
	var shape = ps.shape_create(PhysicsServer.SHAPE_SPHERE)
	#sets radius to 0.5 shape set data depends on shape type ^
	ps.shape_set_data(shape, 0.5)
	#add shape to body setting local Transform to 0
	ps.body_add_shape(as_col,shape,Transform(Basis(),Vector3()))
	#set the body global position 
	ps.body_set_state(as_col,PhysicsServer.BODY_STATE_TRANSFORM,Transform(Basis(),pos))
	

#For freeing thread
func _exit_tree():
	if thread == null:
		return
	if thread.is_alive() == false:
		thread.wait_to_finish()
