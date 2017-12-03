##Predstavljanje stanja problema
Stanje na tabli predstavljeno je kroz dve liste, na razlicite nacine. Prva lista *states* je oblika *((x-koordinate) (y-koordinate))* gde prva od podlisti predstavlja sve koordinate polja na kojima se nalaze x-figure, a druga, suprotno tome predstavlja sve koordinate na kojima se nalaze o-figure. Lista *vertical-states* sadrzi koordinate iz ugla vertikalnog predstavljanja, svaka koordinata je data u formatu okrenutom u odnosu na prvu listu, a same koordinate su grupisane u dve podslite po istoj analogjji. Pored neophodnih listi se cuva i informacija o dimenzionalnosti samog polja.

Korisnik nakon startovanja igre i biranja moda (koji određuje prvenstvo igre na početku između čoveka i mašine) unosi veličinu tabele za igru, na osnovu čega se formiraju liste odgovarajucih dimenzija. Naime, nakon unosa dimenzija liste se inicijalizuju funkcijama *initial-states* i *initial-states-vertical*.

S obzirom da vid predstavljanja koji smo izabrali nije dovoljan za prikaz i evaluaciju uvedene su pomocne funkcije *encode-row* koja vrsi kodiranje jednog reda polja, *states-to-matrix* koja obezbedjuje formiranje kodirane matrice za celokupno polje i *print-matrix* koja obezbedjuje prikaz polja, a za argumenat ima kodiranu matricu. Razlikujemo tri moguće situacije za bilo koje polje - “X” – označava polje na kome je smeštena figura igrača koji otvara igru, “O” – polje na kome je smeštena figura njegovog protivnika, i “-” koja predstavlja prazno polje.

**Primer kodiranja:**

(rownum: 0) - - x - - o o - - - - x

(coded: 0) 2 (3 x) 2 (6 o) (7 o) 4 (12 x)

Samo kodiranje pruza uvid u strukturu svakog reda polja, atomicni elementi su brojnih vrednosti i govore o broju slobodnih pozicija, sa druge strane neatomicni elementi predstavljaju pojavu x/o elemenata i sadrze informaciju o rednom broju u redu. Ovakav vid predstavljanja je pogodan za samo prikazivanje celog polja i pruza dodatne informacije koje su korisne prilikom razlicitih evaluacija i formiranje heuristike.

Pri svakom potezu koji se zadaje “koordinatama” trenutne pozicije figure koju pomeramo i koordinatama pozicije na koju želimo pomeriti tu figuru. Za navedenu funkcionalnost zadužena je funkcija make-move koja poziva samu sebe i na taj način održava igru u toku sve dok se manualno ne otkuca komanda “exit” kojom se program napušta, ili jedna od evaluacionih funkcija: *check-winner-state-horizontal*, *check-winner-state-vertical* ili *check-winner-state-diagonal* ne naznači da je jedan od igrača ostvario uslove za pobedu (pet vezanih figura, po vertikali, horizontali ili dijagonali).

##Funkcije i operator promene stanja

**(make-move xo)**
Ključna funkcija u programu, kao argument dobija boolean xo koji odredjuje igraca na potezu (true: x false: o) cija je negirana vrednost prosledjena rekurzivno ovoj istoj funkciji nakon uspesno zavrsenog poteza, dok se ne dođe do jednog od gorenavedenih uslova za prekid igre (korisnik prekida igru kucanjem “exit” u terminal, ili je neki od igrača pobedio). Funkcija zahteva od korisnika unos poteza u formi početnih i završnih “koordinata” - ((B 3) (C 3)) na primer. Nakon unosa poteza, poziva se pomoćna funkcija form-move kojom konvertujemo slova u brojeve i vršimo proveru granica i ispravnosti formatiranja. Ukoliko je potez ispravan, funkcija *validate-state* vraca true kao povratnu vrednost jer se potez nalazi u grupi svih mogucih poteza. Potez se primenjuje, dolazi do efekata nad globalnim promeljivama i funkcija make-moe poziva samu sebe zbog kontinualnog i naizmenicnog igranja. Pomocne funkcije *check-winner-state-horizontal*, *check-winner-state-vertical* i *check-winner-state-diagonal* vracaju povratnu vrednost koja potvrdjuje situaciju pobednika, ako ima pobednika igra se prekida i izlazi iz izvorne funkcije.

**validate-state (source destination all-states)**
Funkcija koja vrsi proveru ispravnosti stanja gde su argumetni source (x y) i destionation (new-x new-y) koordinate trenutnog i ciljnog stanja. Argumenat all-states predstavlja sve moguce poteze koji poticu iz trenutnog stanja i generise se funkcijom *generate-states*.


**generate-states (matrix lvl xo)**
**generate-moves-for-row (lvl seclst lst xo row res)**
Funkcija za generisanje poteza u jednom redu, ulazni parametri - lvl (koji red evaluiramo), seclst (predzadnji element), lst (prethodni element), xo (kog igra?a evaluiramo), row - (kodirani red), res (rezultat). Rezultat funkcije je lista sa u formatu (((trenutna figura - koordinate)((moguca nova pozicija 1) (moguca nova pozicija 2)...))(...)). Ovoj funkciji se prosledjuju kodirane matrice horizontalnih i vertikalnih koordinata koje su formirane od globalnih promenljivih. Rezultat ove funkcije predstavlja sve moguce poteze u vertikalnom/horizontalnom smeru i kombinovanje svih mogucih poteza se vrsi u funkciji genrate-states. Sama provera se vrsi posebno po redovima (horizontalna matrica) i kolonama (vertikalna matrica). Kodirane matrice se formiraju posebno od globalnih promenljivih *states* i *states-vertical*.

`(let*(
(horizontal (states-to-matrix 1 dimension states))
(vertical (states-to-matrix 1 dimension states-vertical))
...
(validate-state current move (generate-states horizontal 1 xo)
(validate-state (list (cadr current) (car current)) (list (cadr move) (car move)) (generate-states vertical 1 xo)))`
