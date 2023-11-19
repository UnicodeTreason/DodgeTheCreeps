extends Area2D
signal hit

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # Player movement vector
	
	# Check for inputs
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	# Prevent faster diagonal movement
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		get_node("AnimatedSprite2D").play()
	else:
		get_node("AnimatedSprite2D").stop()

	# Add movement vectors to player
	position += velocity * delta
	
	# Prevent leaving the screen
	position = position.clamp(Vector2.ZERO, screen_size)
	
	# Ensure sprite looks good
	if velocity.x != 0: # Moving Left/Right
		$AnimatedSprite2D.animation = "walk" # Alternative to get_node()
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0 # Boolean assignment shortcut to find "Left" movement
	elif velocity.y != 0: # Moving Up/Down
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0 # Boolean assignment shortcut to find "Up" movement

func _on_body_entered(body):
	hide()
	hit.emit()
	# Disable collision, once safe to do so
	# Must be deferred as we can't change physics properties on a physics callback
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
