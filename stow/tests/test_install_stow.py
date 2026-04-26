import io
import shutil
import sys
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT))

import install_stow


class PackageLayoutValidationTests(unittest.TestCase):
    def test_flags_suspicious_xdg_root_file(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            package_dir = Path(tmpdir) / "profiles" / "base" / "lazygit"
            config_file = package_dir / ".config" / "config.yml"
            config_file.parent.mkdir(parents=True)
            config_file.write_text("customCommands: []\n", encoding="utf-8")

            result = install_stow.validate_package_layout(package_dir, "lazygit", Path(tmpdir) / "home")

        self.assertFalse(result.ok)
        self.assertIn(".config/config.yml", result.errors[0])
        self.assertIn(".config/lazygit/config.yml", result.errors[0])

    def test_accepts_existing_kitty_and_vim_packages(self) -> None:
        target = Path("/tmp/stow-validation-home")

        kitty = install_stow.validate_package_layout(
            REPO_ROOT / "profiles" / "base" / "kitty",
            "kitty",
            target,
        )
        vim = install_stow.validate_package_layout(
            REPO_ROOT / "profiles" / "base" / "vim",
            "vim",
            target,
        )

        self.assertTrue(kitty.ok)
        self.assertTrue(vim.ok)


@unittest.skipUnless(shutil.which("stow"), "GNU Stow is required")
class StowPackageTests(unittest.TestCase):
    def test_dry_run_lists_expected_nested_lazygit_target(self) -> None:
        with tempfile.TemporaryDirectory() as repo_dir, tempfile.TemporaryDirectory() as home_dir:
            package_dir = Path(repo_dir) / "profiles" / "base" / "lazygit"
            config_file = package_dir / ".config" / "lazygit" / "config.yml"
            config_file.parent.mkdir(parents=True)
            config_file.write_text("customCommands: []\n", encoding="utf-8")

            stdout = io.StringIO()
            stderr = io.StringIO()
            with redirect_stdout(stdout), redirect_stderr(stderr):
                ok = install_stow.stow_package(
                    Path(repo_dir),
                    "base",
                    "lazygit",
                    dry_run=True,
                    target=Path(home_dir),
                )

        self.assertTrue(ok)
        self.assertEqual("", stderr.getvalue())
        self.assertIn(str(Path(home_dir) / ".config" / "lazygit" / "config.yml"), stdout.getvalue())

    def test_rejects_malformed_package_before_linking(self) -> None:
        with tempfile.TemporaryDirectory() as repo_dir, tempfile.TemporaryDirectory() as home_dir:
            package_dir = Path(repo_dir) / "profiles" / "base" / "lazygit"
            config_file = package_dir / ".config" / "config.yml"
            config_file.parent.mkdir(parents=True)
            config_file.write_text("customCommands: []\n", encoding="utf-8")

            stdout = io.StringIO()
            stderr = io.StringIO()
            with redirect_stdout(stdout), redirect_stderr(stderr):
                ok = install_stow.stow_package(
                    Path(repo_dir),
                    "base",
                    "lazygit",
                    target=Path(home_dir),
                )

            self.assertFalse(ok)
            self.assertFalse((Path(home_dir) / ".config" / "config.yml").exists())
            self.assertIn("Invalid package layout for lazygit", stderr.getvalue())
            self.assertIn(".config/config.yml", stderr.getvalue())

    def test_links_valid_package_to_nested_xdg_target(self) -> None:
        with tempfile.TemporaryDirectory() as repo_dir, tempfile.TemporaryDirectory() as home_dir:
            package_dir = Path(repo_dir) / "profiles" / "base" / "lazygit"
            config_file = package_dir / ".config" / "lazygit" / "config.yml"
            config_file.parent.mkdir(parents=True)
            config_file.write_text("customCommands: []\n", encoding="utf-8")

            stdout = io.StringIO()
            stderr = io.StringIO()
            with redirect_stdout(stdout), redirect_stderr(stderr):
                ok = install_stow.stow_package(
                    Path(repo_dir),
                    "base",
                    "lazygit",
                    target=Path(home_dir),
                )

            target_file = Path(home_dir) / ".config" / "lazygit" / "config.yml"
            self.assertTrue(ok)
            self.assertEqual("", stderr.getvalue())
            self.assertTrue(target_file.exists())
            self.assertEqual(config_file.resolve(), target_file.resolve())
            self.assertFalse((Path(home_dir) / ".config" / "config.yml").exists())

    def test_adopt_uses_native_stow_behavior(self) -> None:
        with tempfile.TemporaryDirectory() as repo_dir, tempfile.TemporaryDirectory() as home_dir:
            package_dir = Path(repo_dir) / "profiles" / "base" / "lazygit"
            config_file = package_dir / ".config" / "lazygit" / "config.yml"
            config_file.parent.mkdir(parents=True)
            config_file.write_text("source-version\n", encoding="utf-8")

            target_file = Path(home_dir) / ".config" / "lazygit" / "config.yml"
            target_file.parent.mkdir(parents=True)
            target_file.write_text("target-version\n", encoding="utf-8")

            stdout = io.StringIO()
            stderr = io.StringIO()
            with redirect_stdout(stdout), redirect_stderr(stderr):
                ok = install_stow.stow_package(
                    Path(repo_dir),
                    "base",
                    "lazygit",
                    adopt=True,
                    target=Path(home_dir),
                )

            self.assertTrue(ok)
            self.assertEqual("", stderr.getvalue())
            self.assertTrue(target_file.exists())
            self.assertEqual("target-version\n", config_file.read_text(encoding="utf-8"))
            self.assertEqual(config_file.resolve(), target_file.resolve())
