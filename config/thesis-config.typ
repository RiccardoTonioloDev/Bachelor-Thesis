#import "../config/constants.typ": chapter
#let config(
    myAuthor: "Nome cognome",
    myTitle: "Titolo",
    myLang: "it",
    myNumbering: "1",
    body
) = {
  // Set the document's basic properties.
    set document(author: myAuthor, title: myTitle)
    show math.equation: set text(weight: 400)

    // LaTeX look (secondo la doc di Typst)
    set page(margin: 1.1811in, numbering: myNumbering, number-align: center)
    // set par(leading: 0.55em, first-line-indent: 1.8em, justify: true)
    set par(leading: 0.55em, justify: true)
    set text(font: "EB Garamond", size: 12pt, lang: myLang)
    set heading(numbering: myNumbering )
    show raw: set text(font: "JetBrains Mono", size: 9pt, lang: myLang)
    show par: set block(spacing: 0.55em)
    show heading: set block(above: 1.4em, below: 1em)
    show heading: set text(weight: "medium")
    set heading(numbering: (..nums) => nums.pos().map(str).join("."))
    show par: set block(spacing: 1.25em)
    set par(leading: 0.75em)
    set list(indent: 9pt, body-indent: 9pt)
    set enum(indent: 9pt, body-indent: 9pt)
    show ref: set text(fill: blue.darken(70%), weight: "medium")
    show figure.caption: set text(size: 10pt, font: "Optima")


    show heading.where(level: 1): it => {
        stack(
            spacing: 2em,
            if it.numbering != none {
                align(center)[#text(size: 4.5em,fill: rgb(149, 0, 6),weight: "thin")[#counter(heading).display()]]
            },
            align(center)[#text(size:2em,it.body, weight: "thin")],
            []
        )
    }

  body
}
