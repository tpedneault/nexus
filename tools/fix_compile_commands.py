#!/usr/bin/env python3
"""
Fix compile_commands.json for clangd LSP use.

This script:
1. Converts Docker container paths (/workspace/) to Windows host paths
2. Translates TI compiler flags to Clang-compatible flags so clangd can parse them
"""

import json
import re
import sys
from pathlib import Path


def translate_ti_flags_to_clang(command_str: str, workspace_root_str: str) -> str:
    """
    Convert TI ARM compiler flags to Clang-compatible flags.

    Args:
        command_str: Original TI compiler command line
        workspace_root_str: Root directory path (for path translation)

    Returns:
        Clang-compatible command string
    """
    # Replace the compiler executable
    command_str = re.sub(r'/opt/ti-cgt-arm/[^/]+/bin/armcl', 'clang', command_str)

    # Convert --include_path=<path> to -I<path>
    # Also convert --include_path <path> to -I<path>
    command_str = re.sub(r'--include_path[= ]([^\s]+)', r'-I\1', command_str)

    # Convert --c_file=<file> to just the file (it's redundant)
    command_str = re.sub(r'--c_file=', '', command_str)

    # Convert --output_file=<file> to -o <file>
    command_str = re.sub(r'--output_file=', '-o ', command_str)

    # Remove TI-specific flags that have no Clang equivalent
    ti_flags_to_remove = [
        r'--compile_only',
        r'--silicon_version=\S+',
        r'--code_state=\S+',
        r'--float_support=\S+',
        r'--endian=\S+',
        r'--enum_type=\S+',
        r'--abi=\S+',
        r'--diag_\S+',
        r'--display_error_number',
        r'--symdebug:\S+',
    ]

    for pattern in ti_flags_to_remove:
        command_str = re.sub(pattern, '', command_str)

    # Add Clang resource directory FIRST (for stddef.h, stdint.h, etc.)
    # Then TI headers (for string.h and other libc functions)
    # This way Clang's builtins take precedence over TI's
    command_str = f'-isystem C:/Program Files/LLVM/lib/clang/21/include {command_str}'

    # Add Clang target architecture
    command_str += ' --target=armv7r-none-eabi -mbig-endian'

    # Clean up extra whitespace
    command_str = ' '.join(command_str.split())

    return command_str


def fix_compile_commands(compile_commands_path: Path, workspace_root: Path) -> None:
    """
    Fix compile_commands.json for clangd compatibility.

    Args:
        compile_commands_path: Path to compile_commands.json
        workspace_root: Root directory of the workspace (e.g., D:/nexus)
    """
    if not compile_commands_path.exists():
        print(f"Error: {compile_commands_path} not found", file=sys.stderr)
        sys.exit(1)

    # Read the compile commands
    with open(compile_commands_path, 'r') as f:
        commands = json.load(f)

    # Convert workspace_root to forward slashes for consistency
    workspace_root_str = str(workspace_root).replace('\\', '/')

    # Fix paths and translate flags in each command
    for cmd in commands:
        # Fix the directory path
        if 'directory' in cmd:
            cmd['directory'] = cmd['directory'].replace('/workspace', workspace_root_str)

        # Fix the file path
        if 'file' in cmd:
            cmd['file'] = cmd['file'].replace('/workspace', workspace_root_str)

        # Fix and translate the command string
        if 'command' in cmd:
            # First, fix paths
            cmd['command'] = cmd['command'].replace('/workspace', workspace_root_str)
            # Replace Docker-only TI include path with local copy (TI format)
            cmd['command'] = re.sub(
                r'--include_path=/opt/ti-cgt-arm/[^\s]+/include',
                f'--include_path={workspace_root_str}/build/ti-headers',
                cmd['command']
            )
            # Then translate TI flags to Clang flags
            cmd['command'] = translate_ti_flags_to_clang(cmd['command'], workspace_root_str)
            # Also replace after translation (in case some -I flags weren't converted)
            cmd['command'] = re.sub(
                r'-I/opt/ti-cgt-arm/[^\s]+/include',
                f'-I{workspace_root_str}/build/ti-headers',
                cmd['command']
            )

        # Fix paths in arguments array (if present)
        if 'arguments' in cmd:
            # Translate arguments array (similar to command string)
            new_args = []
            skip_next = False

            for i, arg in enumerate(cmd['arguments']):
                if skip_next:
                    skip_next = False
                    continue

                # Fix paths
                arg = arg.replace('/workspace', workspace_root_str)

                # Convert --include_path to -I
                if arg.startswith('--include_path='):
                    path = arg.split('=', 1)[1]
                    new_args.append(f'-I{path}')
                elif arg == '--include_path' and i + 1 < len(cmd['arguments']):
                    path = cmd['arguments'][i + 1].replace('/workspace', workspace_root_str)
                    new_args.append(f'-I{path}')
                    skip_next = True
                # Skip TI-specific flags
                elif any(arg.startswith(pattern.replace(r'\S+', '').replace('\\', ''))
                        for pattern in ['--silicon_version', '--code_state', '--float_support',
                                      '--endian', '--enum_type', '--abi', '--diag_',
                                      '--display_error_number', '--symdebug:', '--compile_only',
                                      '--c_file=', '--output_file=']):
                    continue
                # Replace Docker-only TI include path with local copy
                elif arg.startswith('-I/opt/ti-cgt-arm/'):
                    new_args.append(f'-I{workspace_root_str}/build/ti-headers')
                    continue
                # Replace compiler
                elif arg.endswith('/armcl'):
                    new_args.append('clang')
                else:
                    new_args.append(arg)

            # Add Clang resource directory first (for stddef.h, stdint.h precedence)
            new_args.insert(1, '-isystem')
            new_args.insert(2, 'C:/Program Files/LLVM/lib/clang/21/include')

            # Add target architecture
            new_args.extend(['--target=armv7r-none-eabi', '-mbig-endian'])
            cmd['arguments'] = new_args

    # Write back the fixed compile commands
    with open(compile_commands_path, 'w') as f:
        json.dump(commands, f, indent=2)

    print(f"Fixed {len(commands)} compilation database entries")
    print(f"Replaced /workspace with {workspace_root_str}")
    print(f"Translated TI compiler flags to Clang-compatible flags")


def main():
    # Get the workspace root (parent of tools directory)
    script_dir = Path(__file__).parent
    workspace_root = script_dir.parent

    # Path to compile_commands.json
    compile_commands_path = workspace_root / 'build' / 'compile_commands.json'

    # Fix the paths and translate flags
    fix_compile_commands(compile_commands_path, workspace_root)


if __name__ == '__main__':
    main()
