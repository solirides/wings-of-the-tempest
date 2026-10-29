extends Resource
class_name ChunkTerrainSampler

@export var noise: Noise;

func set_seed( new_seed: int ) -> void:
	noise.seed = new_seed;

func sample( voxel: Vector3i, max_height: float ) -> float:
	return ( noise.get_noise_2d( voxel.x, voxel.z ) * 0.5 + 0.5 ) \
		* max_height - voxel.y;
