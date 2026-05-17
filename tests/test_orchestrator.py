from unittest.mock import patch, MagicMock

from setup.orchestrator import Orchestrator, ModuleStatus, OrchestratorReport, ModuleResult
from setup.modules import ALL_MODULES


class TestOrchestrator:
    def test_list_modules(self, mock_installer):
        orchestrator = Orchestrator(installer=mock_installer)
        modules = orchestrator.list_modules()
        assert len(modules) == len(ALL_MODULES)
        for name, should_run in modules:
            assert isinstance(name, str)
            assert isinstance(should_run, bool)

    def test_skip_modules(self, mock_installer):
        orchestrator = Orchestrator(
            installer=mock_installer,
            skip_modules=["kitty", "awesome"],
        )
        modules = orchestrator.list_modules()
        skipped = [name for name, should_run in modules if not should_run]
        assert "kitty" in skipped
        assert "awesome" in skipped

    def test_run_all_dry_run(self, mock_installer):
        orchestrator = Orchestrator(
            installer=mock_installer,
            dry_run=True,
        )
        with patch.object(mock_installer, "install", return_value=True):
            with patch("setup.modules.kitty.KittyModule.should_run", return_value=False):
                with patch("setup.modules.zsh_ohmyzsh.ZshOhMyZshModule.should_run", return_value=False):
                    with patch("setup.modules.neovim.NeovimModule.should_run", return_value=False):
                        with patch("setup.modules.awesome.AwesomeModule.should_run", return_value=False):
                            with patch("setup.modules.ssh.SSHModule.should_run", return_value=False):
                                with patch("setup.modules.atuin.AtuinModule.should_run", return_value=False):
                                    with patch("setup.modules.zoxide.ZoxideModule.should_run", return_value=False):
                                        with patch("setup.modules.clipboard.ClipboardModule.should_run", return_value=False):
                                            with patch("setup.modules.cronjob.CronjobModule.should_run", return_value=False):
                                                with patch("setup.modules.git_diff_image.GitDiffImageModule.should_run", return_value=False):
                                                    with patch("setup.modules.pacman_config.PacmanConfigModule.should_run", return_value=False):
                                                        with patch("setup.modules.dotfiles.DotfilesModule.should_run", return_value=False):
                                                            with patch("setup.modules.git.GitModule.should_run", return_value=False):
                                                                with patch("setup.modules.picom.PicomModule.should_run", return_value=False):
                                                                    report = orchestrator.run_all()

        assert isinstance(report, OrchestratorReport)
        assert len(report.results) == len(ALL_MODULES)

    def test_report_all_success(self):
        report = OrchestratorReport(results=[
            ModuleResult(name="test", status=ModuleStatus.SUCCESS),
        ])
        assert report.all_success is True
        assert report.failed_count == 0
        assert report.success_count == 1

    def test_report_with_failure(self):
        report = OrchestratorReport(results=[
            ModuleResult(name="test1", status=ModuleStatus.SUCCESS),
            ModuleResult(name="test2", status=ModuleStatus.FAILED),
        ])
        assert report.all_success is False
        assert report.failed_count == 1

    def test_report_with_skip(self):
        report = OrchestratorReport(results=[
            ModuleResult(name="test1", status=ModuleStatus.SUCCESS),
            ModuleResult(name="test2", status=ModuleStatus.SKIPPED),
        ])
        assert report.all_success is True
        assert report.skipped_count == 1
