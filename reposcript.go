package main

import (
	"bytes"
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"
	"time"
)

func execCommand(name string, args ...string) (string, error) {
	cmd := exec.Command(name, args...)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	output := stdout.String() + stderr.String()
	return output, err
}

func processRepo(scriptPath, branchName, repoPath string) error {
	if err := os.Chdir(repoPath); err != nil {
		return err
	}

	finalBranchName := branchName + "-" + strconv.Itoa(int(time.Now().Unix()))

	commands := []struct {
		name string
		args []string
	}{
		{"git", []string{"checkout", "main"}},
		{"git", []string{"pull", "--rebase"}},
		{"bash", []string{scriptPath}},
		{"git", []string{"checkout", "-b", finalBranchName}},
		{"git", []string{"add", "."}},
		{"git", []string{"commit", "-m", "Auto-generated changes from script: " + scriptPath}},
	}

	for _, cmd := range commands {
		output, err := execCommand(cmd.name, cmd.args...)
		if err != nil {
			log.Printf("Command failed: %s %v\nOutput: %s\nError: %v",
				cmd.name, cmd.args, output, err)
			return err
		}
	}

	output, err := execCommand("git", "push", "--set-upstream", "origin", finalBranchName)
	if err != nil {
		log.Printf("Failed to push changes: %v", err)
		return err
	}

	fmt.Println(output)

	if idx := strings.Index(output, "https://"); idx != -1 {
		line := strings.Split(output[idx:], "\n")
		prURL := strings.TrimSpace(line[0])
		log.Printf("Opening PR URL: %s", prURL)
		if err := openBrowser(prURL); err != nil {
			log.Printf("Failed to open browser: %v", err)
		}
	}

	return nil
}

func openBrowser(url string) error {
	var cmd *exec.Cmd
	switch runtime.GOOS {
	case "darwin":
		cmd = exec.Command("open", url)
	default:
		cmd = exec.Command("xdg-open", url)
	}
	return cmd.Start()
}

func main() {
	repositoryList := flag.String("repos", "", "repositories to run the script in")
	branchName := flag.String("branch", "", "the prefix for the branch created")
	script := flag.String("script", "", "the path to the script that will be ran in each repository")
	flag.Parse()

	if repositoryList == nil {
		log.Printf("usage: repupdate -script=<script-path> -repos=<repos-separated-by-comma> -branch=<branch prefix>")
		return
	}

	if branchName == nil {
		log.Printf("usage: repupdate -script=<script-path> -repos=<repos-separated-by-comma> -branch=<branch prefix>")
		return
	}

	if script == nil {
		log.Printf("usage: repupdate -script=<script-path> -repos=<paths-to-repos-separated-by-comma> -branch=<branch prefix>")
		return
	}

	originalWorkingDir, err := os.Getwd()
	if err != nil {
		log.Printf("error getting current working directory: %v", err)
		return
	}

	repos := strings.Split(*repositoryList, ",")
	scriptAbs, err := filepath.Abs(*script)
	if err != nil {
		log.Printf("failed to get script absolute path: %v", err)
		return
	}

	for _, repo := range repos {
		repoAbs, err := filepath.Abs(repo)
		if err != nil {
			log.Printf("error converting repo path to absolute: %v", err)
			return
		}

		if err := processRepo(scriptAbs, *branchName, repoAbs); err != nil {
			log.Printf("failed to process repo")
			return
		}

		if err := os.Chdir(originalWorkingDir); err != nil {
			return
		}
	}

	log.Printf("all repositories processed")
}
