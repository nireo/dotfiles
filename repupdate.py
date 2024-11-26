import subprocess
import os
import sys
from typing import List
import logging
from datetime import datetime


def setup_logging():
    """Configure logging with timestamp and level."""
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )


def run_command(command: List[str], cwd: str) -> tuple[bool, str]:
    """
    Execute a shell command and return success status and output.

    Args:
        command: List of command components
        cwd: Working directory for command execution

    Returns:
        Tuple of (success: bool, output: str)
    """
    try:
        result = subprocess.run(
            command, cwd=cwd, capture_output=True, text=True, check=True
        )
        return True, result.stdout
    except subprocess.CalledProcessError as e:
        return False, f"Error: {e.stderr}"


def verify_script(script_path: str, repo_path: str) -> tuple[bool, str]:
    """
    Verify that the script exists and is executable.

    Args:
        script_path: Path to the script to verify
        repo_path: Path to the repository (for resolving relative paths)

    Returns:
        Tuple of (success: bool, resolved_path: str)
    """
    if os.path.isabs(script_path):
        full_path = script_path
    else:
        full_path = os.path.abspath(script_path)
        if not os.path.exists(full_path):
            full_path = os.path.abspath(os.path.join(repo_path, script_path))

    if not os.path.exists(full_path):
        return False, f"Script not found at: {full_path}"

    if not os.access(full_path, os.X_OK):
        try:
            os.chmod(full_path, 0o755)
            logging.info(f"Made script executable: {full_path}")
        except Exception as e:
            return False, f"Cannot make script executable: {str(e)}"

    return True, full_path


def process_repository(repo_path: str, script_path: str, new_branch_name: str) -> bool:
    """
    Process a single git repository: pull changes, run script, commit and push changes.

    Args:
        repo_path: Path to the git repository
        script_path: Path to the script to execute
        new_branch_name: Name of the new branch to create

    Returns:
        bool indicating success or failure
    """
    logging.info(f"Processing repository: {repo_path}")

    if not os.path.exists(repo_path):
        logging.error(f"Repository path does not exist: {repo_path}")
        return False

    script_success, resolved_script_path = verify_script(script_path, repo_path)
    if not script_success:
        logging.error(resolved_script_path)
        return False

    logging.info(f"Using script at: {resolved_script_path}")

    success, current_branch = run_command(
        ["git", "rev-parse", "--abbrev-ref", "HEAD"], repo_path
    )
    if not success:
        logging.error(f"Failed to get current branch: {current_branch}")
        return False

    main_branch = "main"
    success, output = run_command(["git", "checkout", main_branch], repo_path)
    if not success:
        success, output = run_command(["git", "checkout", "master"], repo_path)
        if not success:
            logging.error(f"Failed to checkout main/master branch: {output}")
            return False
        main_branch = "master"

    success, output = run_command(["git", "pull", "origin", main_branch], repo_path)
    if not success:
        logging.error(f"Failed to pull latest changes: {output}")
        return False

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    branch_name = f"{new_branch_name}_{timestamp}"
    success, output = run_command(["git", "checkout", "-b", branch_name], repo_path)
    if not success:
        logging.error(f"Failed to create new branch: {output}")
        return False

    try:
        logging.info(f"Executing script: {resolved_script_path}")
        success, output = run_command([resolved_script_path], repo_path)
        if not success:
            logging.error(f"Script execution failed: {output}")
            return False
    except Exception as e:
        logging.error(f"Script execution failed with exception: {str(e)}")
        return False

    success, status = run_command(["git", "status", "--porcelain"], repo_path)
    if not success:
        logging.error(f"Failed to check git status: {status}")
        return False

    if status.strip():
        success, output = run_command(["git", "add", "."], repo_path)
        if not success:
            logging.error(f"Failed to stage changes: {output}")
            return False

        commit_message = f"Automated changes from script execution on {timestamp}"
        success, output = run_command(
            ["git", "commit", "-m", commit_message], repo_path
        )
        if not success:
            logging.error(f"Failed to commit changes: {output}")
            return False

        success, output = run_command(["git", "push", "origin", branch_name], repo_path)
        if not success:
            logging.error(f"Failed to push changes: {output}")
            return False

        logging.info(f"Successfully pushed changes to branch: {branch_name}")
    else:
        logging.info("No changes detected after script execution")

    return True


def main():
    """Main function to process multiple repositories."""
    setup_logging()

    if len(sys.argv) < 3:
        print(
            "Usage: python script.py <script_path> <branch_name> <repo_path1> [repo_path2 ...]"
        )
        print("\nExample:")
        print(
            "  python script.py ./update_script.sh feature_update /path/to/repo1 /path/to/repo2"
        )
        print("\nNote: script_path can be absolute or relative to either:")
        print("  - Current working directory")
        print("  - Repository directory")
        sys.exit(1)

    script_path = sys.argv[1]
    new_branch_name = sys.argv[2]
    repo_paths = sys.argv[3:]

    success_count = 0
    for repo_path in repo_paths:
        if process_repository(repo_path, script_path, new_branch_name):
            success_count += 1
        else:
            logging.error(f"Failed to process repository: {repo_path}")

    total_repos = len(repo_paths)
    logging.info(f"Processed {success_count}/{total_repos} repositories successfully")

    if success_count != total_repos:
        sys.exit(1)


if __name__ == "__main__":
    main()
