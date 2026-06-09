# AI 出图提示词 — 404 除灵事务所

使用方法：复制每段提示词，粘贴到 https://www.bing.com/images/create （免费，需要微软账号）
或 https://app.leonardo.ai （免费额度，游戏素材更专业）

输出格式全部要求 PNG 透明背景（Leonardo 支持，Bing 不支持透明需要用 remove.bg 去底）

---

## 角色立绘（3张）→ 放到 game/assets/characters/

### 林锦 / lin_jin.png
```
a young chinese male exorcist, short dark hair, wearing a modern tactical vest over traditional robe, holding a glowing red talisman in one hand, futuristic cyberpunk details on his sleeves, determined expression, standing pose, full body, 2D game character art style, muted dark blue and gray color palette, white background, concept art
```

### 徐招夜 / xu_zhaye.png
```
a young chinese male folklore researcher, medium length hair tied back, wearing round glasses and a dark brown scholar's coat, paper talismans floating around him, copper coins hanging from his belt, calm scholarly expression, standing pose, full body, 2D game character art style, warm gold and brown color palette, white background, concept art
```

### 白纸 / bai_zhi.png
```
a young chinese female agent, short messy white hair, right eye is completely black, wearing a torn dark red tactical coat, bandages wrapped around her arms, holding a cracked mirror shard, intense expression with a slight unsettling smile, standing pose, full body, 2D game character art style, dark red and black color palette, white background, concept art
```

---

## Boss（5张）→ 放到 game/assets/bosses/

### 灰线列车员 / grey_line_conductor.png
```
a ghostly subway train conductor, wearing a vintage 1980s metro uniform, face is featureless except for glowing red eyes, holding a ticket punch that drips dark liquid, surrounded by floating train tickets, dark atmospheric, 2D game boss art, horror concept art, white background
```

### 站台暗影 / station_shadow.png
```
a humanoid shadow creature emerging from a subway platform wall, vaguely human shaped but elongated, tendrils of darkness spreading, wet floor reflection, ocean-like texture on its surface, 2D game boss art, dark atmospheric, horror concept art, white background
```

### 镜中守护者 / mirror_keeper.png
```
a crystalline humanoid made of broken mirror shards, multiple distorted reflections visible within its body, sharp glass edges, glowing pale light from cracks, elegant but menacing posture, 2D game boss art, cold blue silver tones, concept art, white background
```

### 广播寄生体 / broadcast_entity.png
```
a grotesque fusion of vintage radio speakers and organic flesh, multiple speakers embedded in its body, sound waves visualized as purple distortion, mouths forming in unexpected places, wires and tubes, 2D game boss art, dark purple and flesh tones, horror concept art, white background
```

### 逆行列车长 / reverse_conductor.png
```
a time-worn ghostly conductor, uniform torn and aged thirty years, clock faces embedded in its chest all showing different times, hands are transparent and flickering, surrounded by floating pocket watches, expression of infinite regret, 2D game boss art, sepia and dark gray tones, concept art, white background
```

---

## 敌人的敌人（7种）→ 放到 game/assets/enemies/

### 空座乘客 / empty_seat_passenger.png
```
a spectral subway passenger, translucent gray figure, wearing everyday commuter clothes, featureless pale face, floating slightly above ground, simple ghost design, 2D game enemy sprite, 256x256, white background
```

### 低频噪音影 / low_frequency_shade.png
```
a creature made of purple sound waves and static noise, no defined shape just vibrating energy, small lightning-like arcs around it, 2D game enemy sprite, 256x256, white background
```

### 逆行客 / reverse_walker.png
```
a humanoid figure walking backwards, limbs bent in wrong directions, dark red aura, afterimage trail, twisted posture, 2D game enemy sprite, 256x256, white background
```

### 暗影碎片 / shadow_fragment.png
```
a small fragment of pure darkness, roughly circular with jagged edges, faint purple glow at core, swarm creature, very simple design, 2D game enemy sprite, 128x128, white background
```

### 镜中复制体 / mirror_clone.png
```
a silver humanoid made of liquid mercury, reflective surface, distorted proportions like a funhouse mirror, dripping slightly, 2D game enemy sprite, 256x256, white background
```

### 被魅惑的乘客 / charmed_passenger.png
```
a brainwashed subway passenger, eyes glowing purple, walking stiffly forward, purple mist around head, civilian clothing, vacant expression, 2D game enemy sprite, 256x256, white background
```

### 时间回响 / time_echo.png
```
a temporal ghost, cyan-blue translucent figure, flickering between young and old versions, clock hands spinning around it, afterimage effect, 2D game enemy sprite, 256x256, white background
```

---

## 背景（5张）→ 放到 game/assets/backgrounds/

### 灰线地铁 / GLM-001.png (以及其他案件可复用)
```
abandoned subway station interior, 1980s chinese metro design, dirty white tile walls, dim flickering fluorescent lights, empty tracks, faded propaganda posters on walls, atmospheric, dark but not pitch black, game background art, 1920x1080, wide angle
```

---

## 出图后操作

1. 图片命名按上面指定的文件名
2. 放到对应的 game/assets/ 子目录
3. PNG 需要透明背景（Leonardo 直接出，Bing 出的图用 https://www.remove.bg 去底）
4. 角色建议 1024x1536，敌人 256x256，Boss 512x512，背景 1920x1080
5. 放好后重启 Godot，自动替换代码画的精灵
