# Nx Parameter Disposition Cheatsheet

## Parameter Dispositions
Parameter dispositions provide ways to invoke methods when object parameters are configured. The test file focuses on two main disposition types: `alias` and `forward`.

## Basic Syntax

### Alias Disposition
```tcl
parameterName:alias[,options]
-parameterName:alias[,options]
```

### Forward Disposition
```tcl
parameterName:forward,method=SPEC[,options]
-parameterName:forward,method=SPEC[,options]
```

Where `SPEC` can contain these placeholders:
- `%self`: Reference to the current object
- `%method`: Method name

## Key Characteristics

1. Dispositions are restricted to object parameters only
2. Aliases and forwarders do not set instance variables
3. Parameters are limited to a single value, unless using special techniques
4. Both `alias` and `forward` work with public and protected target methods

## Common Options

### `noarg` Option (for alias only)
```tcl
-bar:alias,noarg  # Calls method 'bar' without arguments
```

### `method` Option
```tcl
-foo:alias,method=bar  # Aliasing to a specific method
-foo:forward,method=%self bar  # Forwarding to a specific method
```

### Type Constraints
```tcl
-foo:alias,boolean
-foo:forward,method=%self %method,integer
```

### Multiplicity
```tcl
-foo:alias,1..*,boolean  # List of boolean values
-foo:alias,0..*,false    # Optional list of false values
```

## Common Patterns

### Positional vs. Non-positional
```tcl
foo:alias         # Positional parameter
-foo:alias        # Non-positional parameter
```

### Handling Multiple Arguments
```tcl
# Passing multiple arguments as a list
-multi-escape:alias
[C new -multi-escape [list X Y]]

# Using eval in a forward
-multi-2:forward,method=eval %self %method
[C new -multi-2 {X Y}]
```

### Residual Args Handling
```tcl
args:alias,method=Residualargs,args
```

## Object Targets for Dispositions

Dispositions can target not only methods but also objects:

```tcl
# Aliasing to an object
T setObjectParams x:alias,method=::obj

# Using the defaultmethod of an object
T setObjectParams [list [list z:alias,noarg ""]]
```

When working with object targets:
- Using `noarg` with an object target calls the object's defaultmethod
- Chained dispatches work by forwarding messages: `tt->z(::obj)->YYY()`
- Method handles can be used as targets: `x:alias,method=$methods(z)`
- Tcl procedures can be aliased: `x:alias,method=::baz`

## XOTcl Compatibility

### XOTcl Parameter Handling

```tcl
# XOTcl class with parameters
::xotcl::Class create XC -parameter {a b c}

# Residual args handling for init
::XD instproc init args {
  set :args $args
}

# Standard XOTcl parameter structure
"-instfilter:filterreg,alias,0..n -superclass:alias,0..n -instmixin:mixinreg,alias,0..n \
 {-__default_metaclass ::xotcl::Class} {-__default_superclass ::xotcl::Object} \
 -mixin:mixinreg,alias,0..n -filter:filterreg,alias,0..n -class:class,alias args:alias,method=residualargs,args"
```

### XOTcl Uplevel/Upvar Resolution

```tcl
# XOTcl uplevel/upvar with callstack resolution
xotcl::Class C -instproc call {x} {
  :uplevel [list set ix $x]
  :upvar $x _
  incr _
}
```

## Return Value Interactions
```tcl
# Return value checking with alias disposition
-foo:alias,true
set methods(foo) [R public method foo {x:true} -returns false {...}]
```

## Callstack Considerations

When using uplevel/upvar with alias and forward dispositions:
- Level -1 → C-level frame
- Level -2 → Actual caller frame
- Target methods of alias parameters don't have full callstack transparency

Use these for proper callstack handling:
```tcl
:uplevel [list set ix $x]  # NSF/Nx uplevel method
:upvar $x _               # NSF/Nx upvar method
uplevel [current callinglevel] [list set ix $x]  # Using callinglevel
uplevel [current activelevel] [list set ix $x]   # Using activelevel
```

## Init and Configuration

### `init` Method

```tcl
# Calling init via alias disposition
C setObjectParams {-a init:alias,noarg -b:integer}
```

The init method is called only once during object creation, even when configured via alias.

### Default Superclass Handling

```tcl
# Default superclass behavior
nx::Class create P
# P inherits from ::nx::Object by default

# Explicit superclass
nx::Class create Q -superclass P

# configure does not reset superclass to default
Q configure
# Q still inherits from P, not ::nx::Object
```

### initcmd Interactions

```tcl
# initcmd with default
C setObjectParams {{__init:cmd :foo}}

# optional initcmd
C setObjectParams {initcmd:cmd,optional}

# initcmd with default value
C setObjectParams {{initcmd:cmd ""}}

# initcmd cannot use noarg
C setObjectParams {initcmd:cmd,noarg}  # ERROR: noarg only for alias
```

## Common Error Messages

- "parameter option 'alias' not allowed"
- "parameter option 'noarg' only allowed for parameter type 'alias'"
- "parameter option 'method=' only allowed for parameter types 'alias', 'forward' and 'slotset'"
- "parameter invocation types cannot be used with option 'switch'"
- "multiplicity settings for variable argument parameter 'args' not allowed"
- "parameter option 'args' invalid for parameter 'a'; only allowed for last parameter"
- "refuse to redefine parameter type of 'args' from type 'integer' to type 'args'"

## Examples

### Basic Alias
```tcl
C setObjectParams {-foo:alias}
C create c1 -foo value
```

### Basic Forward
```tcl
C setObjectParams {{{-foo:forward,method=%self %method}}}
C create c1 -foo value
```

### Alias with Default Value
```tcl
C setObjectParams {{-foo:alias "defaultValue"}}
C create c1
```

### Alias with No Arguments
```tcl
C setObjectParams {-foo:alias,noarg}
C create c1 -foo  # Calls method 'foo' with no arguments
```

### Forward with Complex Logic
```tcl
C method multi-mix {-x y args} {
  set :[current method] --x-$x--y-$y--args-$args
}
C setObjectParams {{{-multi-mix:forward,method=eval %self %method}}}
[C new -multi-mix [list -x X Y Z 1 2]]
```

### Custom User-defined Type
```tcl
::nx::methodParameterSlot object method type=mytype {name value} {
  if {$value < 1 || $value > 3} {
    error "Value '$value' of parameter $name is not between 1 and 3"
  }
}
C setObjectParams [list [list -baz:alias,mytype]]
```

## Integration with Other Features

### With Submethods
```tcl
C public method "FOO foo" {}
C setObjectParams [list FOO:alias]
```

### With Mixins
```tcl
C mixins set M
C setObjectParams [list FOO:alias]
```

### With Filters
```tcl
C public method intercept args {
  next
}
C filters set intercept
C setObjectParams [list FOO:alias]
```

### With Residual Args (XOTcl compatibility)
```tcl
C setObjectParams {args:alias,method=Residualargs,args}
```

## Implementation Notes

- The `method` parameter name is used consistently, though it may seem more fitting for alias than forward
- Return value checkers can't use disposition types
- Callstack position must be considered when using uplevel/upvar
- Ensemble callstack structures differ between ordinary dispatch and parameter dispatch
- In parameter (alias) dispatch, configure() introduces additional frames in the callstack 
