import pytest
from pathlib import Path
from unittest.mock import patch, MagicMock

from setup.installer import BaseInstaller


class MockInstaller(BaseInstaller):
    def __init__(self, dry_run=False, installed_packages=None):
        super().__init__(dry_run=dry_run)
        self._installed = set(installed_packages or [])
        self.install_calls = []

    def install(self, packages):
        self.install_calls.append(packages)
        self._installed.update(packages)
        return True

    def is_installed(self, package):
        return package in self._installed


@pytest.fixture
def mock_installer():
    return MockInstaller()


@pytest.fixture
def mock_subprocess():
    with patch("setup.utils.subprocess.run") as mock:
        mock.return_value = MagicMock(returncode=0, stdout="", stderr="")
        yield mock


@pytest.fixture
def mock_os_release(tmp_path):
    os_release = tmp_path / "os-release"
    with patch("setup.os_detector.OS_RELEASE_PATH", os_release):
        yield os_release


@pytest.fixture
def mock_home(tmp_path):
    with patch("pathlib.Path.home", return_value=tmp_path):
        yield tmp_path
