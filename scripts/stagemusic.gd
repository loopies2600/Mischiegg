extends AudioStreamPlayer

var fade := false

func _ready():
	Globals.stageMusic = self
	
func _process(delta):
	if playing:
		if fade:
			volume_db = lerp(volume_db, -80, delta / 4)
