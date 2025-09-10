# System Extensions

## Requirements

sysext directory should be named `sysext-{core package name}`, where the `{core package name}`
is the package that the sysext tracks for versioning.

## Key Package and Versions

Extensions should have a `mkosi.finalize` that contains a line like this:

```bash
echo "code" > "$OUTPUTDIR/$IMAGE_ID.keypackage"
```

This line sets the "key package" of the extension, the package that's central to the extension
operation. The version of the key package is listed in each tagged release, if available.

If an extension doesn't have a key package, use "NIL".
