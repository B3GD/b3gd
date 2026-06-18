extends MeshInstance3D

@export var noteskin_texture: Texture2D
@export var noteskin_data: NoteskinGridData
@export_group("Drawing Info")
@export var strum_line_idx: int = 1
@export var receptor_spacing := 0.9
@export var note_speed := 1.0
@export var hold_resolution := 8.0
# Callables can't be edited with export. This is a functional modifier system for modcharts though.
var modifiers: Array[Callable]

@onready var song_audio_player := get_tree().get_first_node_in_group("SongAudioPlayer")
@onready var note_manager := get_tree().get_first_node_in_group("NoteManager")
@onready var chart_source := get_tree().get_first_node_in_group("ChartSource")


var idle_frames: Dictionary[String, float] = {
	"receptor_frames": 0,
	"note_frames": 0,
	"hold_frames": 0,
	"hold_end_frames": 0
}

var material: Material

func _ready() -> void:
	material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = noteskin_texture
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

func _process(delta: float) -> void:
	update_idle_frames(delta)
	mesh = get_strum_line_mesh()
	mesh.surface_set_material(0, material)

func get_strum_line_mesh() -> ArrayMesh:
	var mesh_array = []
	mesh_array.resize(Mesh.ARRAY_MAX)
	mesh_array[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	mesh_array[Mesh.ARRAY_TEX_UV] = PackedVector2Array()
	
	var receptor_count = note_manager.strum_lines[strum_line_idx].receptors.size()
	for receptor_id in receptor_count:
		var receptor = note_manager.strum_lines[strum_line_idx].receptors[receptor_id]
		var receptor_transform = Transform3D.IDENTITY
		var receptor_offset = receptor_id - ((receptor_count - 1) * 0.5)
		receptor_transform = receptor_transform.translated_local(Vector3(-receptor_offset * receptor_spacing, 0, 0))
		
		add_receptor_to_mesh(mesh_array, receptor, receptor_transform, receptor_id)
		add_notes_to_mesh(mesh_array, receptor.notes, receptor_id, receptor_transform)
	
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_array)
	return array_mesh

func add_receptor_to_mesh(mesh_array: Array, receptor: Receptor, receptor_transform: Transform3D, receptor_id: int):
	var receptor_frame = get_receptor_frame(receptor)
	add_quad_to_mesh(
		mesh_array, 
		get_texture_index(receptor_id, receptor_frame), 
		get_note_transform(receptor_id, 0.0, receptor_transform)
	)

func add_notes_to_mesh(mesh_array: Array, notes: Array[Note], receptor_id: int, receptor_transform = Transform3D.IDENTITY):
	var note_receptor_transform = receptor_transform.translated_local(Vector3(0, 0, -0.005))
	var hold_receptor_transform = receptor_transform.translated_local(Vector3(0, 0, -0.003))
	var scroll_speed = chart_source.chart.scroll_speed
	var note_frame = noteskin_data.note_frames[idle_frames.note_frames]
	for note in notes:
		var note_distance = (note.time - song_audio_player.song_progress_seconds) * note_speed * scroll_speed
		if note.length > 0:
			var end_distance = note_distance + (note.length * note_speed * scroll_speed)
			add_sustain_to_mesh(mesh_array, receptor_id, hold_receptor_transform, note_distance, end_distance)
		if note.hold_pressed:
			continue
		add_quad_to_mesh(
			mesh_array, 
			get_texture_index(receptor_id, note_frame), 
			get_note_transform(receptor_id, note_distance, note_receptor_transform)
		)

func add_sustain_to_mesh(mesh_array: Array, receptor_id: int, receptor_transform: Transform3D, note_distance: float, end_distance: float):
	var segment_count = floor((end_distance - note_distance) * hold_resolution) + 1.0
	var last_hold_transform = Transform2D.IDENTITY
	var hold_frame = noteskin_data.hold_frames[idle_frames.hold_frames]
	
	var last_rotation = 0
	for segment_id in range(segment_count):
		var start_segment_point = lerp(note_distance, end_distance, (segment_id + 0.0) / segment_count)
		var last_segment_point = lerp(note_distance, end_distance,  (segment_id + 1.0) / segment_count)
		var transform_start = get_note_transform(receptor_id, start_segment_point, receptor_transform)
		var transform_end = get_note_transform(receptor_id, last_segment_point, receptor_transform)
		#transform_end.basis = transform_end.basis.looking_at(transform_start.origin, Vector3(0, 1, 0), true)
		#transform_start.basis = transform_end.basis
		add_hold_quad_to_mesh(
			mesh_array,
			get_texture_index(receptor_id, hold_frame), 
			transform_start, 
			transform_end
		)
		last_hold_transform = transform_end
	hold_frame = noteskin_data.hold_end_frames[idle_frames.hold_end_frames]
	add_quad_to_mesh(
		mesh_array,
		get_texture_index(receptor_id, hold_frame), 
		last_hold_transform
	)

func add_hold_quad_to_mesh(mesh_array: Array, index: Vector2i, draw_transform_top: Transform3D, draw_transform_bottom: Transform3D):
	var quad = [
		Vector3(-0.5, 0.0, 0) * draw_transform_top,
		Vector3( 0.5, 0.0, 0) * draw_transform_top,
		Vector3( 0.5, 0.0, 0) * draw_transform_bottom,
		Vector3(-0.5, 0.0, 0) * draw_transform_bottom,
	]
	var uv_transform = get_uv_transform(index)
	var height = float(noteskin_data.hold_part_height)
	var quad_y_min = (noteskin_data.grid_size.y - height) / 2
	quad_y_min /= noteskin_data.grid_size.y
	var quad_y_max = (noteskin_data.grid_size.y + height) / 2
	quad_y_max /= noteskin_data.grid_size.y
	var quad_uvs = [
		Vector2(0, quad_y_min) * uv_transform, 
		Vector2(1, quad_y_min) * uv_transform, 
		Vector2(1, quad_y_max) * uv_transform, 
		Vector2(0, quad_y_max) * uv_transform
	]
	for idx in [0, 1, 3, 1, 2, 3]:
		mesh_array[Mesh.ARRAY_VERTEX].append(quad[idx])
		mesh_array[Mesh.ARRAY_TEX_UV].append(quad_uvs[idx])

func add_quad_to_mesh(mesh_array: Array, index: Vector2i, draw_transform: Transform3D):
	var quad = [
		Vector3(-0.5, 0.5, 0) * draw_transform,
		Vector3( 0.5, 0.5, 0) * draw_transform,
		Vector3( 0.5,-0.5, 0) * draw_transform,
		Vector3(-0.5,-0.5, 0) * draw_transform,
	]
	var uv_transform = get_uv_transform(index)
	var quad_uvs = [
		Vector2(0, 0) * uv_transform, 
		Vector2(1, 0) * uv_transform, 
		Vector2(1, 1) * uv_transform, 
		Vector2(0, 1) * uv_transform
	]
	for idx in [0, 1, 3, 1, 2, 3]:
		mesh_array[Mesh.ARRAY_VERTEX].append(quad[idx])
		mesh_array[Mesh.ARRAY_TEX_UV].append(quad_uvs[idx])

func get_uv_transform(index: Vector2i) -> Transform2D:
	var uv_transform = Transform2D.IDENTITY
	uv_transform = uv_transform.scaled(Vector2(noteskin_data.grid_size) / noteskin_texture.get_size())
	uv_transform = uv_transform.translated(Vector2(index) * Vector2(-1, -1))
	return uv_transform

func get_note_transform(receptor_id: int, note_offset: float, relative_to := Transform3D.IDENTITY, receptor_count:int = 4):
	var note_transform = relative_to.translated_local(Vector3(0, note_offset, 0))
	for modifier in modifiers:
		note_transform = modifier.call(self, receptor_id, note_offset, relative_to, receptor_count)
	return note_transform

func get_texture_index(receptor: int, frame: int):
	if noteskin_data.orientation == 0:
		return Vector2i(frame, receptor)
	return Vector2i(receptor, frame)

func update_idle_frames(delta: float) -> void:
	for key in idle_frames.keys():
		var animation_length = noteskin_data.get(key).size()
		idle_frames[key] += delta * noteskin_data.idle_animation_fps
		idle_frames[key] = fmod(idle_frames[key], animation_length)

func get_receptor_frame(receptor: Receptor) -> int:
	var receptor_frame = noteskin_data.receptor_frames[idle_frames.receptor_frames]
	var time_since_last_input = song_audio_player.song_progress_seconds - receptor.last_press.input_time
	if !receptor.last_press.ignore_draw:
		var hit_frame = time_since_last_input * noteskin_data.active_animation_fps
		if receptor.last_press.dummy:
			hit_frame = min(hit_frame, noteskin_data.receptor_dummy_frames.size() - 1)
			receptor_frame = noteskin_data.receptor_dummy_frames[hit_frame]
		else:
			hit_frame = min(hit_frame, noteskin_data.receptor_hit_frames.size() - 1)
			receptor_frame = noteskin_data.receptor_hit_frames[hit_frame]
	return receptor_frame
