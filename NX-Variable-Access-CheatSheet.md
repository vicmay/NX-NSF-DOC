# Next Scripting Framework (NX) Variable Access Cheatsheet

This cheatsheet documents variable access methods in the Next Scripting Framework (NX) as demonstrated in the test file `var-access.test`.

## Basic Variable Access Functions

The NX framework provides several functions in the `nsf::var` namespace for manipulating variables in objects:

| Function | Description | Syntax |
|----------|-------------|--------|
| `nsf::var::set` | Get or set a scalar variable | `nsf::var::set object varName ?value?` |
| `nsf::var::set -array` | Get or set an array variable | `nsf::var::set -array object arrayName ?keyValueList?` |
| `nsf::var::exists` | Check if a scalar variable exists | `nsf::var::exists object varName` |
| `nsf::var::exists -array` | Check if an array variable exists | `nsf::var::exists -array object arrayName` |
| `nsf::var::unset` | Unset a variable | `nsf::var::unset object varName` |
| `nsf::var::unset -nocomplain` | Unset a variable without error if not exists | `nsf::var::unset -nocomplain object varName` |
| `nsf::var::import` | Import a variable from an object | `nsf::var::import object varName` |

## Alternative Access Methods

NX provides alternative ways to access these functions:

### 1. Namespace Ensemble (`::nx::var1`)

```tcl
namespace eval ::nx::var1 {
  namespace ensemble create -map {
    exists ::nsf::var::exists 
    import ::nsf::var::import 
    set ::nsf::var::set
  }
}
```

Usage:
```tcl
::nx::var1 set object varName ?value?
::nx::var1 exists object varName
::nx::var1 import object varName
```

### 2. NX Object with Aliases (`::nx::var2`)

```tcl
::nx::Object create ::nx::var2 {
  :object alias exists ::nsf::var::exists 
  :object alias import ::nsf::var::import
  :object alias set ::nsf::var::set
}
```

Usage:
```tcl
::nx::var2 set object varName ?value?
::nx::var2 exists object varName
::nx::var2 import object varName
```

## Scalar Variables

```tcl
# Set a scalar variable
nsf::var::set objectName varName value  # Returns the value

# Get a scalar variable value
nsf::var::set objectName varName        # Returns the current value

# Check if a scalar variable exists
nsf::var::exists objectName varName     # Returns 1 if exists, 0 if not
```

## Array Variables

```tcl
# Set an array variable
nsf::var::set -array objectName arrayName {key1 value1 key2 value2}  # Returns empty string

# Get all array elements
nsf::var::set -array objectName arrayName  # Returns "key1 value1 key2 value2..."

# Check if an array variable exists
nsf::var::exists -array objectName arrayName  # Returns 1 if exists as array, 0 if not
```

## Unsetting Variables

```tcl
# Unset a variable (raises error if it doesn't exist)
nsf::var::unset objectName varName

# Unset a variable without complaining if it doesn't exist
nsf::var::unset -nocomplain objectName varName
```

## Importing Variables

```tcl
# Import a variable from another object
nsf::var::import sourceObject varName  # Makes varName accessible in current context
```

## Object Variable Access Methods

Within object methods, you can access object variables in several ways:

1. Using the colon prefix syntax:
```tcl
set :varName value   # Set object variable
incr :varName        # Increment object variable
```

2. Using `eval` on another object:
```tcl
otherObject eval {incr :varName}  # Increment varName in otherObject's context
```

3. Using variable import:
```tcl
::nsf::var::import otherObject varName  # Import from other object
incr varName                           # Modify the imported variable
```

## Information About Object Variables

```tcl
# List all variables in an object
objectName info vars  # Returns list of all variable names in the object
```

## Performance Considerations

The test file contains benchmarks comparing different variable access methods, suggesting that different approaches may have performance implications when used in high-frequency operations. 