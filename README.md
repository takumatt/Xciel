Xciel is a Xcode Extension influented by ci (di) command in Vim.
This command can delete, select and comment-out the region which the cursor is.
For example, see the following gif.

# The behavior

As a introduction, the Delete command behave like the following.
(the cursor position is expressed as $)

1. 

```swift
if x.isEasy {
  do(what: $x)
}
```

2. 

```
if x.isEasy {
  do($)
}
```

As you can see, the cursor's scope is inside of the `do(what: @x)` and it deletes `what: x`.
By the way, if the cursor is outside of the `do()`, then

1.

```swift
if !(x.isEasy) {
	waitUntilPossible()
  $do(what: x)
}
```

2. 
```swift
if !(x.isEasy) {
  $
}
```

Now, you can imagine the Delete command's behavior.

NOTE: Comment out command can toggle comments in the region!

# Installation

Download from the release page and open Xciel.

Then, open System Preferences > Extensions and enable Xciel Extension.

If you cannot find Xcode Menu > Editor > Xciel Extension, please reopen Xcode.

# Usage

Select Xcode Menu > Editor > Xciel Extensions.

However, I highly recommend setting keybind to the Xciel commands.