#import "../config/variables.typ" : profTitle, myProf, myLocation, myTime, myName
#import "../config/constants.typ" : acknlowledgements

#set par(first-line-indent: 0pt)
#set page(numbering: none)
#pagebreak(to: "odd")


#let acknowledgements_content() = {
align(right, [
    #text(style: "italic", [Ogni mattina, alzandoti, pensa a quale prezioso privilegio è essere vivo - #linebreak() respirare, pensare, provare gioia, amare.])
    #v(6pt)
    #sym.dash Marco Aurelio
])

v(10em)

text(24pt, weight: "semibold", acknlowledgements)

v(3em)

text(style: "italic", "Innanzitutto, vorrei sentitamente ringraziare il " + profTitle + myProf + ", relatore della mia tesi, per la sua disponibilità e per la bellissima esperienza che mi ha permesso di fare.")

linebreak()

text(style: "italic", "Ti ringrazio di cuore Elena, per essere stata un preziosissimo mentore durante tutta questa esperienza, per il tempo dedicatomi, per i tuoi consigli e per la conoscenza che mi hai dispensato.")

linebreak()

text(style: "italic", "Ringrazio profondamente la mia famiglia, il cui supporto è stato inestimabile, per avermi sostenuto in ogni mia scelta.")

linebreak()

text(style: "italic", "Ti ringrazio Alessandro per essere stato la mia costante da quando abbiamo deciso che saremo stati migliori amici, iscrivendoci a quel corso di teatro in inglese. Tu sei la dimostrazione che si può essere fratelli anche se si viene da due mamme diverse.")

linebreak()

text(style: "italic", "Ringrazio infine i miei amici, che sono stati compagni di avventure e hanno condiviso con me sia i momenti belli che quelli più difficili. Un ringraziamento particolare a: Alberto, Anna, Davide, Dennis, Marcello, Riccardo.")

linebreak()

text(style: "italic","Vi voglio bene, e se la vita è un viaggio, spero continuerete ad essere i miei compagni.")

v(2em)

text(style: "italic", myLocation + ", " + myTime + h(1fr) + myName)

v(1fr)

}

#acknowledgements_content()
