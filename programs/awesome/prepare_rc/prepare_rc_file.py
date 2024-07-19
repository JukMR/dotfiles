import subprocess
from pathlib import Path


def get_network_interfaces_from_iwconfig() -> list[str]:
    """Run iwconfig and get the names of the interfases as a dict"""

    cmd: str = "iwconfig 2>&1 | awk '{print $1;}'"
    process_output = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=True)
    interfaces = process_output.stdout.split("\n")
    interfaces = list(filter(None, interfaces))
    print(interfaces)

    return list(set(interfaces))


def get_tabs_string(line: str) -> str:
    """Get the tabs from the line to keep the same indentation"""
    tabs_count = line.count("\t")
    tabs_string = "\t" * tabs_count

    return tabs_string


def find_line_to_replace(lines: list[str]) -> list[str]:
    """Find the line to replace and replace it with the new interfaces"""
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
    """Write the file to disk"""
    with open(output_path, "w", encoding="utf-8") as f:
        f.writelines(file)


def main() -> None:
    """Main function"""

    rc_lua_file = Path("../rc.lua")
    assert rc_lua_file.exists(), "rc.lua file not found"

    with open(rc_lua_file, "r", encoding="utf-8") as f:
        lines = f.readlines()

    new_file: list[str] = find_line_to_replace(lines=lines)

    output_file: Path = Path("rc_prepared.lua")
    output_file.touch(exist_ok=True)

    write_file_to_disk(file=new_file, output_path=output_file)


if __name__ == "__main__":
    main()
