{ mkGeneric, srcOnly }:

package:

mkGeneric (package // {
  builder = srcOnly;
})
