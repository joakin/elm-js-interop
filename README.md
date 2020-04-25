# Elm-JS interop

**You probably don't need or shouldn't use this. If you do, you need to be
experienced in JS and Elm, and thread carefully to not break purity.**

**This works for 0.19, and it is likely to break or not even work in future
versions of Elm. If you use this you are solely responsible for any future pain
you may incur on by not being able to easily migrate your app to new Elm
versions**.

See `src/Main.elm` for examples of usage of the sync and async FFI. Within the
boundaries of possibility, the library still tries to encapsulate JS code
running to not break the Elm runtime or your app.

If you want to add this to your application, copy `src/Js.elm` to your app, and
include the JS file in `public/elm-js-interop.js`.

Stay safe out there.
