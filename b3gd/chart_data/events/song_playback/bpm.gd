class_name EventBPMChange extends Event

@export var bpm: float

func init():
	parent.get_tree().get_first_node_in_group("SongAudioPlayer").bpm_events.append(self)

func play(_speed: float = 1.0):
	pass
