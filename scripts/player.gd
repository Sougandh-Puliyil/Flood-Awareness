extends CharacterBody2D

var speed=200

var player_state

var last_dir=1

func _physics_process(delta:):
	var direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	
	if direction.x == 0 and direction.y == 0:
		player_state= "Idle"
	elif direction.x != 0 or direction.y != 0:
		player_state = "Walking"
	
	velocity = direction * speed
	move_and_slide()
	
	play_anim(direction)

func play_anim(dir):
	if player_state=="Idle":
		if last_dir==-1:
			$Body.play("IdleL")
			$Shirt.play("IdleL")
			$Pant.play("IdleL")
			$Hair.play("IdleL")
		else:
			$Body.play("IdleR")
			$Shirt.play("IdleR")
			$Pant.play("IdleR")
			$Hair.play("IdleR")
	if player_state=="Walking":
		if dir.x<0:
			$Body.play("WalkL")
			$Shirt.play("WalkL")
			$Pant.play("WalkL")
			$Hair.play("WalkL")
			last_dir=-1
		elif dir.x>0:
			$Body.play("WalkR")
			$Shirt.play("WalkR")
			$Pant.play("WalkR")
			$Hair.play("WalkR")
			last_dir=1
		else:
			if last_dir==1:
				$Body.play("WalkR")
				$Shirt.play("WalkR")
				$Pant.play("WalkR")
				$Hair.play("WalkR")
				last_dir=1
			else:
				$Body.play("WalkL")
				$Shirt.play("WalkL")
				$Pant.play("WalkL")
				$Hair.play("WalkL")
				last_dir=-1
