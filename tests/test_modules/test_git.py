from unittest.mock import patch, MagicMock

from setup.modules.git import GitModule


class TestGitModule:
    def test_name(self):
        module = GitModule()
        assert module.name == "git"

    def test_should_run_always_true(self):
        module = GitModule()
        assert module.should_run() is True

    def test_run_dry_run(self, mock_installer, mock_subprocess):
        module = GitModule()
        result = module.run(mock_installer, dry_run=True)
        assert result is True

    def test_run_sets_aliases(self, mock_installer, mock_subprocess):
        module = GitModule()
        module.run(mock_installer, dry_run=False)
        calls = mock_subprocess.call_args_list
        alias_calls = [c for c in calls if "alias.lola" in str(c)]
        assert len(alias_calls) >= 1
