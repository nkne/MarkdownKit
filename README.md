## About MarkdownKit

MarkdownKit is a 100% CommonMark compliant Markdown parser for Xojo written in pure Xojo code. I needed a fast and robust parser that not only would reliably generate the correct output but would also run on iOS. After looking around I realised that there was no other solution available for Xojo and so I decided to write one myself. MarkdownKit is a labour love, taking months of hard work and containing over 6000 lines of code.

MarkdownKit takes Markdown as input and generates an _abstract syntax tree_ (AST). From the AST, it is then able to render the input as HTML.

This branch of the repo contains an empty iOS project containing the `MarkdownKit` module.


### The Demo Application

The demo app is a fully functioning Markdown editor with a live preview. It has light and dark themes (user-selectable) and will even highlight syntax within code blocks in the provided Markdown input. I have deliberately kept it light on features as its purpose is really just to demonstrate what can be achieved with MarkdownKit. Within the `demo/Desktop` folder you'll see there are versions for API 1 and API 2.0.


## Quick Start

1. Open the `MarkdownKit (iOS).xojo_project` file in `src/`. Copy the `MarkdownKit` module from the navigator and paste it into your own project.
2. Convert Markdown source to HTML with the `MarkdownKit.ToHTML()` method:

```xojo
Dim html As Text = MarkdownKit.ToHTML("Some **bold** text")
```

## Advanced Use

I imagine that most people will only ever need to use the simple `MarkdownKit.ToHTML()` method. However, if you want access to the abstract syntax tree created by `MarkdownKit` during parsing then you can, like so:

```xojo
Dim ast As New MarkdownKit.Document("Some **bold** text")

// Parsing Markdown is done in two phases. First the block structure is 
// determined and then inlines are parsed.
ast.ParseBlockStructure
ast.ParseInlines
```

Why might you want access to the AST? Well, maybe you want to do something as simple as render every soft linebreak in a document as a hard linebreak. Perhaps you want to output the Markdown source as something other than HTML.

`MarkdownKit` provides a class interface called `IRenderer` which must be implemented by any custom renderer you write. The built-in `MarkdownKit.HTMLRenderer` and `MarkdownKit.ASTRenderer` classes are examples of renderers which implement this interface. Take a look at their well-documented methods to learn how to write your own renderer.

[forums]: https://forum.xojo.com
[cm spec]: https://spec.commonmark.org/0.29/