# Changelog

## 1.0.0

- Ruby 3.0

## 0.4.0

- Each `Bunq.client` call now `.dup`s the `Bunq::Configuration`. This means the `Bunq::Client#configuration` is no longer shared as a global.
- Add `Bunq::Client#with_local_config` method. Can be useful in a multi-threaded environment.
