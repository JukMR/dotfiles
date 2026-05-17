from pathlib import Path

from ..installer import BaseInstaller
from ..utils import dir_exists, file_contains, run_cmd
from .base import BaseModule

SERVICE_CONTENT = """[Unit]
Description=SSH key agent

[Service]
Type=simple
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -D -a $SSH_AUTH_SOCK

[Install]
WantedBy=default.target
"""


class SSHModule(BaseModule):
    @property
    def name(self) -> str:
        return "ssh"

    def should_run(self) -> bool:
        service_file = Path.home() / ".config" / "systemd" / "user" / "ssh-agent.service"
        return not service_file.exists()

    def run(self, installer: BaseInstaller, dry_run: bool = False) -> bool:
        from ..utils import logger

        service_dir = Path.home() / ".config" / "systemd" / "user"
        service_file = service_dir / "ssh-agent.service"

        if not dry_run:
            service_dir.mkdir(parents=True, exist_ok=True)
            if not service_file.exists():
                service_file.write_text(SERVICE_CONTENT)
                logger.info("Created ssh-agent.service")

        run_cmd(["systemctl", "--user", "enable", "ssh-agent"], dry_run=dry_run)
        run_cmd(["systemctl", "--user", "start", "ssh-agent"], dry_run=dry_run)

        zshrc = Path.home() / ".zshrc"
        sock_line = 'export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"'
        if not file_contains(str(zshrc), "SSH_AUTH_SOCK"):
            if not dry_run:
                with open(zshrc, "a") as f:
                    f.write(sock_line + "\n")
                logger.info("Added SSH_AUTH_SOCK to .zshrc")
        else:
            logger.info("SSH_AUTH_SOCK already in .zshrc")

        logger.info("SSH agent setup complete.")
        return True
