# Defining Validations

We will use a reset password feature as an example to demonstrate how to use this package.

Consider the following input.

```
{
    "email": "user@example.com",
    "oldPassword": "insecure",
    "newPassword": "insecure2"
    "confirmation": "insecure2"
}
```

There are several things we'd like to validate:
1. all fields are present and of the correct type
2. the new password is strong enough
3. the new password equals the value of the confirmation field
4. the old password matches that of the user with the given email address

Normally we'd represent this payload as follows:

```swift
struct ResetPasswordRequest: Decodable {
    let email: String
    let oldPassword: String
    let newPassword: String
    let confirmation: String
}
```

But in order to use Validations we need to wrap the fields with `Decoded`:

```swift
struct ResetPasswordRequest: Decodable {
    let email: Decoded<String>
    let oldPassword: Decoded<String>
    let newPassword: Decoded<String>
    let confirmation: Decoded<String>
}
```
