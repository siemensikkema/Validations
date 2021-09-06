# Validations

A Swift framework designed to make validating Decodable input convenient, type safe, versitile, and efficient.

Most APIs and server-side rendered webpages deal with input from the outside world. Not all input is acceptable; some rules must be followed. And when they aren't we should be able to provide clear feedback on what rules were violated. When there is more than one thing wrong with the input we should report all violations instead of just halting at the first error we encounter.

This framework is inspired from working with `Vapor`s  `Validations`. It is an attempt to address some of its pain points, which include:

- the use of strings to refer to keys in the payload
- needing to use clunky workarounds to build validations that involve comparing values _within_ the input
- as well as for those that require asynchronous operations (eg. looking up an email address in the database to see if it is unique)

> Note: this framework is at a very early stage and much of the API is subject to change

## Goals

By striving to fulfill the goals below, this framework aims to make writing good validations as painless as possible.

- minimally repetitive code
- type safety
- enable complex validations eg. comparing values within a payload
- usable in an asynchronous context.
- a single decoding step
- i18n ready

## Structure

It consists of 2 targets: Decoded and Validations. Together, these provide the full functionality of this framework. But each can be used on its own. 

### `Decoded`: Capture success _and_ error states from decoding

`Decoded` provides a layer on top of Swift's `Codable` that allows for capturing and collecting error states.

### `Validations`: Validate the decoded values and get a view into the data 

`Validations` aims to add a powerful domain specific language (DSL) to express what input we should consider valid.
