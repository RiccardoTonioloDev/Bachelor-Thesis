// Frontmatter

#include "./preface/firstpage.typ"
#include "./preface/dedication.typ"
#include "./preface/summary.typ"
#include "./preface/table-of-contents.typ"

// Mainmatter

#counter(page).update(1)
#show link: set text(fill: blue.darken(70%), weight: "medium")

#include "./chapters/introduction.typ"
#include "./chapters/pydnet.typ"
#include "./chapters/xinet.typ"
#include "./chapters/attention.typ"
#include "./chapters/pyxinet.typ"
#include "./chapters/results.typ"
#include "./chapters/conclusioni.typ"

// // Glossario
#include "./appendix/glossary.typ"

// Bibliography
#include "./appendix/bibliography/bibliography.typ"

#include "./preface/acknowledgements.typ"
