from unittest.mock import patch, MagicMock

from setup.installer_pacman import PacmanInstaller
from setup.installer_apt import AptInstaller


class TestPacmanInstaller:
    def test_install(self, mock_subprocess):
        installer = PacmanInstaller()
        result = installer.install(["git", "zsh"])
        assert result is True
        mock_subprocess.assert_called_once()
        call_args = mock_subprocess.call_args[0][0]
        assert call_args == ["sudo", "pacman", "-S", "--noconfirm", "--needed", "git", "zsh"]

    def test_install_dry_run(self, mock_subprocess):
        installer = PacmanInstaller(dry_run=True)
        result = installer.install(["git"])
        assert result is True
        mock_subprocess.assert_not_called()

    def test_is_installed(self, mock_subprocess):
        installer = PacmanInstaller()
        installer.is_installed("git")
        call_args = mock_subprocess.call_args[0][0]
        assert call_args == ["pacman", "-Qi", "git"]

    def test_is_installed_false(self, mock_subprocess):
        mock_subprocess.return_value = MagicMock(returncode=1, stdout="", stderr="")
        installer = PacmanInstaller()
        assert installer.is_installed("nonexistent") is False

    def test_install_aur(self, mock_subprocess):
        with patch("setup.installer_pacman.command_exists", return_value=True):
            installer = PacmanInstaller()
            result = installer.install_aur("visual-studio-code-bin")
            assert result is True
            call_args = mock_subprocess.call_args[0][0]
            assert call_args == ["yay", "-S", "--noconfirm", "visual-studio-code-bin"]

    def test_install_aur_no_yay(self, mock_subprocess):
        with patch("setup.installer_pacman.command_exists", return_value=False):
            installer = PacmanInstaller()
            result = installer.install_aur("some-aur-package")
            assert result is False


class TestAptInstaller:
    def test_install(self, mock_subprocess):
        installer = AptInstaller()
        result = installer.install(["git", "zsh"])
        assert result is True
        call_args = mock_subprocess.call_args[0][0]
        assert call_args == ["sudo", "apt", "install", "-y", "git", "zsh"]

    def test_install_dry_run(self, mock_subprocess):
        installer = AptInstaller(dry_run=True)
        result = installer.install(["git"])
        assert result is True
        mock_subprocess.assert_not_called()

    def test_is_installed(self, mock_subprocess):
        installer = AptInstaller()
        installer.is_installed("git")
        call_args = mock_subprocess.call_args[0][0]
        assert call_args == ["dpkg", "-s", "git"]

    def test_install_aur_delegates_to_apt(self, mock_subprocess):
        installer = AptInstaller()
        result = installer.install_aur("copyq")
        assert result is True
        call_args = mock_subprocess.call_args[0][0]
        assert call_args == ["sudo", "apt", "install", "-y", "copyq"]
