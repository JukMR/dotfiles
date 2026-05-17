from unittest.mock import patch, MagicMock
from pathlib import Path

from setup.modules.dotfiles import DotfilesModule


class TestDotfilesModule:
    def test_name(self):
        module = DotfilesModule()
        assert module.name == "dotfiles"

    def test_should_run_always_true(self):
        module = DotfilesModule()
        assert module.should_run() is True

    def test_run_dry_run(self, mock_installer, mock_subprocess, mock_home):
        stow_dir = mock_home / "stow" / "profiles" / "base"
        stow_dir.mkdir(parents=True)
        mock_stow = MagicMock()
        mock_stow.stow_package.return_value = True
        with patch.object(DotfilesModule, "_find_dotfiles_root", return_value=mock_home):
            with patch.object(DotfilesModule, "_detect_os_profile", return_value="manjaro"):
                with patch.dict("sys.modules", {"install_stow": mock_stow}):
                    module = DotfilesModule()
                    result = module.run(mock_installer, dry_run=True)
                    assert result is True
