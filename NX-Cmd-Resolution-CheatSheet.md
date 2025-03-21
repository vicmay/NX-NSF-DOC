# Command Resolution in NX and XOTcl - Cheatsheet

## Overview
This cheatsheet explains command resolution behavior in NX and XOTcl, based on test cases that explore how command literals like `self` and `next` are resolved in different object system contexts.

## Key Concepts

### Command Literal Pool
- Command literals are stored in a global literal pool
- Different object systems (NX, XOTcl) can share the same namespace
- Command resolution must respect the underlying object system's context

### Test Case 1: `self` Resolution

#### NX Class Example
```tcl
nx::Class create ::xowiki::C {
    :public method foo {} {return [self]}
}
```
- The `self` command is resolved against `nx::self` in the `::xowiki` namespace
- Returns the object instance when called

#### XOTcl Class Example
```tcl
xotcl::Class create xowiki::Link
xowiki::Link instproc init {} {
    set class [self class]
}
```
- The same `self` command must resolve against `xotcl::self`
- Works independently of NX's resolution of `self`

### Test Case 2: `self` and `next` Resolution

#### NX Inheritance Example
```tcl
nx::Class create xowiki::C1 {
    :public method foo {x y} {set s [self]; return $x-$y-C1}
}
nx::Class create xowiki::C2 -superclass xowiki::C1 {
    :public method foo {x y} {return [next [list $x $y]]}
}
```
- Both `self` and `next` commands are added to the global command literal pool
- `next` properly chains method calls in inheritance hierarchy

#### XOTcl Inheritance Example
```tcl
xotcl::Class create xowiki::X1
xowiki::X1 instproc foo {x y} {
    return $x-$y-[self class]
}
xotcl::Class create xowiki::X2 -superclass xowiki::X1
```
- Similar inheritance pattern in XOTcl
- Command resolution remains specific to XOTcl despite shared namespace

## Important Notes

1. **Namespace Sharing**
   - Multiple object systems can coexist in the same namespace
   - Command resolution must be context-aware

2. **Command Resolution Rules**
   - Commands resolve based on the object system context
   - NX commands resolve to NX implementations
   - XOTcl commands resolve to XOTcl implementations

3. **Literal Pool Management**
   - Global literal pool must maintain proper resolution
   - No interference between different object systems
   - Command shimmering doesn't affect proper resolution

## Testing Patterns

1. **Basic Resolution Test**
   ```tcl
   ? {c1 foo} ::c1
   ```

2. **Inheritance Chain Test**
   ```tcl
   ? {[xowiki::C2 new] foo 1 2} 1-2-C1
   ```

3. **Cross-System Verification**
   ```tcl
   ? {[xowiki::X2 new] foo 1 2} 1-2-::xowiki::X1
   ```

## Best Practices

1. Always be aware of the object system context when using `self` and `next`
2. Test command resolution in mixed object system environments
3. Verify inheritance chains work correctly across object system boundaries
4. Consider namespace implications when designing class hierarchies 