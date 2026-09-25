#!/usr/bin/env python3
"""二进制文件转 32 位十六进制文本（每行一个 word）"""
import sys

if len(sys.argv) != 3:
    print("Usage: bin2hex.py <input.bin> <output.hex>", file=sys.stderr)
    sys.exit(1)

data = open(sys.argv[1], 'rb').read()
with open(sys.argv[2], 'w') as f:
    for i in range(0, len(data), 4):
        word = int.from_bytes(data[i:i+4].ljust(4, b'\x00'), 'little')
        f.write('%08x\n' % word)

print("Generated %s: %d words (%d bytes)" % (sys.argv[2], (len(data)+3)//4, len(data)))
