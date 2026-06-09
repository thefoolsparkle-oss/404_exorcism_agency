extends Node

var hit_player: AudioStreamPlayer
var shoot_player: AudioStreamPlayer
var explosion_player: AudioStreamPlayer
var pickup_player: AudioStreamPlayer
var boss_player: AudioStreamPlayer

func _ready() -> void:
	hit_player = _make_pcm(_gen_hit_pcm(), "hit")
	shoot_player = _make_pcm(_gen_shoot_pcm(), "shoot")
	explosion_player = _make_pcm(_gen_explosion_pcm(), "explosion")
	pickup_player = _make_pcm(_gen_pickup_pcm(), "pickup")
	boss_player = _make_pcm(_gen_boss_pcm(), "boss")

func hit() -> void: hit_player.play()
func shoot() -> void: shoot_player.play()
func explosion() -> void: explosion_player.play()
func pickup() -> void: pickup_player.play()
func boss() -> void: boss_player.play()

func _make_pcm(data: PackedByteArray, name: String) -> AudioStreamPlayer:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 44100
	stream.stereo = false
	stream.data = data
	var p: AudioStreamPlayer = AudioStreamPlayer.new()
	p.name = name
	p.stream = stream
	p.volume_db = -6.0
	add_child(p)
	return p

func _gen_hit_pcm() -> PackedByteArray:
	var out: PackedByteArray
	var sr: int = 44100
	var dur: float = 0.06
	for i in range(int(sr * dur)):
		var t: float = float(i) / sr
		var env: float = 1.0 - t / dur
		var freq: float = 300.0 * (1.0 - t / dur) + 60.0
		var s: int = int(16000.0 * sin(t * freq * TAU) * env)
		out.append(s & 0xFF)
		out.append((s >> 8) & 0xFF)
	return out

func _gen_shoot_pcm() -> PackedByteArray:
	var out: PackedByteArray
	var sr: int = 44100
	var dur: float = 0.04
	for i in range(int(sr * dur)):
		var t: float = float(i) / sr
		var env: float = 1.0 - t / dur
		var freq: float = 800.0 * (1.0 - t / dur) + 150.0
		var s: int = int(10000.0 * sin(t * freq * TAU) * env)
		out.append(s & 0xFF)
		out.append((s >> 8) & 0xFF)
	return out

func _gen_explosion_pcm() -> PackedByteArray:
	var out: PackedByteArray
	var sr: int = 44100
	var dur: float = 0.25
	for i in range(int(sr * dur)):
		var t: float = float(i) / sr
		var env: float = 1.0 - t / dur
		var noise: float = randf_range(-1.0, 1.0)
		var s: int = int(20000.0 * noise * env)
		out.append(s & 0xFF)
		out.append((s >> 8) & 0xFF)
	return out

func _gen_pickup_pcm() -> PackedByteArray:
	var out: PackedByteArray
	var sr: int = 44100
	var dur: float = 0.08
	for i in range(int(sr * dur)):
		var t: float = float(i) / sr
		var env: float = 1.0 - t / dur
		var freq: float = 500.0 + 1200.0 * (t / dur)
		var s: int = int(8000.0 * sin(t * freq * TAU) * env)
		out.append(s & 0xFF)
		out.append((s >> 8) & 0xFF)
	return out

func _gen_boss_pcm() -> PackedByteArray:
	var out: PackedByteArray
	var sr: int = 44100
	var dur: float = 0.5
	for i in range(int(sr * dur)):
		var t: float = float(i) / sr
		var env: float = 1.0 - t / dur
		var freq: float = 60.0 - 40.0 * (t / dur)
		var noise: float = randf_range(-1.0, 1.0)
		var s: int = int(25000.0 * (sin(t * freq * TAU) * 0.5 + noise * 0.5) * env)
		out.append(s & 0xFF)
		out.append((s >> 8) & 0xFF)
	return out
