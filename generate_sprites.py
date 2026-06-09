"""404 除灵事务所 — AI 精灵生成器 (Stability AI API)"""

import os, time, requests, base64

API_KEY = "sk-HJFmkYUjW5478OvG0belLkS85R42QP876Zs2c3UefWd3oQYv"
STABILITY_URL = "https://api.stability.ai/v2beta/stable-image/generate/sd3"

BASE = os.path.dirname(os.path.abspath(__file__))

OUTPUTS = {
    "game/assets/characters": [
        ("lin_jin.png", 1024, 1536,
         "character design sheet, full body front view, young chinese male exorcist hacker, short black hair with blue tint, navy tactical vest with glowing circuit lines, grey traditional inner robe, combat boots, holding floating red digital talisman, confident expression, dark chinese urban fantasy concept art illustration, muted earth tones, dramatic rim lighting"),
        ("xu_zhaye.png", 1024, 1536,
         "character design sheet, full body 3/4 view, chinese male folklore scholar, medium black hair tied with red string, round wire glasses, long dark brown traditional changshan coat with copper embroidery, three paper effigy dolls floating around, bronze compass in right hand, left hand making Taoist seal, calm knowing eyes, warm amber desk lamp lighting, dark urban fantasy concept art"),
        ("bai_zhi.png", 1024, 1536,
         "character design sheet, full body front view, chinese female agent, messy short silver-white hair, right eye completely pitch black, left eye bloodshot and intense, torn crimson tactical coat, black combat bodysuit, white bandages wrapping forearms, holding cracked obsidian mirror shard emitting purple glow, unsettling slight smile, flickering fluorescent overhead light, dark urban fantasy concept art"),
    ],
    "game/assets/bosses": [
        ("grey_line_conductor.png", 1024, 1024,
         "ghost subway conductor monster, tall imposing, decaying 1980s chinese metro uniform, featureless smooth white face with two burning red eye sockets, holding brass ticket punch dripping black liquid, hundreds of floating expired train tickets orbiting, lower body dissolves into dark smoke, tunnel background, dramatic under-lighting, atmospheric horror concept art"),
        ("station_shadow.png", 1024, 1024,
         "massive humanoid shadow creature emerging from subway wall, 3 meters tall, elongated with too many joints, skin texture like deep ocean water with bioluminescent specks, no face just darker void, shadow tendrils spreading, seawater puddles forming, cracked wet subway tiles, blue-green bioluminescent glow, lovecraftian horror concept art"),
        ("mirror_keeper.png", 1024, 1024,
         "crystalline humanoid made of broken mirror fragments, elegant angular geometry, different distorted reflections visible in each shard, head fragment floating detached, arms ending in sharp glass points, cold blue-white light from cracks, smaller orbiting shards, mirror corridor background, beautiful but deadly, concept art"),
        ("broadcast_entity.png", 1024, 1024,
         "grotesque fusion of vintage radio speakers and organic flesh, humanoid asymmetrical, 1970s speaker cones embedded in torso pulsing like lungs, wires and vacuum tubes growing from back as spines, purple electricity sparking, multiple crude whispering mouths on body, visible purple sound wave ripples, tangled cable legs, destroyed control room, industrial horror, warm tube-glow and purple lighting"),
        ("reverse_conductor.png", 1024, 1024,
         "time-worn ghost conductor, decaying 1997 dated metro uniform, body flickering between solid and transparent like VHS tracking error, three analog clock faces embedded in chest showing different times, face frozen in eternal regret with tear tracks, holding broken pocket watch, ghostly younger afterimages trailing, sepia toned with cold blue ghost-light, melancholic, old subway car with 1997 cityscape through windows"),
    ],
    "game/assets/enemies": [
        ("empty_seat_passenger.png", 512, 512,
         "translucent gray ghost of subway commuter, simple everyday clothes, pale blank featureless face empty eye sockets, floating above ground feet fading to mist, arms limp, tired haunted posture, simple sad ghost design, soft gray lighting"),
        ("low_frequency_shade.png", 512, 512,
         "creature made of purple sound waves and TV static, roughly humanoid energy form no solid body, purple lightning arcs across surface, brighter static ring around head area, constantly shifting impossible to focus, harsh contrast purple and dark violet"),
        ("reverse_walker.png", 512, 512,
         "twisted humanoid walking backwards, torso facing opposite direction from legs, arms bent wrong, neck too long craned backwards, dark reddish-black with crimson aura, motion blur afterimage trail, face hidden in shadow under twisted neck"),
        ("shadow_fragment.png", 512, 512,
         "small floating orb of pure darkness, basketball sized, circular with constantly shifting jagged edges like living inkblot, faint purple-violet inner glow, smaller shadow droplets breaking off and rejoining, minimalist simple design"),
        ("mirror_clone.png", 512, 512,
         "liquid mercury humanoid, fully reflective constantly flowing surface, distorted funhouse mirror proportions one arm too long head tilted, mercury drips evaporating, no features just smooth curve, silver chrome with environment reflections"),
        ("charmed_passenger.png", 512, 512,
         "regular commuter under mind control, normal clothes but stiff unnatural walk pose, glowing purple eyes no pupils, purple mist seeping from ears and mouth, vacant slack expression, arms reaching forward, faint purple aura around head"),
        ("time_echo.png", 512, 512,
         "cyan-blue translucent time ghost, flickering between young and old versions, small clock hands orbiting body, visual afterimage shadow showing different age, composed of light and temporal distortion, clock faces appearing and dissolving inside, cool icy blue tones, semi-transparent with lens flare"),
    ],
}

NEGATIVE = "low quality, blurry, bad anatomy, extra limbs, missing limbs, watermark, signature, text, 3D, anime, cartoon, deformed, ugly, mutation"

def generate():
    total = sum(len(v) for v in OUTPUTS.values())
    done = 0
    for out_dir, items in OUTPUTS.items():
        out_path = os.path.join(BASE, out_dir)
        os.makedirs(out_path, exist_ok=True)
        for filename, w, h, prompt in items:
            full_path = os.path.join(out_path, filename)
            if os.path.exists(full_path) and os.path.getsize(full_path) > 1000:
                print(f"[SKIP] {filename}")
                done += 1
                continue

            print(f"[{done+1}/{total}] {filename} ({w}x{h})...", end=" ", flush=True)

            try:
                resp = requests.post(
                    STABILITY_URL,
                    headers={"Authorization": f"Bearer {API_KEY}", "Accept": "image/*"},
                    files={
                        "prompt": (None, prompt),
                        "negative_prompt": (None, NEGATIVE),
                        "output_format": (None, "png"),
                        "aspect_ratio": (None, f"{w}:{h}"),
                    },
                    timeout=120,
                )
                if resp.status_code == 200:
                    with open(full_path, "wb") as f:
                        f.write(resp.content)
                    print(f"OK ({os.path.getsize(full_path)//1024}KB)")
                else:
                    print(f"FAIL HTTP {resp.status_code}: {resp.text[:200]}")
            except Exception as e:
                print(f"ERROR: {e}")

            done += 1
            time.sleep(1)

    print(f"\nDone! {done} images.")

if __name__ == "__main__":
    generate()
