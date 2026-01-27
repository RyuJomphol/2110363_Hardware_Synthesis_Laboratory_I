import os

files = [
    "./problem-1/tests/moore_fsm_test.py",
    "./problem-2/tests/bcd_counter_test.py",
    "./problem-3/tests/debouncer_samp_3_test.py",
    "./problem-3/tests/debouncer_samp_5_test.py",
]

if __name__ == "__main__":
    for test_file in files:
        cmd = f"python {test_file}"
        print(f"Running tests in {test_file}...")
        os.system(cmd)
        print("\n")