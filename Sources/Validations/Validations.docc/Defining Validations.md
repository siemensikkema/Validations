# Defining Validations

Define the validation rules that your data should adhere to.

We will use a fictional reset password feature as an example since it enables us to explore various interesting aspects of validation.

Consider the following input:

```swift
let payload: Data = """
{
    "email": "user@example.com",
    "password": "insecure",
    "newPassword": "insecure2"
    "confirmation": "insecure2"
}
""".data(using: .utf8)!
```

There are several preconditions that the payload needs to meet before we can accept the input and change the user's password, including:
1. all fields are present and of the correct type
2. `newPassword` contains a strong enough password
3. `confirmation` equals the value of the `newPassword`
4. `password` matches the current password of the user with the given email address

More generally these correspond to validating ...
1. the structure
2. a single field
3. a relationship between fields
4. against an external state

> Warning: This example is chosen to highlight `Validations`' features and not intended to be a best practice for building a password reset implementation.

## Representing the payload

Traditionally we'd represent a payload like the above as follows:

```swift
struct ResetPasswordRequest: Decodable { // ❌
    let email: String
    let password: String
    let newPassword: String
    let confirmation: String
}
```

Defining the payload like this would cause decoding to fail on the first mismatch between the input and the type. 

> One could define the fields as `Optional` which would prevent decoding to fail on missing or `null` values but that would not convey the intended structure. Moreover, it would still fail if a field would be present but of the wrong type, say an `Int` instead of a `String`.

By wrapping the fields with `Decoded` we can capture any and all mismatches while still expressing the proper structure.

```swift
struct ResetPasswordRequest: Decodable {
    let email: Decoded<String>
    let password: Decoded<String>
    let newPassword: Decoded<String>
    let confirmation: Decoded<String>
}
```

Now we're ready to decode the input.

```swift
let decoder = JSONDecoder()
let request = try decoder.decode(Decoded<ResetPasswordRequest>.self, 
                                 from: payload)
```

> Important: Note again the presence of the `Decoded` wrapper – this time involving our custom type. This allows us to capture top-level decoding errors (eg. trying to decode a `String` instead of the expected object) but more importantly it provides access to the validation APIs.

> Despite wrapping our fields in `Decoded` the decoding operation can still throw. Errors that can still occur include those due to malformed input (eg. `JSON` with syntax errors) and the possible presence of any non-`Decoded` fields.

## Validating the payload

Let's go through the preconditions listed above and see how to express them in `Validations`.

### 1. Validating the structure

If we just want to validate that the _structure_ of our input is correct, validation involves a single operation: 

```swift
let validated = try request.validated() // Validated<ResetPasswordRequest>
```

> See ``Validated`` on how to use the values in the (now validated) payload and ``KeyedFailures`` on how to handle any resulting validation failures.

### 2. Validating a single field

Additional validations can be expressed using a special syntax powered by result builders.     

```swift
let validated = try request.validated {
    \.newPassword.count >= 8
}
```

The new validation will fail if `newPassword` is present and of the correct type but its `count` is less than eight characters.

> See ``Validator`` for available validations.

### 3. Validating a relationship between fields

Besides validations involving fields and values it is also possible to validate a relationship _between_ fields.

```swift
\.confirmation == \.newPassword
```

### 4. Validating against external state

Suppose we have a credential verification function that can verify that a password is valid for a user with an email address.  

```swift
func verifyCredentials(email: String?,
                       password: String?) async -> ValidationFailure? {
    // verify credentials
    ...
}
```

If both email and password have non-nil values, the function performs a database lookup for the user and verifies the password against the stored hashed password. If the password does not match or if no user with the email address could not be found, some ``ValidationFailure`` is returned.

As the function is marked as `async` it cannot be used directly inside the validation builder. We can deal with this by verifying the password first and using the result when building the validator.

```swift
let credentialFailure = await verifyCredentials(email: payload.email.value, 
                                                password: payload.password.value)

let validated = try payload.validated {
    \.newPassword.count > 8
    \.confirmation == \.newPassword

    if let failure = credentialFailure {
        Validator(nestedAt: \.email, failure: failure)
    }
}
```
> We're associating the failure with the _email_ field. The failure could indicate either an incorrect email address or an incorrect password and we don't want to give any hints to potential bad actors. 

An alternative way to approach this would be to split the validation into two validators and combining them at the validation step.

```swift
let payloadValidator = Validator<ResetPasswordPayload> {
    \.newPassword.count > 8
    \.confirmation == \.newPassword
}

let credentialFailure = await verifyCredentials(email: payload.email.value, 
                                                password: payload.password.value)

let credentialValidator = Validator<ResetPasswordPayload> {
    if let failure = credentialFailure {
        Validator(nestedAt: \.email, failure: failure)
    }
}

let validated = try payload.validated(by: payloadValidator, credentialValidator)
```
