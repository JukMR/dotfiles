import subprocess
import unittest
from pathlib import Path
from unittest.mock import call, mock_open, patch

import prepare_rc_file  # Replace with the actual name of your module


class TestYourModule(unittest.TestCase):
    def test_load_file_in_lines(self) -> None:
        mock_path = Path("fake_path")
        mock_file_content = "line1\nline2\nline3\n"
        with patch("builtins.open", mock_open(read_data=mock_file_content)) as mock_file:
            lines = prepare_rc_file.load_file_in_lines(mock_path)
            mock_file.assert_called_once_with(mock_path, "r", encoding="utf-8")
            self.assertEqual(lines, ["line1\n", "line2\n", "line3\n"])

    @patch("subprocess.run")
    def test_get_network_interfaces_from_iwconfig(self, mock_run) -> None:
        mock_result = subprocess.CompletedProcess(args=["iwconfig"], returncode=0, stdout="eth0\nwlan0\nlo\n")
        mock_run.return_value = mock_result

        interfaces = prepare_rc_file.get_network_interfaces_from_iwconfig()
        self.assertEqual(sorted(interfaces), sorted(["eth0", "wlan0", "lo"]))

    def test_get_tabs_string(self):
        line = "\t\tline"
        tabs_string = prepare_rc_file.get_tabs_string(line)
        self.assertEqual(tabs_string, "\t\t")

    @patch("prepare_rc_file.get_network_interfaces_from_iwconfig")
    def test_find_line_to_replace(self, mock_get_network_interfaces_from_iwconfig) -> None:
        mock_get_network_interfaces_from_iwconfig.return_value = ["eth0", "wlan0"]
        lines = ['interfaces = { "old_interface" },\n', "some other line\n"]
        expected_output = ['interfaces = { "eth0" , "wlan0" },\n ', "some other line\n"]
        new_file = prepare_rc_file.find_line_to_replace(lines)
        self.assertEqual(new_file, expected_output)

    @patch("builtins.open", new_callable=mock_open)
    def test_write_file_to_disk(self, mock_file):
        mock_output_path = Path("output_path")
        mock_file_content = ["line1\n", "line2\n"]
        prepare_rc_file.write_file_to_disk(mock_file_content, mock_output_path)
        mock_file.assert_called_once_with(mock_output_path, "w", encoding="utf-8")
        mock_file().writelines.assert_called_once_with(mock_file_content)

    @patch("prepare_rc_file.load_file_in_lines")
    @patch("prepare_rc_file.find_line_to_replace")
    @patch("prepare_rc_file.write_file_to_disk")
    def test_main(self, mock_write_file_to_disk, mock_find_line_to_replace, mock_load_file_in_lines):
        mock_path = Path("../rc.lua")
        mock_output_path = Path("rc_prepared.lua")
        mock_lines = ["line1\n", "line2\n"]
        mock_new_file = ["new_line1\n", "new_line2\n"]

        with patch("pathlib.Path.exists", return_value=True):
            with patch("pathlib.Path.touch"):
                mock_load_file_in_lines.return_value = mock_lines
                mock_find_line_to_replace.return_value = mock_new_file

                prepare_rc_file.main()

                mock_load_file_in_lines.assert_called_once_with(file=mock_path)
                mock_find_line_to_replace.assert_called_once_with(lines=mock_lines)
                mock_write_file_to_disk.assert_called_once_with(file=mock_new_file, output_path=mock_output_path)


if __name__ == "__main__":
    unittest.main()
