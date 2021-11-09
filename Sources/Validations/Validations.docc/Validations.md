# ``Validations``

Type-safe and composable validations with flexible error output.       

## Overview

Validating that data follows certain rules is relevant in situations where end-users or other services submit data to your application.

The aim of this package is to enable you to express such validation rules in a type-safe and flexible manner while making it possible to collect all failures at once and have full flexibility over how any violations of the rules are presented.

This package builds on the `Decoded` package to take advantage of its ability to collect any and all error states during the decoding process as opposed to failing on the first error. This makes it possible to combine _structural_ decoding related errors with _semantic_ failures as defined by validation rules in a single pass.

``Validator``s can be passed around and combined as needed before performing the actual validation. This enables you, among other things, to combine validations that require asynchronicity with those that don't.

Once validated successfully, the resulting ``Validated`` structure yields access to the now validated input almost as if you were interacting with a plain decoded value through the use of `dynamicMemberLookup`.

If the validation was not successful, an error of type ``KeyedFailures`` will be thrown which contains one or more ``ValidationFailure``s per offending `CodingPath`. These can be transformed before presenting them to the sender in order to do things like localization.


## Topics

### Validating input

- <doc:Defining-Validations>

### Using the validated output

- ``Validated``

### Customizing error output 

- ``KeyedFailures``
