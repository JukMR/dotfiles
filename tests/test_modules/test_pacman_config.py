from unittest.mock import patch, MagicMock
from pathlib import Path

from setup.modules.pacman_config import PacmanConfigModule


class TestPacmanConfigModule:
    def test_name(self):
        module = PacmanConfigModule()
        assert module.name == "pacman_config"

    def test_should_run_always_true(self):
        module = PacmanConfigModule()
        assert module.should_run() is True

    def test_run_dry_run(self, mock_installer, mock_subprocess, tmp_path):
        pacman_conf = tmp_path / "pacman.conf"
        pacman_conf.write_text("# Color\n# ParallelDownloads = 5\n")
        with patch("pathlib.Path.exists", return_value=True):
            with patch("pathlib.Path.read_text", return_value=pacman_conf.read_text()):
                with patch("pathlib.Path.write_text"):
                    module = PacmanConfigModule()
                    result = module.run(mock_installer, dry_run=True)
                    assert result is True
