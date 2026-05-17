from unittest.mock import patch

from setup.os_detector import detect_os, _parse_os_release


def test_parse_os_release():
    content = 'ID=manjaro\nID_LIKE=arch\nPRETTY_NAME="Manjaro Linux"'
    assert _parse_os_release(content, "ID") == "manjaro"
    assert _parse_os_release(content, "ID_LIKE") == "arch"
    assert _parse_os_release(content, "PRETTY_NAME") == "Manjaro Linux"
    assert _parse_os_release(content, "MISSING") == ""


def test_detect_os_manjaro(mock_os_release):
    mock_os_release.write_text('ID=manjaro\nID_LIKE=arch\n')
    assert detect_os() == "manjaro"


def test_detect_os_ubuntu(mock_os_release):
    mock_os_release.write_text('ID=ubuntu\nID_LIKE=debian\n')
    assert detect_os() == "ubuntu"


def test_detect_os_arch(mock_os_release):
    mock_os_release.write_text('ID=arch\n')
    assert detect_os() == "arch"


def test_detect_os_debian(mock_os_release):
    mock_os_release.write_text('ID=debian\n')
    assert detect_os() == "debian"


def test_detect_os_derived(mock_os_release):
    mock_os_release.write_text('ID=linuxmint\nID_LIKE=ubuntu\n')
    assert detect_os() == "ubuntu"


def test_detect_os_other(mock_os_release):
    mock_os_release.write_text('ID=unknown\n')
    assert detect_os() == "other"


def test_detect_os_missing(mock_os_release):
    with patch("setup.os_detector.Path.exists", return_value=False):
        assert detect_os() == "other"
