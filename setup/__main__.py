import argparse
import sys
from pathlib import Path

from loguru import logger

from .installer import BaseInstaller
from .logging_config import setup_logging
from .os_detector import detect_os
from .orchestrator import Orchestrator


def get_installer(distro: str, dry_run: bool) -> BaseInstaller:
    if distro in ("manjaro", "arch"):
        from .installer_pacman import PacmanInstaller
        return PacmanInstaller(dry_run=dry_run)
    elif distro in ("ubuntu", "debian"):
        from .installer_apt import AptInstaller
        return AptInstaller(dry_run=dry_run)
    else:
        logger.warning(f"Unsupported distro '{distro}', defaulting to pacman installer")
        from .installer_pacman import PacmanInstaller
        return PacmanInstaller(dry_run=dry_run)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Dotfiles setup orchestrator",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python -m setup                      Auto-detect OS and run all modules
  python -m setup --dry-run            Show what would be done
  python -m setup --skip kitty,awesome Skip specific modules
  python -m setup --list               List available modules
  python -m setup --os ubuntu          Override OS detection
        """,
    )
    parser.add_argument(
        "--profile",
        default="base",
        help="Profile to use: base, manjaro, ubuntu, personal (default: base)",
    )
    parser.add_argument(
        "--os",
        default="auto",
        help="Override auto-detect: auto, manjaro, ubuntu (default: auto)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without executing",
    )
    parser.add_argument(
        "--skip",
        default="",
        help='Comma-separated list of modules to skip (e.g. "kitty,awesome")',
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable verbose output",
    )
    parser.add_argument(
        "--list",
        action="store_true",
        help="List available modules and their status",
    )
    parser.add_argument(
        "--log-file",
        default=None,
        help="Path to log file (default: ~/dotfiles_setup.log)",
    )

    args = parser.parse_args()

    log_file = Path(args.log_file) if args.log_file else Path.home() / "dotfiles_setup.log"
    setup_logging(verbose=args.verbose, log_file=log_file)

    if args.os == "auto":
        distro = detect_os()
    else:
        distro = args.os

    logger.info(f"Detected OS: {distro}")

    installer = get_installer(distro, dry_run=args.dry_run)

    skip_list = [s.strip() for s in args.skip.split(",") if s.strip()] if args.skip else []

    orchestrator = Orchestrator(
        installer=installer,
        dry_run=args.dry_run,
        skip_modules=skip_list,
    )

    if args.list:
        logger.info("Available modules:")
        for name, should_run in orchestrator.list_modules():
            status = "will run" if should_run else "will skip"
            logger.info(f"  {name}: {status}")
        sys.exit(0)

    if args.dry_run:
        logger.info("Running in dry-run mode - no changes will be made.")

    report = orchestrator.run_all()
    orchestrator.print_report(report)

    sys.exit(0 if report.all_success else 1)


if __name__ == "__main__":
    main()
