# NX Accessor Cheatsheet

## Property Types and Behaviors

### 1. Basic Property (No Accessor)
```tcl
:property {p1a 1}
```
- Basic property with default value
- Accessible via `cget` and `configure`
- No direct get/set methods

### 2. Public Accessor Property
```tcl
:property -accessor public {p2a 2}
```
Features:
- Adds public get/set methods
- Supports `cget` and `configure`
- Adds `unset` capability
- Methods available:
  - `object p2a get`
  - `object p2a set value`
  - `object p2a unset`
  - `object p2a unset -nocomplain`

### 3. Incremental Property
```tcl
:property -incremental {p3a 3}
```
Features:
- Similar to public accessor
- Adds value tracking capabilities
- Methods available:
  - `object p3a get`
  - `object p3a set value`
  - `object p3a unset`

## Custom Value Setting

You can customize value setting behavior by defining a custom `value=set` method:
```tcl
:public object method value=set {obj prop value} {
    nx::var::set $obj $prop [incr value]
}
```
This allows you to:
- Intercept value assignments
- Modify values before storage
- Implement custom validation
- Add side effects to value changes

## Common Operations

1. Getting Values:
   ```tcl
   object cget -propertyName
   object propertyName get
   ```

2. Setting Values:
   ```tcl
   object configure -propertyName value
   object propertyName set value
   ```

3. Unsetting Values:
   ```tcl
   object propertyName unset
   object propertyName unset -nocomplain  # Won't error if property doesn't exist
   ```

## Error Handling

- Accessing unset properties raises: `can't read "propertyName": no such variable`
- Unsetting non-existent properties raises: `can't unset "propertyName": no such variable`
- Use `-nocomplain` with unset to suppress errors

## Best Practices

1. Use `-accessor public` when you need direct get/set methods
2. Use `-incremental` when you need value tracking
3. Implement custom `value=set` for specialized behavior
4. Always handle potential unset states in your code
5. Use `-nocomplain` when uncertain about property existence

## Notes

- Properties can combine different features (e.g., public accessor with custom value=set)
- The `configure` interface is always available regardless of accessor type
- Custom value setters can modify the input value before storage 