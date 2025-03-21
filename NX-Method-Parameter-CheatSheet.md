# NextScript (NX) Method Parameter Cheatsheet

## Basic Parameter Syntax

### Non-positional Parameters (with dash prefix)
```tcl
nsf::proc p1 {-x} {return [list [info exists x]]}
```
- Non-positional parameters are prefixed with `-` (e.g., `-x`)
- Called with: `p1 -x 1`
- Error if value missing: `p1 -x` → "value for parameter '-x' expected"
- Error for invalid param: `p1 -y` → "invalid non-positional argument '-y', valid are: -x"

### Positional Parameters
```tcl
nsf::proc p3 {1 -2 -3 4} {return [list ${1} [info exists 2] [info exists 3] ${4}]}
```
- Positional parameters don't have dash prefix or are defined with numbers
- Order matters for positional parameters
- Called with: `p3 -4 -3 -2 -1` → "-4 0 1 -1"

## Special Parameter Options

### The `nodashalnum` Option
```tcl
nsf::proc p2b {-x args:nodashalnum} {return [list [info exists x] $args]}
```
- Treats arguments starting with dash as potential flags, not values
- Without nodashalnum: `p2a -x 1 -y` → {1 -y} (accepts `-y` as arg)
- With nodashalnum: `p2b -x 1 -y` → error (rejects `-y` as arg)
- Affects handling of arguments starting with dash

### Double Dash (`--`) Usage
- Used to mark end of non-positional arguments
- Everything after `--` is treated as positional argument
- Example: `p2b -x 1 -- -y` (passes `-y` as positional)

## Parameter Abbreviations

```tcl
nsf::proc x {-super -super11 -superclass -super12} {...}
```
- Parameter names can be abbreviated if unambiguous
- `-super` → refers to `-super`
- `-super1` → ambiguous (could be `-super11` or `-super12`)
- `-superc` → refers to `-superclass`

## Error Message Patterns

### Too Many Arguments
```
invalid argument '2', maybe too many arguments; should be "p1 ?-x /value/?"
```

### Invalid Parameter Name
```
invalid non-positional argument '-y', valid are: -x;
should be "p1 ?-x /value/?"
```

### Missing Parameter Value
```
value for parameter '-x' expected
```

## Object-Oriented Usage

```tcl
Class create C {
  :public method p1 {-x} {return [list [info exists x]]}
}
```
- Methods follow same parameter rules as procedures
- Error handling includes object context in messages

## Ensemble Commands

```tcl
C info subclasses ?-closure? ?-dependent? ?/pattern/?
```
- Pattern arguments in ensembles may have `nodashalnum` option
- Affects how dash-prefixed patterns are interpreted
- `C info subclasses -- -a` (pattern matching class named "-a")

## Advanced Parameter Tricks

### Numeric Parameter Names
```tcl
nsf::proc y {-1 y:integer} {return [info exists 1]-$y}
```
- Parameter names can be numbers (e.g., `-1`, `1`)
- Special handling required when passing negative numbers as values
- `y -- -1` to pass `-1` as a positional argument

## Argument Processing

- Arguments are processed left to right
- Non-positional arguments can appear before positional ones
- Double dash `--` marks end of non-positional arguments
- Parameter values with leading dash require special handling 