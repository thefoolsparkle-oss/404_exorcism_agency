extends Node

var hit_player: AudioStreamPlayer
var shoot_player: AudioStreamPlayer
var explosion_player: AudioStreamPlayer
var pickup_player: AudioStreamPlayer
var boss_player: AudioStreamPlayer
var levelup_player: AudioStreamPlayer
var skill_lightning_player: AudioStreamPlayer
var skill_fire_player: AudioStreamPlayer
var skill_shield_player: AudioStreamPlayer
var skill_camera_player: AudioStreamPlayer
var skill_ash_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var music_playing: bool = false

func _ready() -> void:
	hit_player = _make_player(_gen_hit_pcm(), "hit", -4.0)
	shoot_player = _make_player(_gen_shoot_pcm(), "shoot", -6.0)
	explosion_player = _make_player(_gen_explosion_pcm(), "explosion", -2.0)
	pickup_player = _make_player(_gen_pickup_pcm(), "pickup", -6.0)
	boss_player = _make_player(_gen_boss_pcm(), "boss", 0.0)
	levelup_player = _make_player(_gen_levelup_pcm(), "levelup", -4.0)
	skill_lightning_player = _make_player(_gen_lightning_pcm(), "lightning", -6.0)
	skill_fire_player = _make_player(_gen_fire_pcm(), "fire", -8.0)
	skill_shield_player = _make_player(_gen_shield_pcm(), "shield", -6.0)
	skill_camera_player = _make_player(_gen_camera_pcm(), "camera", -6.0)
	skill_ash_player = _make_player(_gen_ash_pcm(), "ash", -12.0)
	ambient_player = _make_player(_gen_ambient_pcm(), "ambient", -14.0)
	music_player = _make_player(_gen_music_pcm(), "music", -10.0)

func hit() -> void: hit_player.play()
func shoot() -> void: shoot_player.play()
func explosion() -> void: explosion_player.play()
func pickup() -> void: pickup_player.play()
func boss() -> void: boss_player.play()
func levelup() -> void: levelup_player.play()
func lightning() -> void: skill_lightning_player.play()
func fire() -> void: skill_fire_player.play()
func shield() -> void: skill_shield_player.play()
func camera_flash() -> void: skill_camera_player.play()
func ash() -> void: skill_ash_player.play()

func start_ambient() -> void:
	if not ambient_player.playing:
		ambient_player.play()

func stop_ambient() -> void:
	ambient_player.stop()

func start_music() -> void:
	if not music_playing:
		music_player.play()
		music_playing = true

func stop_music() -> void:
	music_player.stop()
	music_playing = false

func start_boss_music() -> void:
	stop_music()
	music_player.stream = _make_stream(_gen_boss_music_pcm())
	music_player.play()
	music_playing = true

func _make_player(data: PackedByteArray, pname: String, vol: float) -> AudioStreamPlayer:
	var p: AudioStreamPlayer = AudioStreamPlayer.new()
	p.name = pname
	p.stream = _make_stream(data)
	p.volume_db = vol
	add_child(p)
	return p

func _make_stream(data: PackedByteArray) -> AudioStreamWAV:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 44100
	stream.stereo = false
	stream.data = data
	return stream

# ---- PCM Generators ----

func _gen_hit_pcm() -> PackedByteArray:
	var out: PackedByteArray
	var sr: int = 44100; var dur: float = 0.06
	for i in range(int(sr * dur)):
		var t = float(i) / sr; var env = 1.0 - t / dur
		var s = int(16000.0 * sin(t * (300.0 * (1.0 - t / dur) + 60.0) * TAU) * env)
		out.append(s & 0xFF); out.append((s >> 8) & 0xFF)
	return out

func _gen_shoot_pcm() -> PackedByteArray:
	var out: PackedByteArray
	var sr: int = 44100; var dur: float = 0.04
	for i in range(int(sr * dur)):
		var t = float(i) / sr; var env = 1.0 - t / dur
		var s = int(10000.0 * sin(t * (800.0 * (1.0 - t / dur) + 150.0) * TAU) * env)
		out.append(s & 0xFF); out.append((s >> 8) & 0xFF)
	return out

func _gen_explosion_pcm() -> PackedByteArray:
	var out: PackedByteArray
	var sr: int = 44100; var dur: float = 0.25
	for i in range(int(sr * dur)):
		var t = float(i) / sr; var env = 1.0 - t / dur
		var s = int(20000.0 * randf_range(-1.0, 1.0) * env)
		out.append(s & 0xFF); out.append((s >> 8) & 0xFF)
	return out

func _gen_pickup_pcm() -> PackedByteArray:
	var out: PackedByteArray
	var sr: int = 44100; var dur: float = 0.08
	for i in range(int(sr * dur)):
		var t = float(i) / sr; var env = 1.0 - t / dur
		var s = int(8000.0 * sin(t * (500.0 + 1200.0 * t / dur) * TAU) * env)
		out.append(s & 0xFF); out.append((s >> 8) & 0xFF)
	return out

func _gen_boss_pcm() -> PackedByteArray:
	var out: PackedByteArray
	var sr: int = 44100; var dur: float = 0.5
	for i in range(int(sr * dur)):
		var t = float(i) / sr; var env = 1.0 - t / dur
		var s = int(25000.0 * (sin(t * (60.0 - 40.0 * t / dur) * TAU) * 0.5 + randf_range(-1.0, 1.0) * 0.5) * env)
		out.append(s & 0xFF); out.append((s >> 8) & 0xFF)
	return out

func _gen_levelup_pcm() -> PackedByteArray:
	var out: PackedByteArray
	var sr: int = 44100; var dur: float = 0.3
	for i in range(int(sr * dur)):
		var t = float(i) / sr; var env = 1.0 - t / dur
		var freq = 300.0 + 800.0 * (t / dur)
		var s = int(6000.0 * (sin(t * freq * TAU) + sin(t * freq * 1.5 * TAU) * 0.5) * env)
		out.append(s & 0xFF); out.append((s >> 8) & 0xFF)
	return out

func _gen_lightning_pcm() -> PackedByteArray:
	var out: PackedByteArray
	var sr: int = 44100; var dur: float = 0.15
	for i in range(int(sr * dur)):
		var t = float(i) / sr; var env = 1.0 - t / dur
		var noise = randf_range(-1.0, 1.0)
		var freq = 2000.0 * (1.0 - t / dur) + 200.0
		var s = int(15000.0 * (sin(t * freq * TAU) * 0.4 + noise * 0.6) * env)
		out.append(s & 0xFF); out.append((s >> 8) & 0xFF)
	return out

func _gen_fire_pcm() -> PackedByteArray:
	var out: PackedByteArray
	var sr: int = 44100; var dur: float = 0.5
	for i in range(int(sr * dur)):
		var t = float(i) / sr; var env = 1.0 - t / dur
		var freq = 100.0 - 80.0 * (t / dur) + sin(t * 25.0) * 30.0
		var s = int(12000.0 * (sin(t * freq * TAU) * 0.3 + randf_range(-1.0, 1.0) * 0.7) * env * env)
		out.append(s & 0xFF); out.append((s >> 8) & 0xFF)
	return out

func _gen_shield_pcm() -> PackedByteArray:
	var out: PackedByteArray
	var sr: int = 44100; var dur: float = 0.2
	for i in range(int(sr * dur)):
		var t = float(i) / sr; var env = 1.0 - t / dur
		var s = int(12000.0 * sin(t * (600.0 + 400.0 * sin(t * 30.0)) * TAU) * env)
		out.append(s & 0xFF); out.append((s >> 8) & 0xFF)
	return out

func _gen_camera_pcm() -> PackedByteArray:
	var out: PackedByteArray
	var sr: int = 44100; var dur: float = 0.12
	for i in range(int(sr * dur)):
		var t = float(i) / sr; var env = max(0, 1.0 - t / dur)
		var s = int(20000.0 * sin(t * (8000.0 * (1.0 - t / dur)) * TAU) * env)
		out.append(s & 0xFF); out.append((s >> 8) & 0xFF)
	return out

func _gen_ash_pcm() -> PackedByteArray:
	var out: PackedByteArray
	var sr: int = 44100; var dur: float = 0.8
	for i in range(int(sr * dur)):
		var t = float(i) / sr; var env = 1.0 - t / dur
		var s = int(6000.0 * randf_range(-0.3, 0.3) * env)
		out.append(s & 0xFF); out.append((s >> 8) & 0xFF)
	return out

func _gen_ambient_pcm() -> PackedByteArray:
	var out: PackedByteArray
	var sr: int = 44100; var dur: float = 6.0
	var phase: float = 0.0
	for i in range(int(sr * dur)):
		var t = float(i) / sr
		var freq = 55.0 + sin(t * 0.3) * 12.0 + sin(t * 0.7) * 8.0
		phase += freq / sr * TAU
		var sample = sin(phase) * 0.4 + sin(phase * 0.5) * 0.3 + sin(phase * 2.0) * 0.15
		sample += randf_range(-0.05, 0.05)
		var s = int(3000.0 * sample)
		out.append(s & 0xFF); out.append((s >> 8) & 0xFF)
	return out

func _gen_music_pcm() -> PackedByteArray:
	var out: PackedByteArray
	var sr: int = 44100; var dur: float = 12.0
	var note_len: float = 0.6
	var notes: Array[float] = [55.0, 65.4, 73.4, 82.4, 73.4, 65.4, 55.0, 49.0, 55.0, 65.4, 73.4, 65.4, 55.0, 49.0, 41.2, 55.0]
	var cutoff: float = 200.0
	for i in range(int(sr * dur)):
		var t = float(i) / sr
		var note_idx = int(t / note_len) % notes.size()
		var note_t = fmod(t, note_len) / note_len
		var note_env = 1.0 - note_t
		var freq = notes[note_idx]
		var wave = sin(t * freq * TAU) + sin(t * freq * 0.5 * TAU) * 0.6
		wave += sin(t * freq * 3.0 * TAU) * 0.08
		var lp = wave * 0.5
		var bass_freq = freq * 0.25
		var bass = sin(t * bass_freq * TAU) * 0.3
		var s = int(2500.0 * (lp * 0.6 + bass * 0.4) * clamp(note_env * 2.0, 0, 1))
		out.append(s & 0xFF); out.append((s >> 8) & 0xFF)
	return out

func _gen_boss_music_pcm() -> PackedByteArray:
	var out: PackedByteArray
	var sr: int = 44100; var dur: float = 8.0
	for i in range(int(sr * dur)):
		var t = float(i) / sr
		var bass = sin(t * 55.0 * TAU) * 0.15
		var drone = sin(t * 110.0 * TAU) * 0.08 + sin(t * 165.0 * TAU) * 0.05
		var pulse = sin(t * 3.0 * TAU) * 0.12 + sin(t * 3.7 * TAU) * 0.08
		var noise = randf_range(-0.06, 0.06)
		var s = int(3000.0 * (bass + drone + pulse + noise))
		out.append(s & 0xFF); out.append((s >> 8) & 0xFF)
	return out
