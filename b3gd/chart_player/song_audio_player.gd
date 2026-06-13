extends AudioStreamPlayer
# I just stole this whole script from myself, it might need adjustment - gitgato


signal beat_hit(beat: int)

var bpm_events: Array[EventBPMChange] = []

var paused = false

var song_progress_seconds = -4: #set to a really low number so the song wont play until the chart loader does its setup
	set(value):
		var previous_beat = song_progress_beats
		song_progress_seconds = value
		var new_beat = song_progress_beats
		if floor(previous_beat) != floor(new_beat):
			beat_hit.emit(floor(new_beat))
		if song_progress_seconds >= 0 and playing:
			return
		if song_progress_seconds < 0 and playing:
			stop()
		elif song_progress_seconds >= 0 and !paused and !playing:
			if song_progress_seconds > 0.08: # if its only a little off it just resyncs
				play(song_progress_seconds)
			else:
				play()
			force_sync = true

var paused_position = 0.0
var force_sync = false

var bpm_events_index:
	get():
		var result = 0
		for bpm_index_check in range(bpm_events.size()):
			if bpm_events[bpm_index_check].time < song_progress_seconds:
				result = bpm_index_check
		return result

var bpm:
	get():
		return bpm_events[bpm_events_index].bpm

var bpm_beat_start:
	get():
		return bpm_events[bpm_events_index].time

var song_progress_beats:
	get():
		var beat_since_beat_start = (bpm / 60) * (song_progress_seconds - bpm_beat_start)
		return beat_since_beat_start + get_beat_carry(bpm_events_index)

@onready var output_latency = AudioServer.get_output_latency()
@onready var scrub_timer = Timer.new()

func get_beat_carry(bpm_index: int):
	var add_beat = 0
	var last_data = [0, 0]
	for i in range(bpm_index + 1):
		add_beat += (last_data[1] / 60.0) * (bpm_events[i].time - last_data[0])
		last_data = [bpm_events[i].time, bpm_events[i].bpm]
	return add_beat

func get_seconds_from_beat(beat: float):
	var bpm_info_at_beat = [bpm_events[0].bpm, bpm_events[0].time, bpm_events[0].time]
	for i in range(bpm_events.size()):
		if get_beat_carry(i) > bpm_info_at_beat[1] and get_beat_carry(i) <= beat:
			bpm_info_at_beat = [bpm_events[i].bpm, get_beat_carry(i), bpm_events[i].time]
	return ((beat - bpm_info_at_beat[1]) / (bpm_info_at_beat[0] / 60)) + bpm_info_at_beat[2]

func _ready() -> void:
	add_child(scrub_timer)

func _process(delta: float) -> void:
	if paused:
		song_progress_seconds = paused_position
		return
	
	if song_progress_seconds < 0:
		var next_prog = song_progress_seconds + (delta * int(!paused) * pitch_scale)
		if next_prog > 0:
			song_progress_seconds = 0
		else:
			song_progress_seconds = next_prog
		return
	
	var mix_adj = (AudioServer.get_time_since_last_mix() - output_latency)
	var true_prog = get_playback_position() + (mix_adj * pitch_scale)
	# if true_prog stutters (which it can do) it will be smoothed out so it still feels normal
	song_progress_seconds = max(true_prog, song_progress_seconds + (delta * 0.9 * pitch_scale))
	if force_sync:
		song_progress_seconds = max(true_prog, 0)
		force_sync = false
	
func pause():
	if paused:
		return
	paused = true
	if song_progress_seconds >= 0:
		paused_position = get_playback_position()
		stop()
	else:
		paused_position = song_progress_seconds

func unpause():
	if !paused:
		return
	paused = false
	song_progress_seconds = paused_position
	if paused_position >= 0:
		play(song_progress_seconds)
		force_sync = true

func track_seek(new_position, paused_scrub_time:float = 0):
	paused_position = new_position
	if paused_position < 0:
		song_progress_seconds = paused_position
		return
	force_sync = true
	if paused:
		if !scrub_timer.is_stopped():
			scrub_timer.timeout.emit()
			scrub_timer.stop()
		play(paused_position)
		scrub_timer.start(paused_scrub_time)
		await scrub_timer.timeout
		if paused:
			stop()
	else:
		play(paused_position)

func on_finished() -> void:
	force_sync = true

func on_event_pre_init() -> void:
	bpm_events = []
