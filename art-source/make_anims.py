"""MARGIN — generates all the animations (PNG sheets + SpriteFrames .tres + manifest + GIF previews)."""
import sys
from anim_core import export, REG
import anims_p0
anims_p0.register()
for m in sys.argv[1:]:
    __import__(m).register()
man = export()
print('animations:', len(REG), 'entities:', len(man))
