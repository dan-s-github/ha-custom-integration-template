"""
Write a generated project's brand icons.

Run by the copier task after every copy and update:

    uv run --no-project --with pillow python brand_icon.py \
        PLACEHOLDER_DIR SOURCE BRAND_DIR OPERATION

Home Assistant (2026.3+) serves brand images from a custom integration's
`brand/` folder and falls back to `icon.png` for any image that is missing,
so `icon.png` (256 px) and `icon@2x.png` (512 px) are enough.

SOURCE blank: copy the template's placeholder icons. SOURCE set: resize it.
SOURCE missing: an error on copy (likely a typo), the placeholder on update.

copier update runs the task three times: in temporary renders of the old and
new template (no icons yet), then in the project. The project's icons may have
been replaced by hand, so on update existing icons are never overwritten; the
two renders get the same icons, so the update changes nothing in brand/.
"""

import shutil
import sys
from pathlib import Path

from PIL import Image

SIZES = {"icon.png": 256, "icon@2x.png": 512}


def main(placeholder_arg: str, source_arg: str, brand_arg: str, operation: str) -> int:
    """Write the icons and return the exit code."""
    placeholder_dir = Path(placeholder_arg)
    brand_dir = Path(brand_arg)
    if operation == "update" and (brand_dir / "icon.png").is_file():
        return 0
    brand_dir.mkdir(parents=True, exist_ok=True)

    source = Path(source_arg).expanduser() if source_arg else None
    if source is not None and not source.is_file():
        if operation != "update":
            print(f"brand_icon: {source} not found", file=sys.stderr)
            return 1
        source = None

    if source is None:
        for name in SIZES:
            shutil.copyfile(placeholder_dir / name, brand_dir / name)
        return 0

    image = Image.open(source).convert("RGBA")
    if image.width != image.height:
        # Centre on a transparent square rather than stretch.
        side = max(image.size)
        square = Image.new("RGBA", (side, side))
        square.paste(image, ((side - image.width) // 2, (side - image.height) // 2))
        image = square
    if image.width < max(SIZES.values()):
        print(
            f"brand_icon: {source} is {image.width} px; 512 px or more is"
            " recommended for icon@2x.png",
        )

    for name, size in SIZES.items():
        resized = image.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(brand_dir / name, optimize=True)
    print(f"brand_icon: wrote {', '.join(SIZES)} to {brand_dir}")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 5:
        print(__doc__, file=sys.stderr)
        sys.exit(2)
    sys.exit(main(*sys.argv[1:]))
