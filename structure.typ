// Frontmatter

#include "./preface/firstpage.typ"
#include "./preface/dedication.typ"
#include "./preface/summary.typ"
#include "./preface/table-of-contents.typ"

// Mainmatter

#counter(page).update(1)
#show link: set text(fill: blue.darken(60%), weight: "semibold")
#show par: set block(spacing: 1.25em)
#set par(leading: 0.75em)

#include "./chapters/introduction.typ"
#include "./chapters/pydnet.typ"
#include "./chapters/xinet.typ"
#include "./chapters/attention.typ"
#include "./chapters/pyxinet.typ"
#include "./chapters/conclusioni.typ"

// // Glossario
#include "./appendix/glossary.typ"

// Bibliography
#include "./appendix/bibliography/bibliography.typ"

#include "./preface/acknowledgements.typ"
