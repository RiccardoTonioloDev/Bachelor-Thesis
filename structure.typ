// Frontmatter

#include "./preface/firstpage.typ"
#include "./preface/copyright.typ"
#include "./preface/summary.typ"
#include "./preface/acknowledgements.typ"
#include "./preface/table-of-contents.typ"

// Mainmatter

#counter(page).update(1)
#show link: set text(fill: blue.darken(60%), weight: "semibold")

#include "./chapters/introduction.typ"
#include "./chapters/pydnet.typ"

// // Glossario
#include "./appendix/glossary.typ"

// Bibliography
#include "./appendix/bibliography/bibliography.typ"
