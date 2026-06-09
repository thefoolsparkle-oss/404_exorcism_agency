"""404 除灵事务所 — AI 精灵生成 (Stability AI)"""

import os, time, requests

API_KEY = "sk-HJFmkYUjW5478OvG0belLkS85R42QP876Zs2c3UefWd3oQYv"
BASE = os.path.dirname(os.path.abspath(__file__))

JOBS = [
    ("game/assets/characters/lin_jin.png", "2:3",
     "character design sheet, full body front view, young chinese male exorcist hacker, short black hair, navy tactical vest with glowing circuit lines, grey inner robe, holding floating red digital talisman, confident expression, dark chinese urban fantasy concept art"),
    ("game/assets/characters/xu_zhaye.png", "2:3",
     "character design sheet, full body, chinese male scholar, medium black hair tied with red string, round glasses, long dark brown changshan coat with copper embroidery, paper effigy dolls floating around, bronze compass in hand, calm knowing eyes, dark urban fantasy concept art"),
    ("game/assets/characters/bai_zhi.png", "2:3",
     "character design sheet, full body front view, chinese female agent, short messy silver-white hair, right eye pitch black, left eye bloodshot, torn crimson tactical coat, black bodysuit, white bandages on arms, cracked obsidian mirror shard glowing purple, unsettling smile, dark urban fantasy concept art"),
    ("game/assets/bosses/grey_line_conductor.png", "1:1",
     "ghost subway conductor, tall imposing, decaying metro uniform, smooth white face with burning red eye sockets, brass ticket punch dripping black liquid, floating expired tickets, dark smoke lower body, tunnel, dramatic under-light, atmospheric horror concept art"),
    ("game/assets/bosses/station_shadow.png", "1:1",
     "massive humanoid shadow creature from subway wall, elongated with too many joints, ocean water texture with bioluminescent dots, no face just void, shadow tendrils, seawater puddles, cracked wet tiles, blue-green glow, lovecraftian horror concept art"),
    ("game/assets/bosses/mirror_keeper.png", "1:1",
     "crystalline humanoid of broken mirror fragments, elegant angular, different reflections in each shard, floating head, sharp glass arms, cold blue-white light, orbiting shards, mirror corridor, beautiful deadly concept art"),
    ("game/assets/bosses/broadcast_entity.png", "1:1",
     "fusion of vintage radio speakers and organic flesh, humanoid asymmetrical, speaker cones embedded in torso pulsing, wires and tubes as spine, purple electricity, multiple whispering mouths, sound wave ripples, tangled cable legs, destroyed control room, industrial horror"),
    ("game/assets/bosses/reverse_conductor.png", "1:1",
     "time-worn ghost conductor, decaying metro uniform with 1997 badge, body flickers between solid and transparent, three clock faces in chest, face of eternal regret with tears, broken pocket watch, ghost afterimages, sepia and cold blue ghost-light, melancholic"),
    ("game/assets/enemies/empty_seat_passenger.png", "1:1",
     "translucent gray ghost commuter, simple clothes, blank featureless face empty eye sockets, floating above ground, tired posture, simple sad ghost, game sprite"),
    ("game/assets/enemies/low_frequency_shade.png", "1:1",
     "purple sound wave and TV static creature, roughly humanoid energy, no solid body, lightning arcs, static ring halo, shifting form, harsh contrast, game sprite"),
    ("game/assets/enemies/reverse_walker.png", "1:1",
     "twisted humanoid walking backwards, torso opposite legs, wrong bend arms, long craned neck, dark red with crimson aura, motion blur trail, face hidden, game sprite"),
    ("game/assets/enemies/shadow_fragment.png", "1:1",
     "small floating orb of pure darkness, jagged shifting edges, faint purple inner glow, dark droplets breaking off, minimalist design, game sprite"),
    ("game/assets/enemies/mirror_clone.png", "1:1",
     "liquid mercury humanoid, reflective flowing surface, distorted funhouse proportions, dripping mercury, no features, silver chrome, game sprite"),
    ("game/assets/enemies/charmed_passenger.png", "1:1",
     "regular commuter mind controlled, normal clothes stiff walk, glowing purple eyes, purple mist from ears and mouth, vacant expression, faint purple head aura, game sprite"),
    ("game/assets/enemies/time_echo.png", "1:1",
     "cyan-blue translucent time ghost, flickers between young and old, clock hands orbiting, afterimage shadow, light and temporal distortion, clock faces appearing inside, cool icy blue tones, game sprite"),
]

NEG = "low quality, blurry, bad anatomy, extra limbs, missing limbs, watermark, signature, text, 3D, anime, cartoon, deformed, ugly, mutation"

for i, (rel_path, ratio, prompt) in enumerate(JOBS):
    full_path = os.path.join(BASE, rel_path)
    fname = os.path.basename(rel_path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)

    if os.path.exists(full_path) and os.path.getsize(full_path) > 1000:
        print(f"[{i+1}/15] SKIP {fname}")
        continue

    print(f"[{i+1}/15] {fname} ({ratio})...", end=" ", flush=True)
    try:
        r = requests.post(
            "https://api.stability.ai/v2beta/stable-image/generate/sd3",
            headers={"Authorization": f"Bearer {API_KEY}", "Accept": "image/*"},
            files={
                "prompt": (None, prompt),
                "negative_prompt": (None, NEG),
                "output_format": (None, "png"),
                "aspect_ratio": (None, ratio),
            },
            timeout=120,
        )
        if r.status_code == 200:
            with open(full_path, "wb") as f:
                f.write(r.content)
            print(f"OK {os.path.getsize(full_path)//1024}KB")
        else:
            print(f"ERR HTTP{r.status_code} {r.text[:150]}")
    except Exception as e:
        print(f"ERR {e}")
    time.sleep(1)

print("Done!")
