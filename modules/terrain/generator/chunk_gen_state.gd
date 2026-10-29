extends Object
class_name ChunkGenState

var chunk_index: int;
var chunk_sampler: ChunkTerrainSampler;
var seeded_number: int;

## Returns a random integer, consistent with the generator seed
func get_seeded_int() -> int:
	seed( seeded_number );
	seeded_number = randi();
	return seeded_number;

## Returns a random float, consistent with the generator seed
func get_seeded_float() -> float:
	get_seeded_int();
	return randf();

func _increment() -> void:
	chunk_index += 1;

func _init( generator_seed: int, sampler: ChunkTerrainSampler ) -> void:
	
	#Start at chunk 0
	chunk_index = 0;
	
	#Start with seed as random number
	seeded_number = generator_seed;
	
	#Get sampler and set seed
	chunk_sampler = sampler;
	chunk_sampler.set_seed( generator_seed );
