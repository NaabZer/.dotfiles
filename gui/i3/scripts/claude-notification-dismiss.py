#!/usr/bin/env python3
"""
i3 Focus-Aware Notification Dismiss Daemon

Listens for i3 window focus events and automatically dismisses Claude Code
notifications when their associated terminal window gains focus.

Invariant: the session key is the decimal X11 window id, equal to
ALACRITTY_WINDOW_ID; a window counts as a Claude session only if
~/.claude/session-ids/<key> or notification-state/notification_id.<key> exists.

Dependencies: pip install i3ipc
"""

import fcntl
import subprocess
import sys
from pathlib import Path

from i3ipc import Connection, Event

STATE_DIR = Path.home() / ".claude" / "notification-state"
SESSION_IDS_DIR = Path.home() / ".claude" / "session-ids"
LOCK_FILE = Path("/tmp/claude-notification-dismiss.lock")
CCS = Path.home() / ".claude" / "session-manager" / ".venv" / "bin" / "ccs"
SET_STATE = Path.home() / ".claude" / "skills" / "title" / "scripts" / "set_state.sh"


def ensure_single_instance():
    """Prevent multiple daemon instances using fcntl lock."""
    lock_fp = open(LOCK_FILE, "w")
    try:
        fcntl.flock(lock_fp, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        sys.exit(0)  # Another instance is already running
    return lock_fp  # Keep reference to prevent GC releasing the lock


def close_notification(notification_id: int) -> None:
    """Close notification using dunstctl."""
    subprocess.run(["dunstctl", "close", str(notification_id)], check=False)


def mark_seen(session_key: str) -> None:
    """Fire-and-forget seen markers for the focused session's window key."""
    for cmd in (
        [str(CCS), "seen", "--window", session_key],
        [str(SET_STATE), "seen", session_key],
    ):
        try:
            subprocess.Popen(
                cmd,
                stdin=subprocess.DEVNULL,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True,
            )
        except OSError:
            pass


def on_window_focus(_i3, event) -> None:
    """Handle window focus event."""
    if not event.container.window:
        return

    session_key = str(event.container.window)
    notification_file = STATE_DIR / f"notification_id.{session_key}"
    if not (SESSION_IDS_DIR / session_key).exists() and not notification_file.exists():
        return

    try:
        mark_seen(session_key)
    except Exception:
        # Marking seen must never take down the focus-event handler.
        pass

    if notification_file.exists():
        try:
            notification_id = int(notification_file.read_text().strip())
            close_notification(notification_id)
            notification_file.unlink()  # Cleanup after closing
        except (ValueError, OSError):
            # Invalid content or file already removed - ignore
            pass


def main() -> None:
    """Start the daemon."""
    _lock_fp = ensure_single_instance()  # Keep reference to prevent GC releasing lock

    i3 = Connection()
    i3.on(Event.WINDOW_FOCUS, on_window_focus)
    i3.main()


if __name__ == "__main__":
    main()
