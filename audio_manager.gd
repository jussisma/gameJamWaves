extends Node  # Usamos Node simple para un Manager global

# Referencias a los nodos (Asegúrate de que sean AudioStreamPlayer normales en el editor)
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer
@onready var music_player: AudioStreamPlayer = $MusicPlayer

var sounds = {
	"shoot": preload("res://assets/Snake's Authentic Gun Sounds/Isolated/5.56/WAV/556 Single Isolated WAV.wav"),
	"heal": preload("res://assets/RPG_Essentials_Free/8_Buffs_Heals_SFX/02_Heal_02.wav"),
	"consume": preload("res://assets/RPG_Essentials_Free/8_Buffs_Heals_SFX/39_Absorb_04.wav"),
	"enemy_attack": preload("res://assets/RPG_Essentials_Free/10_Battle_SFX/22_Slash_04.wav"),
	"move": preload("res://assets/RPG_Essentials_Free/12_Player_Movement_SFX/08_Step_rock_02.wav")
}

# --- SONIDOS GLOBALES (Sin posición: UI, Disparo propio, Música) ---
# --- SONIDOS GLOBALES (Sin posición: UI, Disparo propio, Música) ---
func play_sfx(sound_name: String, pitch_scale: float = 1.0) -> void:
	if sounds.has(sound_name):
		# EN LUGAR DE USAR sfx_player, CREAMOS UNO NUEVO CADA VEZ
		var temp_player = AudioStreamPlayer.new()
		
		temp_player.stream = sounds[sound_name]
		temp_player.pitch_scale = pitch_scale
		temp_player.volume_db = -40
		
		# IMPORTANTE: Conectar la señal para que se autodestruya al terminar
		temp_player.finished.connect(temp_player.queue_free)
		
		add_child(temp_player)
		temp_player.play()
	else:
		print("Error: Sonido no encontrado -> ", sound_name)

# --- SONIDOS POSICIONALES (Explosiones lejanas, enemigos) ---
func play_sfx_2d(sound_name: String, global_pos: Vector2) -> void:
	if sounds.has(sound_name):
		# Aquí SÍ creamos un AudioStreamPlayer2D dinámicamente
		var temp_player = AudioStreamPlayer2D.new()
		temp_player.stream = sounds[sound_name]
		temp_player.global_position = global_pos
		temp_player.autoplay = true
		
		# Opcional: Ajustar distancia máxima si quieres que se deje de oír lejos
		temp_player.max_distance = 1000 
		
		# Se borra al terminar
		temp_player.finished.connect(temp_player.queue_free)
		
		# Lo añadimos a la escena actual o al propio AudioManager
		add_child(temp_player)

# --- MÚSICA ---
func play_music(music_stream: AudioStream) -> void:
	if music_player.stream == music_stream and music_player.playing:
		return 
	
	music_player.stream = music_stream
	music_player.play()

func stop_music():
	music_player.stop()
