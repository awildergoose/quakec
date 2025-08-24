import subprocess
import shutil
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import List, TypedDict


class Job(TypedDict):
    name: str
    src: Path
    out_log: Path
    flags: List[str]


BASE_DIR = Path(__file__).parent.parent
BIN_DIR = BASE_DIR / "bin"
PROGS_DIR = BASE_DIR / "progs"
BUILD_DIR = BASE_DIR / "build"
GAME_DIR = Path(r"G:\\Games\\nzp")
FTEQCC_EXE = BIN_DIR / "fteqcc-cli-win.exe"
IS_DEBUG = True

jobs: List[Job] = [
    {"name": "FTE CSQC", "src": PROGS_DIR / "csqc.src",
        "out_log": BIN_DIR / "csqc.log", "flags": ["-DFTE", "-Wall"]},
    {"name": "FTE SSQC", "src": PROGS_DIR / "ssqc.src",
        "out_log": BIN_DIR / "ssqc.log", "flags": ["-O3", "-DFTE", "-Wall"]},
    {"name": "FTE MenuQC", "src": PROGS_DIR / "menu.src",
        "out_log": BIN_DIR / "menu.log", "flags": ["-O3", "-DFTE", "-Wall"]},
]

standard_job: Job = {"name": "Standard SSQC", "src": PROGS_DIR / "ssqc.src",
                     "out_log": BIN_DIR / "std.log", "flags": ["-O3", "-Wall"]}


def adjust_flags_for_debug(jobs_list: List[Job]) -> None:
    if IS_DEBUG:
        for job in jobs_list:
            if "-O3" in job["flags"]:
                job["flags"].remove("-O3")
            job["flags"].append("-O0")


adjust_flags_for_debug(jobs)
adjust_flags_for_debug([standard_job])


def compile_job(job: Job) -> str:
    with open(job["out_log"], "w") as log_file:
        proc = subprocess.run(
            [FTEQCC_EXE, *job["flags"], "-srcfile", str(job["src"])],
            stdout=log_file,
            stderr=subprocess.STDOUT
        )

    with open(job["out_log"]) as log_file:
        for line in log_file:
            if any(keyword in line.lower() for keyword in ["warn", "err", "fatal"]):
                print(f"{job['name']} log: {line.strip()}")

    if proc.returncode != 0:
        raise RuntimeError(
            f"{job['name']} compilation failed with exit code {proc.returncode}")

    return job["name"]


def copy_build_files() -> None:
    files_to_copy = [
        ("fte/csprogs.dat", "csprogs.dat"),
        ("fte/csprogs.lno", "csprogs.lno"),
        ("fte/menu.dat", "menu.dat"),
        ("fte/qwprogs.dat", "qwprogs.dat"),
    ]
    for src_rel, dest_name in files_to_copy:
        src = BUILD_DIR / src_rel
        dest = GAME_DIR / "nzp" / dest_name
        shutil.copy(src, dest)


def run_game() -> None:
    subprocess.Popen([GAME_DIR / "nzportable-sdl64.exe",
                     "+map", "weapon_test"], cwd=GAME_DIR)


def main(include_standard: bool = False) -> None:
    all_jobs: List[Job] = jobs.copy()
    if include_standard:
        all_jobs.append(standard_job)

    results = {}

    with ThreadPoolExecutor(max_workers=4) as executor:
        futures = {executor.submit(compile_job, job)
                                   : job["name"] for job in all_jobs}
        for future in as_completed(futures):
            job_name = futures[future]
            try:
                results[job_name] = future.result()
            except Exception as e:
                print(f"Error in {job_name}: {e}")
                raise

    copy_build_files()
    run_game()


if __name__ == "__main__":
    main(include_standard=False)
