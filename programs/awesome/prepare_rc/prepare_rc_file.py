import subprocess
from pathlib import Path


def load_file_in_lines(file: Path) -> list[str]:
    """ """

    with open(file, "r", encoding="utf-8") as f:
        return f.readlines()


def get_network_interfaces_from_iwconfig() -> list[str]:
    """Run iwconfig and get the names of the interfases as a dict"""

    cmd = "iwconfig 2>&1 | awk '{print $1;}'"
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=True)
    interfaces = result.stdout.split("\n")
    interfaces = list(filter(None, interfaces))
    print(interfaces)

    return list(set(interfaces))


def get_tabs_string(line: str) -> str:
    tabs_count = line.count("\t")
    tabs_string = "\t" * tabs_count

    return tabs_string


def find_line_to_replace(lines: list[str]) -> list[str]:
    new_file: list[str] = []

    for line in lines:
        if "interfaces = { " in line:
            new_interfaces: list[str] = get_network_interfaces_from_iwconfig()
            new_interfaces_formatted: str = " , ".join([f'"{interface}"' for interface in new_interfaces if interface])
            tabs_string: str = get_tabs_string(line)
            line: str = f"{tabs_string}interfaces = {{ {new_interfaces_formatted} }},\n "

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
