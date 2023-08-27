import pathlib
from typing import List

from loguru import logger


def get_ignored_files(ignore_path: str) -> List:
    result = []

    try:
        with open(ignore_path, "r", encoding="utf-8") as f:
            result = parse_ignorefile(f)
    except FileNotFoundError:
        logger.error("Error fetching dockerignore file: File not found.")
    except Exception as e:
        logger.error(f"Error parsing dockerignore file: {e}")

    return result


def parse_ignorefile(reader: object):
    excludes = []

    if reader is not None:
        current_line = 0

        utf8bom = bytes([0xEF, 0xBB, 0xBF])

        for line in reader:
            scanned_bytes = line.encode("utf-8")

            if current_line == 0:
                scanned_bytes = scanned_bytes.lstrip(utf8bom)

            pattern = scanned_bytes.decode("utf-8").strip()
            current_line += 1

            # ignore comments
            if pattern.startswith("#"):
                continue

            pattern = pattern.strip()

            if not pattern:
                continue

            # normalize absolute paths to paths relative (handle '!' prefix)
            invert = pattern.startswith("!")

            if invert:
                pattern = pattern[1:].strip()

            if pattern:
                pattern = pathlib.Path(pattern).as_posix()

                if len(pattern) > 1 and pattern[0] == "/":
                    pattern = pattern[1:]

            if invert:
                pattern = "!" + pattern

            excludes.append(pattern)

    return excludes
