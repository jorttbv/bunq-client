# Changelog

## 2.0.0

- The `user.certificate_pinned` now takes an argument and points to a single pinned certificate
- Move the `create` of a pinned certificate to the collection resource `user.certificates_pinned`
- Added more endpoints

## 1.0.0

- Ruby 3.0

## 0.4.0

- Each `Bunq.client` call now `.dup`s the `Bunq::Configuration`. This means the `Bunq::Client#configuration` is no longer shared as a global.
- Add `Bunq::Client#with_local_config` method. Can be useful in a multi-threaded environment.
