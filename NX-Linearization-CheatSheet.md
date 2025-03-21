# NX Method Resolution and Class Linearization Cheatsheet

## Overview
This cheatsheet explains class linearization in Next Scripting Framework (NX), which determines method resolution order (MRO) for multiple inheritance hierarchies.

## Key Concepts

### Linearization
Linearization transforms a class inheritance graph into a linear sequence used for method resolution. This is crucial for multiple inheritance to determine which superclass method to invoke.

### Constraints Types

1. **Direct Constraints**
   - Ensures subclass is before superclass in linearization
   - Maintains order from superclass list declarations

2. **Monotonicity Constraints**
   - Makes linearization monotonic (heritage-consistent)
   - Ensures each class's heritage ordering is preserved in linearization

3. **Local-Order Constraints**
   - Ensures subclasses appear before their parent classes
   - Prevents method resolution from violating inheritance relationships

## Important NX Commands

- `info precedence` - Returns linearized class order
- `info superclasses` - Returns immediate superclasses
- `info heritage` - Returns linearized inheritance chain
- `info subclasses -closure` - Returns all subclasses (direct and indirect)

## Test Cases

### Boat Example (DHHM 94)
Based on the paper by R. Ducournau, M. Habib, M. Huchard, and M.L. Mugnier.

```
Class hierarchy:
                 boat
                /    \
           dayboat   wheelboat
          /      \      /
  engineless  smallmultihull
        \        /
   pedalwheelboat  smallcatamaran
             \    /
             pedalo
```

- `dayboat` defines `max-distance` returning "5m"
- `wheelboat` defines `max-distance` returning "100m"
- For `pedalo` instances, `dayboat`'s method is called (returns "5m")

### Linearization Test
Verifies NX's linearization algorithm maintains:
- Direct constraints
- Monotonicity
- Local ordering

### Boat-Crash Test
Tests proper behavior during object destruction with complex inheritance.

## Reference
- Original paper: "Proposal for a Monotonic Multiple Inheritance Linearization" (DHHM 94)
- URL: https://www2.lirmm.fr/~ducour/Publis/DHHM-oopsla94.pdf 