import os

dirs = [
    "problem-1",
    "problem-2",
]

if __name__ == "__main__":
    # Get the path of the current script
    current_path = os.path.dirname(os.path.abspath(__file__))
    os.chdir(current_path)
    
    for dir_name in dirs:
        dir_path = os.path.join(current_path, dir_name)
        if os.path.isdir(dir_path):
            os.chdir(dir_path)
            print(f"Running tests in {dir_name}...")
            os.system("python tb.py")
            os.chdir(current_path)
        else:
            print(f"Directory {dir_name} does not exist.")
    