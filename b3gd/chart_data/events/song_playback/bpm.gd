class_name EventBPMChange extends Event

@export_range(1.0, 300.0, 0.0, "or_greater") var bpm: float

func init():
	parent.get_tree().get_first_node_in_group("SongAudioPlayer").bpm_events.append(self)

func play(_speed: float = 1.0):
	pass
