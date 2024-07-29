#import "../config/variables.typ" : profTitle, myProf, myLocation, myTime, myName
#import "../config/constants.typ" : acknlowledgements

#set par(first-line-indent: 0pt)
#set page(numbering: "i")

#let acknlowledgements_content() = {
align(right, [
    #text(style: "italic", [Ogni mattina, alzandoti, pensa a quale prezioso privilegio è essere vivo - #linebreak() respirare, pensare, provare gioia, amare.])
    #v(6pt)
    #sym.dash#sym.dash#sym.dash Marco Aurelio
])

v(10em)

text(24pt, weight: "semibold", acknlowledgements)

v(3em)

text(style: "italic", "Innanzitutto, vorrei sentitamente ringraziare il " + profTitle + myProf + ", relatore della mia tesi, in primo luogo per la bellissima opportunità che mi ha fornito, e per l'aiuto ed il sostegno ricevuto durante la stesura del lavoro.")

linebreak()

text(style: "italic", "Ringrazio di cuore la dottoranda Elena Izzo, mio supervisore durante tutto il tirocinio. Ti sono grato per il tempo che mi hai dedicato, per i tuoi consigli e per la tua guida. Sei stata una figura fondamentale, un mentore prezioso per il mio percorso.")

linebreak()

text(style: "italic", "Ringrazio profondamente la mia famiglia, il cui supporto è stato inestimabile. Un ringraziamento particolare va a mia madre, il cui amore e incoraggiamento sono stati fondamentali in questo viaggio.")

linebreak()

text(style: "italic", "Ringrazio Alessandro, che per me è stato e continua ad essere come un fratello. Mi sento costantemente grato ad averti trovato.")

linebreak()

text(style: "italic", "Ringrazio infine i miei amici, che sono stati compagni di avventure e hanno condiviso con me sia i momenti belli che quelli più difficili. Un ringraziamento particolare a: Alberto, Anna, Davide, Dennis, Marcello, Riccardo.")

v(2em)

text(style: "italic", myLocation + ", " + myTime + h(1fr) + myName)

v(1fr)

}