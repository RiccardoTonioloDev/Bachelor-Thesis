#import "./config/variables.typ": *
#import "./config/thesis-config.typ": *
#import "@preview/glossarium:0.4.1": make-glossary
#show: make-glossary

#show: config.with(
  myAuthor: myName,
  myTitle: myTitle,
  myNumbering: "1.",
  myLang: myLang
)

#include "structure.typ"
