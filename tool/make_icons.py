"""Generate small PNG install icons from the project's geometric V mark."""
import struct
import zlib
from pathlib import Path

for size in (192, 512):
    data = bytearray()
    for y in range(size):
        data.append(0)
        for x in range(size):
            a, b = x * 512 / size, y * 512 / size
            color = (18, 16, 24)
            if 128 <= b <= 400:
                outer = 104 + (b - 128) * 122 / 272
                inner = 192 + (b - 128) * 64 / 176 if b < 304 else 256
                if outer <= a <= inner or 512 - inner <= a <= 512 - outer:
                    color = (167, 139, 250)
            if (a - 256) ** 2 + (b - 120) ** 2 <= 22 ** 2:
                color = (110, 231, 183)
            data.extend(color)
    def chunk(kind, payload):
        return struct.pack('>I', len(payload)) + kind + payload + struct.pack('>I', zlib.crc32(kind + payload))
    png = b'\x89PNG\r\n\x1a\n'
    png += chunk(b'IHDR', struct.pack('>IIBBBBB', size, size, 8, 2, 0, 0, 0))
    png += chunk(b'IDAT', zlib.compress(bytes(data))) + chunk(b'IEND', b'')
    Path(f'web/icons/vertice-{size}.png').write_bytes(png)
