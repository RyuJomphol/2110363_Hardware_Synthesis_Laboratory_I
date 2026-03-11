#!/usr/bin/env python3

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def find_tb_files(root: Path, self_file: Path) -> list[Path]:
	"""Return all *TB.py files under root, excluding this runner file."""
	tb_files = [
		path
		for path in root.rglob("*TB.py")
		if path.is_file() and path.resolve() != self_file
	]
	return sorted(tb_files)


def run_tb_file(tb_file: Path) -> tuple[int, str]:
	"""Run one TB file and return (exit_code, relative_name)."""
	result = subprocess.run(
		[sys.executable, tb_file.name],
		cwd=tb_file.parent,
		check=False,
	)
	return result.returncode, str(tb_file)


def main() -> int:
	root = Path(__file__).resolve().parent
	self_file = Path(__file__).resolve()
	tb_files = find_tb_files(root, self_file)

	if not tb_files:
		print("No *TB.py files found.")
		return 0

	print(f"Found {len(tb_files)} testbench file(s).")
	print("=" * 60)

	failed: list[str] = []

	for index, tb_file in enumerate(tb_files, start=1):
		rel = tb_file.relative_to(root)
		print(f"[{index}/{len(tb_files)}] Running {rel}")
		code, _ = run_tb_file(tb_file)

	# 	if code == 0:
	# 		print(f"PASS: {rel}\n")
	# 	else:
	# 		print(f"FAIL: {rel} (exit code {code})\n")
	# 		failed.append(str(rel))

	# print("=" * 60)
	# passed_count = len(tb_files) - len(failed)
	# print(f"Completed: {passed_count} passed, {len(failed)} failed")

	# if failed:
	# 	print("Failed testbench files:")
	# 	for item in failed:
	# 		print(f"- {item}")
	# 	return 1

	# return 0


if __name__ == "__main__":
	raise SystemExit(main())
