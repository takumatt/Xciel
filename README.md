Xciel is a Xcode Extension influenced by "ci" ("di") command in Vim.  

This command deletes, selects and comment-out the region (scope) where enclosed in brackets. 

Unlike the "ci" command in Vim, the region is defined by the cursor position.  

# Introduction

Xciel commands are slightly similar to "ci" command in Vim, but these commands search the region by current cursor position.  

It automatically searches the parent brackets ("(){}[]") and executes a command.

## Delete

Xciel Delete command behave like the following.  

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

## Select

Select command simply selects the scope.

## Comment

Comment out command toggles lines in the scope.

NOTE: Comment out command can toggle comments in the region!

## Greedy

Each commends has greedy option.

These commands are usefull in specific situation.  

### Select

This command selects the region where exntended to the first column of the start line and the last column of the end line.

### Delete

This command deletes the region as same as the Select command select.

### Comment out 

This command comments the region as same sa the Select command select.

# Installation

Download from the release page and open Xciel.app.

Then, open System Preferences > Extensions and enable Xciel Extension.

If you cannot find Xcode Menu > Editor > Xciel Extension, please reopen Xcode.

# Usage

Select Xcode Menu > Editor > Xciel Extensions.

I highly recommend setting keybind to the Xciel commands though :)
