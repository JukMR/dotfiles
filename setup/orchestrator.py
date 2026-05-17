from dataclasses import dataclass, field
from enum import Enum

from loguru import logger

from .installer import BaseInstaller
from .modules import ALL_MODULES, get_all_module_names
from .modules.base import BaseModule


class ModuleStatus(Enum):
    SUCCESS = "success"
    SKIPPED = "skipped"
    FAILED = "failed"


@dataclass
class ModuleResult:
    name: str
    status: ModuleStatus
    message: str = ""


@dataclass
class OrchestratorReport:
    results: list[ModuleResult] = field(default_factory=list)

    @property
    def all_success(self) -> bool:
        return all(r.status != ModuleStatus.FAILED for r in self.results)

    @property
    def failed_count(self) -> int:
        return sum(1 for r in self.results if r.status == ModuleStatus.FAILED)

    @property
    def skipped_count(self) -> int:
        return sum(1 for r in self.results if r.status == ModuleStatus.SKIPPED)

    @property
    def success_count(self) -> int:
        return sum(1 for r in self.results if r.status == ModuleStatus.SUCCESS)


class Orchestrator:
    def __init__(
        self,
        installer: BaseInstaller,
        dry_run: bool = False,
        skip_modules: list[str] | None = None,
    ):
        self.installer = installer
        self.dry_run = dry_run
        self.skip_modules = set(skip_modules or [])

    def list_modules(self) -> list[tuple[str, bool]]:
        results = []
        for cls in ALL_MODULES:
            module = cls()
            should_run = module.should_run() and module.name not in self.skip_modules
            results.append((module.name, should_run))
        return results

    def run_all(self) -> OrchestratorReport:
        report = OrchestratorReport()

        available = get_all_module_names()
        for skip_name in self.skip_modules:
            if skip_name not in available:
                logger.warning(f"Unknown module to skip: {skip_name}")

        for cls in ALL_MODULES:
            module = cls()

            if module.name in self.skip_modules:
                result = ModuleResult(
                    name=module.name,
                    status=ModuleStatus.SKIPPED,
                    message="Skipped by user",
                )
                logger.info(f"[{module.name}] Skipped by user")
                report.results.append(result)
                continue

            if not module.should_run():
                result = ModuleResult(
                    name=module.name,
                    status=ModuleStatus.SKIPPED,
                    message="Already satisfied",
                )
                logger.info(f"[{module.name}] Already satisfied, skipping")
                report.results.append(result)
                continue

            logger.info(f"[{module.name}] Running...")
            try:
                success = module.run(self.installer, dry_run=self.dry_run)
                if success:
                    result = ModuleResult(
                        name=module.name,
                        status=ModuleStatus.SUCCESS,
                        message="Completed successfully",
                    )
                    logger.info(f"[{module.name}] Success")
                else:
                    result = ModuleResult(
                        name=module.name,
                        status=ModuleStatus.FAILED,
                        message="Module returned failure",
                    )
                    logger.error(f"[{module.name}] Failed")
            except Exception as e:
                result = ModuleResult(
                    name=module.name,
                    status=ModuleStatus.FAILED,
                    message=str(e),
                )
                logger.error(f"[{module.name}] Exception: {e}")

            report.results.append(result)

        return report

    def print_report(self, report: OrchestratorReport) -> None:
        logger.info("=" * 50)
        logger.info("SETUP REPORT")
        logger.info("=" * 50)

        for result in report.results:
            icon = {
                ModuleStatus.SUCCESS: "✓",
                ModuleStatus.SKIPPED: "○",
                ModuleStatus.FAILED: "✗",
            }[result.status]
            logger.info(f"  {icon} {result.name}: {result.message}")

        logger.info("-" * 50)
        logger.info(
            f"Summary: {report.success_count} succeeded, "
            f"{report.skipped_count} skipped, "
            f"{report.failed_count} failed"
        )

        if report.failed_count > 0:
            logger.error("Some modules failed!")
        else:
            logger.info("All modules completed successfully.")
