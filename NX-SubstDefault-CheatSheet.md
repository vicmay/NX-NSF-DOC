# NX Framework: substdefault Cheatsheet

## Overview

The `substdefault` modifier in the NX/TCL framework allows for variable substitution in default values. This cheatsheet documents its behavior, options, and usage patterns.

## Basic Syntax

```tcl
:property {name:substdefault "value"}
:property {name:substdefault=OPTION "value"}
```

Where OPTION is a binary flag that controls the substitution behavior.

## Substitution Options

| Flag Notation | Decimal | Description |
|---------------|---------|-------------|
| 0b111         | 7       | Substitute all (variables, commands, backslashes) |
| 0b100         | 4       | Only substitute backslashes (-novars -nocommands) |
| 0b010         | 2       | Only substitute variables (-nocommands -nobackslashes) |
| 0b001         | 1       | Only substitute commands (-novars -nobackslashes) |
| 0b000         | 0       | Substitute nothing (-nocommands -novars -nobackslashes) |

## Examples with Results

Given input: `{a $::X [set x 4] \t}`

| Option        | Result              | Description |
|---------------|--------------------|-------------|
| No substdefault | `a $::X [set x 4] \t` | No substitution |
| :substdefault  | `a 123 4 	` | Default substitution (all) |
| :substdefault=0b111 | `a 123 4 	` | Substitute all |
| :substdefault=0b100 | `a $::X [set x 4] 	` | Only substitute backslashes |
| :substdefault=0b010 | `a 123 [set x 4] \t` | Only substitute variables |
| :substdefault=0b001 | `a $::X 4 \t` | Only substitute commands |
| :substdefault=0b000 | `a $::X [set x 4] \t` | No substitution |

## Context and Scoping

### General Considerations

- `[self]` is always set correctly in substdefault expressions

### Object Parameters

1. **Class-defined properties:**
   - Use caution when referring to instance variables, as users have no control over variable creation order
   - Referring to global or namespaced variables avoids creation order issues
   - `[current class]` called directly may not return expected results
   - Recommendation: Define methods to get default values instead of direct references

### Method Parameters

- Instance variables can be referenced directly in the default scope without namespace prefixes
- Method frame contains instance variables, allowing direct access

## Usage Patterns

### 1. Referring to Current Object

```tcl
:property {b:substdefault "[current]"}  # Evaluates to object name, e.g., "::d1"
```

### 2. Accessing Property Values

```tcl
:property -accessor public {c 1}
:property {param:substdefault "[:c get]"}  # Access another property's value
```

### 3. Accessing Instance Variables

```tcl
:property {d 2}
:property {param:substdefault "$d"}  # Direct reference to instance variable
```

### 4. Accessing Object Variables

```tcl
:object variable Y 1002
:property {param:substdefault "[:object getvar Y]"}  # Access object variable
```

### 5. Accessing Class Information

```tcl
:property {param:substdefault "[:current class]"}  # Get current class
```

### 6. Accessing Namespaced Variables

```tcl
namespace eval ::my-module { set X 1001 }
:method file-scoped {x} { namespace eval ::my-module [list set $x ] }
:property {param:substdefault "[:file-scoped X]"}  # Access namespaced variable
```

## Special Cases and Caveats

1. The value of `[current class]` directly in substdefault may not be as expected
   - Use a method that returns `[current class]` instead
   
2. When using substdefault in a namespace:
   - The scope of `[current]` is preserved (e.g., `::my-module::d1`)
   - Definition namespace can be accessed via `[nsf::definitionnamespace]`

3. Dynamic resolution:
   - Variable values are resolved dynamically at the time of evaluation
   - Changes to instance variables are reflected in subsequent evaluations

## Best Practices

1. Use methods to get default values instead of direct expressions
2. Leverage namespaces for better organization of variables
3. Be aware of the evaluation context when using substdefault
4. Use appropriate substitution flags based on security and performance needs
5. For complex cases, define helper methods that return the appropriate values 