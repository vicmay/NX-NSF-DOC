# Tcl Interpreter Cheatsheet

This cheatsheet covers Tcl interpreter functionality, focusing on command hiding, object relationships, and interpreter management. Derived from test cases in the NextScripting Framework (NSF).

## Basic Interpreter Operations

| Command | Description |
|---------|-------------|
| `interp create` | Creates a new slave interpreter |
| `interp delete $i` | Destroys an interpreter |
| `interp issafe $i` | Returns 1 if the interpreter is safe, 0 otherwise |
| `$i eval {cmd}` | Evaluates a command in the slave interpreter |
| `::nsf::interp create` | Creates a new interpreter with NSF loaded |
| `::nsf::interp create -safe` | Creates a new safe interpreter with NSF loaded |

## Command Hiding

| Command | Description |
|---------|-------------|
| `$i hide cmdName` | Hides a command in the interpreter |
| `$i hide cmdName newName` | Hides a command under a different name |
| `interp expose $i hiddenCmd` | Re-exposes a hidden command |
| `interp expose $i hiddenCmd newName` | Re-exposes a hidden command under a different name |
| `interp hidden $i` | Lists all hidden commands |
| `interp invokehidden $i cmd args` | Invokes a hidden command |

## Hidden Command Characteristics

1. Hidden commands:
   - Are removed from the normal command table
   - Placed in a separate interpreter-wide hash table
   - Cannot be accessed via normal command invocation
   - Cannot use namespace qualifiers when hiding commands
   - Command structure is preserved internally
   - Object system relationships remain intact

2. Limitations:
   - Cannot hide namespace-qualified commands
   - Cannot directly dispatch to hidden commands
   - Hidden commands are cleaned up later than regular commands during interpreter deletion

## Object System Interaction

When working with NextScripting Framework (NSF) objects:

1. Object structure is preserved even when command is hidden:
   - Object instances remain in the object system
   - Object-class relationships are maintained
   - Mixin relationships are preserved
   - Introspection still functions for pattern-based queries

2. Method dispatch:
   - Hidden objects can still be accessed via their instances
   - Methods from hidden classes still function on instances
   - Existing mixin relationships continue to work

3. Alias handling:
   - Aliases to hidden procs/objects cannot be dispatched (target appears to have disappeared)
   - Re-exposing with original name restores alias functionality
   - Re-exposing with a different name does not automatically restore alias
   - The `::nsf::alias` array can be manually modified to fix aliases

## Object System Cleanup

```tcl
nsf::finalize [-keepvars]
```

- Shuts down NSF object system in an interpreter
- Similar to `interp delete` but preserves the interpreter
- `-keepvars` flag preserves global variables

## Destruction Behavior

1. Normal destruction:
   - Object destructors are called during cleanup
   - Hidden commands are processed after exit handlers

2. Explicit destruction:
   - Hidden objects can be destroyed via `interp invokehidden` 
   - After destruction, object is removed from hidden command table

3. Error handling in destroy:
   - Errors in destroy methods don't prevent cleanup
   - Self-deletion or self-hiding in destroy methods requires careful handling

## Mixin Relationships

1. Existing mixins continue to function when commands are hidden
2. Adding/removing mixins involving hidden classes is problematic
3. Mixin order computation handles hidden mixins properly

## Best Practices

1. When working with hidden commands:
   - Use `interp invokehidden` from the master interpreter
   - Don't rely on aliases to hidden commands
   - Be careful with destructors that modify command visibility

2. For cleanup:
   - Use `nsf::finalize` for controlled shutdown
   - Check hidden commands after cleanup with `interp hidden`

## Example: Hide and Re-expose

```tcl
# Create and hide a command
set i [interp create]
$i eval {nx::Object create ::o}
$i hide o

# Check status
interp hidden $i         # Returns "o"
$i eval {info commands ::o}  # Returns ""

# Access via hidden mechanism
interp invokehidden $i o method args

# Re-expose the command
interp expose $i o
```

---
*This cheatsheet covers 777 lines of the interp.test file, examining behavior of Tcl's interpreter command hiding mechanism and its interaction with the NextScripting Framework.* 