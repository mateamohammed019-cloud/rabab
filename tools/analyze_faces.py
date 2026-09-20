import os
import glob
import cv2

MODEL = "tools/yunet.onnx"

def detector(img_w, img_h):
    det = cv2.FaceDetectorYN_create(
        MODEL, "", (320, 320),
        score_threshold=0.7, nms_threshold=0.3, top_k=10,
    )
    det.setInputSize((img_w, img_h))
    return det

def analyze(path):
    img = cv2.imread(path)
    if img is None:
        return None
    h, w = img.shape[:2]
    det = detector(w, h)
    _, faces = det.detect(img)
    results = []
    if faces is not None:
        for f in faces:
            x, y, fw, fh = int(f[0]), int(f[1]), int(f[2]), int(f[3])
            conf = f[14]
            rel = (fw * fh) / (w * h)
            cx, cy = x + fw / 2, y + fh / 2
            centered = max(0.0, 1.0 - ((abs(cx - w / 2) / (w / 2) + abs(cy - h / 2) / (h / 2)) / 2))
            size_score = 1.0 - abs(rel - 0.18) / 0.18 if rel < 0.34 else 0.25
            total = 0.45 * size_score + 0.30 * centered + 0.25 * conf
            results.append({
                "box": (x, y, fw, fh),
                "conf": round(float(conf), 3),
                "rel": round(rel, 3),
                "centered": round(centered, 3),
                "score": round(total * 100, 1),
            })
    return {"size": (w, h), "faces": results}

best = None
for path in sorted(glob.glob("assets/images/*.jpg")):
    r = analyze(path)
    if not r:
        print(f"{path}: ERROR")
        continue
    print(f"{path}  size={r['size']}  faces={len(r['faces'])}")
    for f in r["faces"]:
        mark = ""
        score = f["score"]
        print(f"   box={f['box']} conf={f['conf']} rel={f['rel']} centered={f['centered']} SCORE={score}")
        if best is None or score > best[0]:
            best = (score, path, f)

print("\nBEST:", best)