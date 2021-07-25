extends CanvasLayer

const STAGETIME = 120

func _ready():
	Globals.hud = self
	timerTick()
	
func _process(_delta):
	if Globals.player:
		$Score.text = "%08d" % Globals.player.score
		$EggCount.text = str(Globals.player.eggs)
		$EnemyCount.text = str(Globals.player.kills)
		
	if int($EnemyCount.text) >= 32:
		Globals.player.setWinState()
	
func timerTick(sec := 1):
	if int($StageTime.text) > 0:
		yield(get_tree().create_timer(sec), "timeout")
		var newTime = int($StageTime.text) - 1
		$StageTime.text = str(newTime)
		timerTick(sec)
	else:
		Globals.player.nuke = true
		Globals.player.getPongy()
		Globals.player.health = -1
		Globals.player.lives = -1
		
	if int($StageTime.text) < 20:
		$StageTime/Animator.play("LetsGo")
		
