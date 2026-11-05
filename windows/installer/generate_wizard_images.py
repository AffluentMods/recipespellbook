# Generates the art the Windows installer's wizard shows (windows/installer.iss):
#   wizard_image.bmp        410 x 785, the sidebar on the Welcome and Finished pages
#   wizard_small_image.bmp  140 x 140, the corner image on the other pages
# Both are 2.5 times Inno Setup's base sizes, so they stay sharp on high-DPI screens.
# The art carries no version number, so it only needs making again when the logo changes.
#
# Run from the repository root, with Python and Pillow:
#   python windows/installer/generate_wizard_images.py
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
ICON = Image.open(ROOT / 'assets/images/icon.png').convert('RGB')
FRAUNCES = ROOT / 'assets/fonts/Fraunces-Variable.ttf'

CREAM = (251, 243, 233)
PEACH = (236, 182, 132)
INK = (58, 36, 24)
INK_SOFT = (110, 78, 58)


def serif(size):
    font = ImageFont.truetype(str(FRAUNCES), size)
    try:
        font.set_variation_by_axes([600 if 'Weight' in str(a.get('name', '')) else a['default']
                                    for a in font.get_variation_axes()])
    except Exception:
        pass
    return font


def sans(size):
    for name in ('segoeui.ttf', 'arial.ttf'):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def gradient(w, h):
    v = Image.linear_gradient('L')
    mask = ImageChops.add(v, v.rotate(90), scale=2).transpose(Image.FLIP_LEFT_RIGHT).resize((w, h), Image.BICUBIC)
    return Image.composite(Image.new('RGB', (w, h), PEACH), Image.new('RGB', (w, h), CREAM), mask)


def rounded_icon(size):
    mask = Image.new('L', (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, size - 1, size - 1], size // 5, fill=255)
    out = Image.new('RGBA', (size, size))
    out.paste(ICON.resize((size, size), Image.LANCZOS), (0, 0), mask)
    return out


def with_shadow(base, tile, x, y, blur=14):
    shadow = Image.new('RGBA', (tile.width + blur * 4, tile.height + blur * 4), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [blur * 2, blur * 2, blur * 2 + tile.width, blur * 2 + tile.height], tile.width // 5, fill=(70, 35, 10, 70))
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur))
    base.paste(shadow, (x - blur * 2, y - blur * 2 + 8), shadow)
    base.paste(tile, (x, y), tile)


def centred(draw, y, text, font, fill, width):
    draw.text(((width - draw.textlength(text, font=font)) / 2, y), text, font=font, fill=fill)


# Sidebar
W, H = 410, 785
side = gradient(W, H).convert('RGBA')
with_shadow(side, rounded_icon(170), (W - 170) // 2, 170)
d = ImageDraw.Draw(side)
centred(d, 380, 'Recipe', serif(66), INK, W)
centred(d, 452, 'Spellbook', serif(66), INK, W)
centred(d, 552, 'Every recipe you’ve saved,', sans(25), INK_SOFT, W)
centred(d, 584, 'in one book.', sans(25), INK_SOFT, W)
side.convert('RGB').save(OUT / 'wizard_image.bmp')

# Corner image: the icon on the page colour
S = 140
small = Image.new('RGBA', (S, S), (255, 255, 255, 255))
small.paste(rounded_icon(124), (8, 8), rounded_icon(124))
small.convert('RGB').save(OUT / 'wizard_small_image.bmp')
print('wrote', OUT / 'wizard_image.bmp', OUT / 'wizard_small_image.bmp')
