# API examples

Example JSON responses from the native app API (`/api/v1`), written by the
request tests in `test/controllers/api/v1/` every time they run. The app's Swift
tests decode these files, so an API shape change shows up as a diff here and as
a failing decode on the app side.

Timestamps, tokens and Active Storage signed ids are replaced with fixed values,
and record ids are renumbered per file, so a file changes only when a shape does.
Commit any changes the tests make.
