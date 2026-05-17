from unittest.mock import patch, MagicMock
from pathlib import Path

from setup.modules.awesome import AwesomeModule


class TestAwesomeModule:
    def test_name(self):
        module = AwesomeModule()
        assert module.name == "awesome"

    def test_should_run_when_no_widgets(self, mock_home):
        with patch("setup.modules.awesome.dir_exists", return_value=False):
            module = AwesomeModule()
            assert module.should_run() is True

    def test_should_run_when_widgets_exist(self, mock_home):
        with patch("setup.modules.awesome.dir_exists", return_value=True):
            module = AwesomeModule()
            assert module.should_run() is False

    def test_run_dry_run(self, mock_installer, mock_subprocess, mock_home):
        with patch("setup.modules.awesome.dir_exists", return_value=False):
            module = AwesomeModule()
            result = module.run(mock_installer, dry_run=True)
            assert result is True
