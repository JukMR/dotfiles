import subprocess
from pathlib import Path


def load_file_in_lines(file: Path) -> list[str]:
    """ """

    with open(file, "r", encoding="utf-8") as f:
        return f.readlines()


def get_network_interfaces_from_iwconfig() -> list[str]:
    """Run iwconfig and get the names of the interfases as a dict"""

    cmd = "iwconfig"
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    interfaces = result.stdout.split("\n")

    return list(set(interfaces))


def find_line_to_replace(lines: list[str]) -> list[str]:
    new_file: list[str] = []

    for line in lines:
        if 'interfaces = { "wlp3s0", "enp2s0", "lo" },' in line:
            new_interfaces: list[str] = get_network_interfaces_from_iwconfig()
            new_interfaces_formatted: str = ",".join([interface for interface in new_interfaces if interface])
            line = f"interfaces = {new_interfaces_formatted}, "

        new_file.append(line)

    return new_file


def write_file_to_disk(file: list[str], output_path: Path) -> None:
    with open(output_path, "w", encoding="utf-8") as f:
        f.writelines(file)


def main() -> None:
    """"""

    rc_lua_file = Path("../rc.lua")
    assert rc_lua_file.exists(), "rc.lua file not found"

    lines = load_file_in_lines(file=rc_lua_file)
    new_file: list[str] = find_line_to_replace(lines=lines)

    output_file: Path = Path("rc_prepared.lua")
    output_file.touch(exist_ok=True)

    write_file_to_disk(file=new_file, output_path=output_file)


if __name__ == "__main__":
    main()
