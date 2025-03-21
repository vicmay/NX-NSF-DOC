# NXSH Shell Test Cheatsheet

## Overview
This document provides a comprehensive guide to the nxsh shell test file in the Next Scripting Framework (NSF). The test file verifies functionality of the nxsh shell, a Tcl shell with Next Scripting Framework extensions.

## Environment Requirements
- Non-Windows platforms (test skips on Windows environments without bash-like shells)
- NSF compiled without memcount (test skips when `$::nsf::config(memcount) == 1`)

## Test Structure
The test is implemented using `nx::test` framework and consists of a single test case called `nxsh`.

## Shell Initialization
```tcl
set rootDir [file join {*}[lrange [file split [file normalize [info script]]] 0 end-2]]
set nxsh [file join $rootDir nxsh]
```

## Command Line Usage Patterns

### Interactive Mode
- `nxsh` - Launches interactive shell
- Test checks: `exec $nxsh << "$run; exit"` produces expected output

### Script Execution
- `nxsh script.tcl` - Executes a Tcl script with nxsh
- `nxsh script.tcl arg1 arg2 ...` - Passes arguments to script
- Script access to args: `$argc` (count), `$argv` (list of arguments)

### Command Execution (-c option)
- `nxsh -c "command"` - Executes a single command
- `nxsh -c "command" arg1 arg2 ...` - Executes command with arguments
- `nxsh -c << "command"` - Executes command from stdin 

## Test Cases Summary

### File Operations
- Verifies nxsh executable exists and is executable
- Tests temporary file creation and execution
- Tests error handling for non-existent files

### Command Line Arguments
- Checks argument passing and handling
- Tests `$argc` and `$argv` handling

### Exit Code Handling
- Tests various exit code scenarios
- `exit 0` - Normal exit, no error
- `exit 1`, `exit 2`, etc. - Abnormal exit, error reported
- Tests error capturing and error code extraction

### Error Handling
- Tests try/catch behavior with exit codes
- Tests error handling within nx::Object contexts
- Tests finally block execution

## Utility Functions
```tcl
# Extract first line of command output
proc getFirstLine {cmd} {
  catch [list uplevel 1 $cmd] res opts
  set lines [split $res \n]
  return [string trim [lindex $lines 0]]
}
```

## Test Syntax
- `?` command is used for assertions
- Format: `? [test-command] expected-result`

## Platform-Specific Notes
- Test is compatible with Tcl 8.6 or newer for certain features
- Tests use shell I/O redirection (`<<`) to provide input to nxsh
- Special handling for stderr with `-ignorestderr` option

## Common Patterns
- Error testing: `? [list exec $nxsh -c "exit 1"] "child process exited abnormally"`
- Command execution testing: `? [list exec $nxsh -c $run a b c] "3-a-b-c"`
- File existence: `? [list file exists $nxsh] 1`

## Error Code Extraction Example
```tcl
? [list catch [list exec $nxsh -c "exit 5"] ::res ::opts] "1"
? {set ::res} "child process exited abnormally"
? {lindex [dict get $::opts -errorcode] end} "5"
``` 