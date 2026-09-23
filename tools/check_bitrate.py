import os, struct

BITRATES = {1: [0,32,40,48,56,64,80,96,112,128,160,192,224,256,320],
            2: [0,32,48,56,64,80,96,112,128,160,192,224,256,320,384],
            3: [0,32,40,48,56,64,80,96,112,128,160,192,224,256,320]}
SAMPLES = {0: 44100, 1: 48000, 2: 32000}

def bitrate(path):
    with open(path, "rb") as f:
        data = f.read()
    for i in range(len(data)-4):
        b = data[i:i+4]
        if b[0] == 0xFF and (b[1] & 0xE0) == 0xE0:
            version = (b[1] >> 3) & 0x03  # 3=MPEG1
            layer = (b[1] >> 1) & 0x03
            bitrate_idx = (b[2] >> 4) & 0x0F
            sr_idx = (b[2] >> 2) & 0x03
            if version == 3 and layer == 1 and bitrate_idx not in (0,15):
                br = BITRATES[1][bitrate_idx]
                sr = SAMPLES.get(sr_idx, 0)
                return br, sr
    return None

for f in sorted(os.listdir("assets/audio")):
    if f.endswith(".mp3"):
        r = bitrate(os.path.join("assets/audio", f))
        size = os.path.getsize(os.path.join("assets/audio", f))
        print(f"{f}: bitrate={r[0] if r else '?'}kbps  sample={r[1] if r else '?'}Hz  size={round(size/1e6,1)}MB")