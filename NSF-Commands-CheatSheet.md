# NSF (Next Scripting Framework) Commands Cheatsheet

This cheatsheet is derived from the `nsf-cmd.test` file, which contains 792 lines of test cases illustrating the usage and behavior of NSF commands in Tcl.

## Core NSF Command Information Functions

### nsf::cmd::info

This is a core command that provides information about methods, procs, and commands:

```tcl
nsf::cmd::info [subcommand] [-context object] methodName [pattern]
```

Available subcommands:

| Subcommand | Description | Example |
|------------|-------------|---------|
| `args` | Returns argument names | `nsf::cmd::info args $handle` |
| `body` | Returns method body | `nsf::cmd::info body $handle` |
| `definition` | Returns method definition | `nsf::cmd::info definition $handle` |
| `exists` | Checks if method exists | `nsf::cmd::info exists $handle` |
| `registrationhandle` | Returns registration handle | `nsf::cmd::info registrationhandle $handle` |
| `definitionhandle` | Returns definition handle | `nsf::cmd::info definitionhandle $handle` |
| `origin` | Returns origin (for aliases) | `nsf::cmd::info origin $handle` |
| `parameter` | Returns parameter definitions | `nsf::cmd::info parameter $handle` |
| `syntax` | Returns syntax definitions | `nsf::cmd::info syntax $handle` |
| `type` | Returns type (scripted, cmd, alias, nsfproc) | `nsf::cmd::info type $handle` |
| `precondition` | Returns preconditions | `nsf::cmd::info precondition $handle` |
| `postcondition` | Returns postconditions | `nsf::cmd::info postcondition $handle` |
| `submethods` | Returns submethods | `nsf::cmd::info submethods $handle` |
| `returns` | Returns return type information | `nsf::cmd::info returns $handle` |

The `-context` flag provides object context for retrieving virtual arguments.

## Method Properties

### nsf::method::property

Manipulates method properties:

```tcl
nsf::method::property object [-per-object] method property value
```

Properties include:
- `call-protected` - Control access protection
- `debug` - Enable debug flag

### nsf::method::forward::property

Manipulates forwarded method properties:

```tcl
nsf::method::forward::property object [-per-object] method property value
```

Properties include:
- `verbose` - Control verbosity

## Process Handling

### nsf::proc

Creates and configures Tcl procedures with NSF features:

```tcl
nsf::proc [options] name arglist body
```

Options:
- `-debug` - Enable debug tracing
- `-deprecated` - Mark as deprecated

Example:
```tcl
nsf::proc ::foo {{-x 1} y:optional} {return $x-$y}
```

## Class and Object Management

### nx::Class Methods

```tcl
nx::Class create ClassName {
  :property name
  :public method methodName {args} {body}
  :create instanceName
}
```

### nx::Object Methods

Methods for object manipulation that appear in tests:
- `configure` - Configure object properties
- `new` - Create a new object instance 
- `create` - Create a named object instance

## Parameter Types and Annotations

NSF supports various parameter types and annotations:

| Annotation | Description | Example |
|------------|-------------|---------|
| `:integer` | Integer type constraint | `x:integer` |
| `:required` | Required parameter | `{-x:required}` |
| `:optional` | Optional parameter | `y:optional` |
| `:virtualobjectargs` | Virtual object arguments | `args:virtualobjectargs` |
| `:virtualclassargs` | Virtual class arguments | `args:virtualclassargs` |

## Namespace Management

NSF interacts with Tcl namespaces:

```tcl
namespace eval ::name {}     # Create namespace
namespace delete ::name      # Delete namespace
```

## Common Command Types

The tests demonstrate various command types:

1. **Scripted methods**: User-defined NX methods
2. **nsfproc commands**: NSF-enhanced procedures
3. **alias commands**: Methods that delegate to other commands
4. **cmd commands**: Native C-implemented commands

## Debugging and Error Handling

NSF provides debugging and error handling:

```tcl
nsf::proc -debug proc_name args body   # Enable debugging
nsf::log notice message                # Log messages
```

The `nsf::config` array contains configuration settings related to debugging:
- `::nsf::config(development)`
- `::nsf::config(memcount)`
- `::nsf::config(memtrace)`
- `::nsf::config(profile)`
- `::nsf::config(dtrace)`
- `::nsf::config(assertions)`

## Command Lookup and Method Handling

To get a method handle for inspection:

```tcl
set handle [object info lookup method methodName]
```

Various inquiries can be performed on handles:
```tcl
nsf::cmd::info args $handle
nsf::cmd::info body $handle
# etc.
```

## Ensemble Commands

NSF supports ensemble commands (multi-part commands):

```tcl
:public method "string match" {pattern string} {body}
```

These can be accessed and inspected using appropriate quoting:
```tcl
set handle [object info lookup method "string match"]
``` 