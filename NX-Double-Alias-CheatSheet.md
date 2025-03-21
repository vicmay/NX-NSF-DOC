# NX Method Aliasing Cheatsheet

This cheatsheet documents the behavior of method aliases in the NX framework, based on test cases.

## Basic Concepts

- **Method Aliasing**: Creating alternative names for methods
- **Double Aliasing**: Creating an alias that points to another alias
- **Redefinition**: Replacing existing methods with aliases

## Key Commands

- `::nsf::method::alias <object> <alias-name> <target>` - Creates a method alias
- `<object> public object method <name> {} {;}` - Defines a method on an object
- `info commands ::<path>` - Checks if a command exists
- `info exists ::nsf::alias(<object>,<alias>,1)` - Verifies alias registration

## Test Case Patterns

### Basic Method Aliasing

```tcl
nx::Object create o
::nsf::method::alias ::o aliasName ::targetProc
```

### Method Redefinition via Alias

```tcl
# Create a method
::o public object method FOO {} {;}
# Redefine it with an alias
::nsf::method::alias o FOO ::someOtherProc
```

### Double Aliases

```tcl
# Create first alias
::nsf::method::alias o FOO ::someProc
# Create second alias pointing to first
::nsf::method::alias o BAR ::o::FOO
```

## Common Scenarios

1. **Aliasing to a proc**:
   - `::nsf::method::alias o FOO ::foo`

2. **Aliasing to an object method**:
   - `::nsf::method::alias o BAR ::o::existingMethod`

3. **Aliasing to another alias**:
   - `::nsf::method::alias o BAR ::o::FOO` (where FOO is already an alias)

4. **Redefining methods with aliases**:
   - `::o public object method BAR {} {;}`
   - `::nsf::method::alias o BAR ::o::FOO`

## Behavior Notes

- Aliasing maintains internal references in `::nsf::alias` array
- Aliases persist even when target methods are redefined
- Commands created by aliases can be verified with `info commands`
- Fully qualified names (e.g., `::o::FOO`) are used to reference object methods
- Aliases survive method redefinition (as shown in alias-double-alias-object-method-redefine)

## Common Testing Patterns

The `?` operator tests a command and its expected output:
```tcl
? {info commands ::o::FOO} ::o::FOO "a command ::o::FOO exists"
```

This verifies that `info commands ::o::FOO` returns `::o::FOO`, with a description of "a command ::o::FOO exists". 