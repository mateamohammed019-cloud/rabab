import os
import numpy as np
import cv2
from PIL import Image, ImageOps, ImageDraw

MODEL = "tools/yunet.onnx"

def load(path):
    img = Image.open(path).convert("RGB")
    img = ImageOps.exif_transpose(img)
    return img

def detect_best_face(pil_img):
    w, h = pil_img.size
    rgb = np.array(pil_img)
    bgr = cv2.cvtColor(rgb, cv2.COLOR_RGB2BGR)
    det = cv2.FaceDetectorYN_create(MODEL, "", (320, 320),
                                    score_threshold=0.7, nms_threshold=0.3, top_k=10)
    det.setInputSize((w, h))
    _, faces = det.detect(bgr)
    if faces is None:
        return None
    best = None
    best_score = -1
    for f in faces:
        x, y, fw, fh = int(f[0]), int(f[1]), int(f[2]), int(f[3])
        conf = float(f[14])
        rel = (fw * fh) / (w * h)
        cx, cy = x + fw / 2, y + fh / 2
        centered = max(0.0, 1.0 - ((abs(cx - w / 2) / (w / 2) + abs(cy - h / 2) / (h / 2)) / 2))
        size_score = 1.0 - abs(rel - 0.18) / 0.18 if rel < 0.34 else 0.25
        score = 0.45 * size_score + 0.30 * centered + 0.25 * conf
        if score > best_score:
            best_score, best = score, (x, y, fw, fh)
    return best

def square_crop_around_face(pil_img, face):
    w, h = pil_img.size
    fx, fy, fw, fh = face
    cx, cy = fx + fw / 2, fy + fh / 2
    side = min(w, h)
    x0 = max(0, min(int(cx - side / 2), w - side))
    y0 = int(cy - side * 0.36)
    if y0 < 0:
        y0 = 0
    if y0 + side > h:
        y0 = h - side
    return pil_img.crop((x0, y0, x0 + side, y0 + side))

def cartoonify(pil_img, size=512):
    img = pil_img.resize((size, size), Image.LANCZOS)
    bgr = cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)
    small = cv2.resize(bgr, (size // 2, size // 2))
    small = cv2.bilateralFilter(small, 9, 150, 150)
    small = cv2.bilateralFilter(small, 9, 150, 150)
    color = cv2.resize(small, (size, size), interpolation=cv2.INTER_CUBIC)
    data = color.reshape((-1, 3)).astype(np.float32)
    k = 14
    criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 8, 1.0)
    _, labels, centers = cv2.kmeans(data, k, None, criteria, 2, cv2.KMEANS_PP_CENTERS)
    centers = np.uint8(centers)
    color = centers[labels.flatten()].reshape(color.shape)
    gray = cv2.cvtColor(color, cv2.COLOR_BGR2GRAY)
    gray = cv2.medianBlur(gray, 7)
    edges = cv2.adaptiveThreshold(gray, 255, cv2.ADAPTIVE_THRESH_MEAN_C,
                                  cv2.THRESH_BINARY, 9, 7)
    cartoon = cv2.bitwise_and(color, color, mask=edges)
    hsv = cv2.cvtColor(cartoon, cv2.COLOR_BGR2HSV)
    hsv[:, :, 1] = np.clip(hsv[:, :, 1] * 1.18, 0, 255).astype(np.uint8)
    cartoon = cv2.cvtColor(hsv, cv2.COLOR_HSV2BGR)
    return Image.fromarray(cv2.cvtColor(cartoon, cv2.COLOR_BGR2RGB))

def circle_crop(pil_img, radius):
    size = radius * 2
    img = pil_img.resize((size, size), Image.LANCZOS)
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, size, size), fill=255)
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    out.paste(img, (0, 0), mask)
    return out

RING_STOPS = [
    (255, 0, 60), (255, 80, 0), (255, 210, 0),
    (80, 230, 60), (40, 190, 255), (160, 80, 255), (255, 40, 190),
]

def ring_color(frac):
    n = len(RING_STOPS)
    pos = frac * (n - 1)
    i = min(int(pos), n - 2)
    t = pos - i
    a, b = RING_STOPS[i], RING_STOPS[i + 1]
    return tuple(int(x + (y - x) * t) for x, y in zip(a, b))

def build_icon(avatar, bg_top, bg_bottom, size, out_path,
                outer, ring_w, white_w, avatar_r, transparent=False):
    color_mode = "RGBA" if transparent else "RGB"
    canvas = Image.new(color_mode, (size, size), (0, 0, 0, 0) if transparent else None)
    d = ImageDraw.Draw(canvas)
    if not transparent:
        for y in range(size):
            t = y / (size - 1)
            c = tuple(int(a + (b - a) * t) for a, b in zip(bg_top, bg_bottom))
            d.line((0, y, size, y), fill=c)
    pad = (size * 0.02)
    R_out = outer
    for deg in range(0, 360, 2):
        color = ring_color(deg / 360.0)
        d.arc((pad, pad, size - pad, size - pad),
              start=deg, end=deg + 3,
              fill=color, width=ring_w)
    # white border between ring and avatar
    d.ellipse((R_out - white_w, R_out - white_w,
               size - (R_out - white_w), size - (R_out - white_w)),
              outline=(255, 255, 255), width=white_w)
    av = avatar.resize((avatar_r * 2, avatar_r * 2), Image.LANCZOS)
    mask = Image.new("L", (avatar_r * 2, avatar_r * 2), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, avatar_r * 2, avatar_r * 2), fill=255)
    canvas.paste(av, (size // 2 - avatar_r, size // 2 - avatar_r), mask)
    canvas.save(out_path)
    print("saved", out_path, canvas.size)

def main():
    os.makedirs("assets/icons", exist_ok=True)
    src = load("assets/images/photo_2.jpg")
    face = detect_best_face(src)
    print("best face box:", face)
    crop = square_crop_around_face(src, face)
    crop.save("tools/icon_preview_crop.png")
    cartoon = cartoonify(crop)
    cartoon.save("tools/icon_preview_cartoon.png")
    avatar = circle_crop(cartoon, 300)  # 600x600 circle
    avatar.save("assets/icons/avatar.png")

    # الأيقونة الكاملة: خلفية + حلقة ملونة + الأفاتار
    build_icon(avatar, (255, 160, 190), (214, 48, 120),
               1024, "assets/icons/app_icon.png",
               outer=488, ring_w=34, white_w=8, avatar_r=414)
    # الأيقونة التكيّفية لأندرويد: شفافة، محتوى داخل المنطقة الآمنة
    build_icon(avatar, (255, 160, 190), (214, 48, 120),
               1024, "assets/icons/app_icon_fg.png",
               outer=316, ring_w=26, white_w=7, avatar_r=268,
               transparent=True)

if __name__ == "__main__":
    main()