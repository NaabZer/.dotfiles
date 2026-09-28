#!/usr/bin/env python3
"""
i3 Claude Title Color Daemon

Colors the trailing status token ([running]/[permission]/[input]/[dialog]/
[attention]/[idle]) in the i3 window title of Claude Code Alacritty terminals
using per-window Pango title_format markup.

Only manages Alacritty windows whose title contains "[CC]" (case-insensitive).
On shutdown, resets every managed window's title_format back to plain "%title"
so titles never remain frozen with stale markup.

Dependencies: pip install i3ipc
"""

import atexit
import fcntl
import re
import signal
import sys
from pathlib import Path

from i3ipc import Connection, Event

LOCK_FILE = Path("/tmp/claude-title-color.lock")

GREEN = "#5dbd70"
ORANGE = "#e09448"
RED = "#f7768e"
YELLOW = "#e0af68"

# Keyed by the word inside the trailing "[...]" token (see
# skills/title/scripts/set_state.sh LABEL_* constants), not the leading
# glyph, so this table stays readable.
STATUS_COLORS = {
    "running": GREEN,
    "idle": ORANGE,
    "permission": RED,
    "input": RED,
    "dialog": RED,
    "attention": YELLOW,
}

_TRAILING_TOKEN_RE = re.compile(r"\[([^\[\]]*)\]$")

_reset_done = False
_i3: Connection | None = None
_colored_ids: set[int] = set()


def ensure_single_instance():
    """Prevent multiple daemon instances using fcntl lock."""
    lock_fp = open(LOCK_FILE, "w")
    try:
        fcntl.flock(lock_fp, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        sys.exit(0)  # Another instance is already running
    return lock_fp  # Keep reference to prevent GC releasing the lock


def pango_escape(text: str) -> str:
    """Escape a string for safe embedding in Pango markup."""
    text = text.replace("&", "&amp;")
    text = text.replace("<", "&lt;")
    text = text.replace(">", "&gt;")
    return text


def build_title_format(title: str) -> str:
    """Build a Pango title_format string that colors the trailing status token."""
    if "[cc]" not in title.lower():
        return "%title"

    stripped = title.rstrip()
    match = _TRAILING_TOKEN_RE.search(stripped)
    if match is None:
        return "%title"

    inner = match.group(1)
    word = inner.split()[-1].lower() if inner.split() else ""
    color = STATUS_COLORS.get(word)
    if color is None:
        return "%title"

    token = match.group(0)
    escaped = pango_escape(title)
    idx = escaped.rfind(pango_escape(token))
    span = f"<span foreground='{color}'>{pango_escape(token)}</span>"
    return escaped[:idx] + span + escaped[idx + len(pango_escape(token)) :]


def i3_command_quote(fmt: str) -> str:
    """Escape a string for embedding inside a double-quoted i3 command argument."""
    fmt = fmt.replace("\\", "\\\\")
    fmt = fmt.replace('"', '\\"')
    return fmt


def _set_format(con, fmt: str) -> None:
    """Apply a title_format command to a container, never raising."""
    try:
        con.command(f'title_format "{i3_command_quote(fmt)}"')
    except Exception:
        pass  # Never let one failing window kill the daemon


def apply(con) -> None:
    """Apply the appropriate title_format to a container, if manageable."""
    if con.window_class != "Alacritty" or con.name is None:
        return

    fmt = build_title_format(con.name)
    if fmt != "%title":
        _set_format(con, fmt)
        _colored_ids.add(con.id)
    elif con.id in _colored_ids:
        _set_format(con, "%title")
        _colored_ids.discard(con.id)
    # else: a window we never colored — leave it untouched


def reset_all() -> None:
    """Reset title_format on every Alacritty window back to plain %title."""
    global _reset_done
    if _reset_done:
        return
    _reset_done = True

    try:
        conn = _i3 if _i3 is not None else Connection()
        for con in conn.get_tree().leaves():
            if con.window_class != "Alacritty" or con.name is None:
                continue
            _set_format(con, "%title")
    except Exception:
        pass

    _colored_ids.clear()


def handle_signal(_signum, _frame) -> None:
    """Handle SIGINT/SIGTERM by resetting title formats and exiting."""
    reset_all()
    sys.exit(0)


def on_window_event(_i3, event) -> None:
    """Handle window title/new events."""
    apply(event.container)


def main() -> None:
    """Start the daemon."""
    global _i3

    _lock_fp = ensure_single_instance()  # Keep reference to prevent GC releasing lock

    atexit.register(reset_all)
    signal.signal(signal.SIGINT, handle_signal)
    signal.signal(signal.SIGTERM, handle_signal)

    _i3 = Connection()

    for con in _i3.get_tree().leaves():
        apply(con)

    _i3.on(Event.WINDOW_TITLE, on_window_event)
    _i3.on(Event.WINDOW_NEW, on_window_event)
    _i3.main()


if __name__ == "__main__":
    main()
