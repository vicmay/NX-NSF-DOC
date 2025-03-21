# NX Runtime Assertion Checking (RAC) Cheatsheet

This cheatsheet provides a comprehensive overview of Runtime Assertion Checking in NX, based on the conceptual baseline of the Eiffel specification (ECMA Standard 367, 2nd edition, 2006).

## Table of Contents
- [Basic Concepts](#basic-concepts)
- [Assertion Types](#assertion-types)
- [Setting Up Assertions](#setting-up-assertions)
- [Activating/Deactivating Assertions](#activatingdeactivating-assertions)
- [Assertion Evaluation Order](#assertion-evaluation-order)
- [Inheritance and Assertions](#inheritance-and-assertions)
- [Limitations and Issues](#limitations-and-issues)

## Basic Concepts

Runtime Assertion Checking (RAC) is a technique for validating correctness conditions at runtime. In NX, RAC is implemented with the following main features:

- **Class invariants**: Conditions that must hold true for all instances of a class
- **Object invariants**: Conditions that must hold true for a specific object
- **Preconditions**: Conditions that must be true before a method executes
- **Postconditions**: Conditions that must be true after a method executes

## Assertion Types

### Class Invariants

```tcl
nx::Class create MyClass -invariant {
  {# invariant_name: }
  {${:property1} >= ${:property2}}
} {
  # class definition...
}
```

### Object Invariants

```tcl
MyObject configure -object-invariant {
  {${:property} > 0}
}
```

### Method Preconditions and Postconditions

```tcl
MyClass public method myMethod {} {
  # method body
} -precondition {
  {# pre_condition_name: }
  {${:property} > 0}
} -postcondition {
  {# post_condition_name: }
  {${:property} > ${:anotherProperty}}
}
```

## Setting Up Assertions

### Setting Class Invariants

```tcl
# Direct interface
::nsf::method::assertion MyClass class-invar $invariantList

# Object interface
MyClass configure -invariant $invariantList
```

### Setting Object Invariants

```tcl
# Direct interface
::nsf::method::assertion myObject object-invar $invariantList

# Object interface
myObject configure -object-invariant $invariantList
```

### Reading Invariants

```tcl
# Get class invariant
MyClass cget -invariant

# Get object invariant
myObject cget -object-invariant
```

## Activating/Deactivating Assertions

Assertions can be activated or deactivated selectively:

```tcl
# Activate all assertions for an object
::nsf::method::assertion myObject check all

# Activate only preconditions
::nsf::method::assertion myObject check pre

# Activate only postconditions
::nsf::method::assertion myObject check post

# Activate only class invariants
::nsf::method::assertion myObject check class-invar

# Deactivate all assertions for an object
::nsf::method::assertion myObject check {}
```

## Assertion Evaluation Order

The actual evaluation order of assertions in NX:
```
Entry -> PRE -> INVAR -> (METHOD BODY) -> POST -> INVAR -> Exit
```

Expected order according to ECMA-367 §8.23.26:
```
Entry -> INVAR -> PRE -> (METHOD BODY) -> INVAR -> POST -> Exit
```

## Inheritance and Assertions

### Invariants

Class invariants respect inheritance according to the Eiffel specification:
- Child class invariants include parent invariants
- Invariants are joined with logical AND
- Parent clauses take precedence in reverse linearization order

### Preconditions

According to the Eiffel specification:
- Preconditions should weaken in subclasses
- Preconditions are joined with logical OR
- Parent clauses take precedence in reverse linearization order
- The rule for preconditions is "require else" (OR joining)

### Postconditions

According to the Eiffel specification:
- Postconditions should strengthen in subclasses
- Postconditions are joined with logical AND
- Parent clauses take precedence in reverse linearization order
- The rule for postconditions is "ensure then" (AND joining)

### Shadowing Methods

For shadowing methods:
- Using `next` ensures proper execution of parent assertions
- Without `next`, parent assertions may not be properly executed

## Limitations and Issues

1. Error reporting does not clearly distinguish between assertion failures and underlying errors

2. When invariant assertions fail, the object state might still be modified effectively

3. Class invariants are not evaluated after instance creation by default

4. The order of resolution for class invariants in the inheritance hierarchy is not always correct

5. Class invariants are not checked before preconditions as expected by the Eiffel specification

6. Proper access to method arguments in assertion expressions is needed

7. Parameter type checks should be performed before precondition and invariant checks

8. Error messages can be misleading ("in proc 'v'" for invariant failures)

## Usage Examples

### Basic Class with Invariant

```tcl
nx::Class create Account -invariant {
  {# sufficient_balance: }
  {${:balance} >= ${:minimumBalance}}
} {
  :property -accessor public balance:integer
  :property -accessor public minimumBalance:integer
}
```

### Method with Preconditions and Postconditions

```tcl
Account public method deposit {sum:integer} {
  incr :depositTransactions
  incr :balance $sum
} -precondition {
  {# deposit_positive: }
  {$sum > 0}
} -postcondition {
  {# balance_increased: }
  {${:balance} > 0}
}
```

### Inheritance Example

```tcl
nx::Class create SavingsAccount -superclass Account -invariant {
  {# minimum_deposit: }
  {${:minimumBalance} > 100}
}
```

## References

- ECMA Standard 367, 2nd edition (2006): https://www.ecma-international.org/publications/files/ECMA-ST/ECMA-367.pdf 