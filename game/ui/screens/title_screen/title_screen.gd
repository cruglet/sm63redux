extends Control

@export var animation_player: AnimationPlayer
@export var title_loop: AudioStreamPlayer
@export var menu_loop: AudioStreamPlayer
@export var sfx_confirm: AudioStreamPlayer
@export var sfx_back: AudioStreamPlayer
@export var splash_fade: ColorRect

@export var version_text: Label
@export var team_text: Label
@export var splash_screen: Control

@export var playlist: Playlist

var splash_fade_tween: Tween
var on_splash_screen: bool = true
var input_locked: bool = false


func _ready() -> void:
	animation_player.play(&"title_in")
	title_loop.play()


func _input(event: InputEvent) -> void:
	if input_locked:
		return
	
	if event.is_action_pressed(&"start_game") and on_splash_screen:
		input_locked = true
		sfx_confirm.play()
		title_loop.stream_paused = true
		
		_animate_switch_to_mode_selector()
		_show_bottom_text()
		
		await get_tree().create_timer(0.25).timeout
		menu_loop.play()
		animation_player.seek(4.5)
		
		input_locked = false
	
	elif event is InputEventKey and event.keycode == KEY_ESCAPE and event.is_pressed() and not on_splash_screen:
		input_locked = true
		sfx_back.play()
		menu_loop.stream_paused = true
		
		_animate_switch_to_splash_screen()
		await get_tree().create_timer(0.25).timeout
		
		title_loop.stream_paused = false
		
		# Skip to the looping segment if the song was cut off before the beat drop
		if title_loop.get_playback_position() < 4.250:
			title_loop.play(4.250)
		
		input_locked = false

# This is handled manually in case the splash screen
# is exited early, that way we can just call this immediately.
func _show_bottom_text() -> void:
	var bottom_text_tween: Tween = get_tree().create_tween()
	bottom_text_tween.set_parallel(true)
	bottom_text_tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	bottom_text_tween.tween_property(team_text, ^"anchor_top", 0.931, 0.45)
	bottom_text_tween.tween_property(version_text, ^"anchor_top", 0.931, 0.45)
	bottom_text_tween.tween_property(team_text, ^"anchor_bottom", 1.0, 0.45)
	bottom_text_tween.tween_property(version_text, ^"anchor_bottom", 1.0, 0.45)


func _animate_switch_to_mode_selector() -> void:
	on_splash_screen = false
	splash_fade_tween = get_tree().create_tween()
	splash_fade_tween.set_parallel(true)
	splash_fade_tween.set_ease(Tween.EASE_OUT)
	
	splash_fade_tween.tween_property(splash_screen, ^"modulate", Color(1, 1, 1, 0), 0.15)
	splash_fade_tween.tween_property(splash_screen, ^"position:y", -30, 0.15)


func _animate_switch_to_splash_screen() -> void:
	if on_splash_screen:
		return
	
	on_splash_screen = true
	splash_fade_tween = get_tree().create_tween()
	splash_fade_tween.set_parallel(true)
	splash_fade_tween.set_ease(Tween.EASE_OUT)
	
	splash_fade_tween.tween_property(splash_screen, ^"modulate", Color(1, 1, 1, 1), 0.15)
	splash_fade_tween.tween_property(splash_screen, ^"position:y", 0, 0.15)
