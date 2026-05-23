import { spawn } from "node:child_process";

export function runProcess(command, args = [], options = {}) {
  return new Promise((resolve) => {
    const child = spawn(command, args, {
      cwd: options.cwd || process.cwd(),
      shell: false,
      windowsHide: true
    });
    let stdout = "";
    let stderr = "";

    child.stdout.on("data", (chunk) => {
      stdout += chunk.toString();
    });
    child.stderr.on("data", (chunk) => {
      stderr += chunk.toString();
    });
    child.on("error", (error) => {
      resolve({
        status: "FAIL",
        exitCode: null,
        stdout,
        stderr: `${stderr}${error.message}`
      });
    });
    child.on("close", (exitCode) => {
      resolve({
        status: exitCode === 0 ? "PASS" : "FAIL",
        exitCode,
        stdout,
        stderr
      });
    });
  });
}
