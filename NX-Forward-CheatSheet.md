# NX Framework Forward Command Cheatsheet

## Basic Forward Command Syntax

```tcl
object public [object] forward methodName targetObject|targetCommand [args...]
```

## Basic Usage Patterns

### Simple Delegation

```tcl
# Delegate method calls to another object
nx::Object create dog
nx::Object create tail {
  :public object method wag args { return $args }
}
dog public object forward wag tail %proc
```

### Executing Commands

```tcl
# Forward to Tcl commands
nx::Object create obj {
  :public object forward addOne expr 1 +
}
# obj addOne 5  -> returns 6
```

## Special Substitution Variables

| Variable | Description |
|----------|-------------|
| `%self`  | Reference to the current object |
| `%method`| Name of the current method |
| `%proc`  | Refers to the target procedure |
| `%%`     | Literal percent sign |
| `%1`     | First argument or default from list |

## Options

| Option | Description |
|--------|-------------|
| `-frame object` | Execute in object's variable scope |
| `-prefix string` | Add prefix to method name |
| `-verbose` | Enable verbose mode |

## Positional Substitutions

```tcl
# Add argument at the end
obj public object forward foo list {%@end value}
# obj foo 1 2 3  -> returns [1 2 3 value]

# Add argument at specific position
obj public object forward foo list {%@2 value}
# obj foo 1 2 3  -> returns [1 value 2 3]

# Add argument at beginning
obj public object forward foo list {%@1 value}
# obj foo 1 2 3  -> returns [value 1 2 3]

# Add argument at second-to-last position
obj public object forward foo list {%@-1 value}
# obj foo 1 2 3  -> returns [1 2 value 3]
```

## Dynamic Command Selection with %1

```tcl
# Choose from multiple methods based on first argument
obj public object forward foo %self {%1 {methodA methodB}}

# With default values
obj public object forward foo %self {%1 {methodA methodB}} {%1 {defaultA defaultB}}
```

## Argument Count-Based Forwarding

```tcl
nx::Object create obj {
  :public object forward f %self [list %argclindex [list a b c]]
  :object method a args {...}
  :object method b args {...}
  :object method c args {...}
}
# obj f       -> calls method a
# obj f 1     -> calls method b with argument 1
# obj f 1 2   -> calls method c with arguments 1 2
```

## Introspection

```tcl
# List all forwarders
obj info object methods -type forwarder

# Get forwarder definition
obj info object method definition forwardName
```

## Variable Scope Access (Frame Object)

```tcl
nx::Class create X {
  :property {x 1}
  :public forward Incr -frame object incr
}
# Allows accessing object variables
```

## Fully-Qualified Target Shortcut

```tcl
# Shortcut for forwarding to a fully-qualified command
obj public object forward ::ns1::foo
```

## Using Object Variables in Forwarded Commands

```tcl
# Access object variable
obj public object forward x* expr {%:eval {set :x}} *
``` 