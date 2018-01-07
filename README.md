## Predstavljanje stanja problema
Stanje na tabli predstavljeno je kroz dve liste, od kojih svaka predstavlja isto stanje na drugačiji način. Prva lista *states* je oblika *((x-koordinate) (y-koordinate))* gde prva od podlisti predstavlja sve koordinate polja na kojima se nalaze x-figure, a druga, suprotno tome predstavlja sve koordinate na kojima se nalaze o-figure. Lista *vertical-states* sadrži koordinate iz ugla vertikalnog predstavljanja, svaka koordinata je data u formatu okrenutom (mirrored) u odnosu na prvu listu, a same koordinate su grupisane u dve podslite po istoj analogjji. Pored neophodnih listi se čuva i informacija o dimenzionalnosti samog polja, odnosno table.

Korisnik nakon startovanja igre i biranja moda (koji određuje prvenstvo igre na početku između čoveka i mašine) unosi veličinu tabele za igru, na osnovu čega se formiraju liste odgovarajućih dimenzija. Naime, nakon unosa dimenzija liste se inicijalizuju funkcijama *initial-states* i *initial-states-vertical*.

S obzirom da vid predstavljanja koji smo izabrali nije dovoljan za prikaz i evaluaciju uvedene su pomoćne funkcije *encode-row*, koja vrši kodiranje jednog reda polja, *states-to-matrix* koja obezbedjuje formiranje kodirane matrice za celokupno polje i *print-matrix* koja obezbedjuje prikaz polja, a za argumenat ima kodiranu matricu. Pridodata funkcija *show-output* omogućava markiranje vrsta i kolona odgovarajućim slovima i brojevima. Razlikujemo tri moguće situacije za bilo koje polje - “x” – označava polje na kome je smeštena figura igrača koji otvara igru, “o” – polje na kome je smeštena figura njegovog protivnika, i “-” koja predstavlja prazno polje.

**Primer kodiranja:**

`(rownum: 0) - - x - - o o - - - - x`

`(coded: 0) 2 (3 x) 2 (6 o) (7 o) 4 (12 x)`

Samo kodiranje pruža uvid u strukturu svakog reda polja, atomični elementi su brojnih vrednosti i govore o broju slobodnih pozicija. Sa druge strane, neatomični elementi označavaju prisutnost x/o elemenata i sadrže informaciju o rednom broju u redu. Ovakav vid predstavljanja je pogodan za samo prikazivanje celokupnog polja, odnosno table, i pruža dodatne informacije koje su korisne prilikom različitih evaluacija i formiranja heuristike. Kodiranje se vrši na nivou vrsta ili kolona, a celokupne kodirane matrice se koriste u algoritmima prilikom obrada i procena stanja. Jedna od ključnih funkcija ***states-to-matrix*** upravo ima tu ulogu, da na osnovu prosledjenog stanja generiše kodiranu matricu koja oslikava celu tablu. Ako se ovoj funkciji prosledi kao argumenat skup stanja sa horizontalnim koordinatama (states) dobija se matrica kodiranih vrsta, a u suprotnom ako je prosledjeni argumenat skup stanja sa vertikalnim koordinatama (states-vertical) dobija se matrica kodiranih kolona.

Svaki potez zadaje se “koordinatama” trenutne pozicije figure koju pomeramo i koordinatama pozicije na koju želimo pomeriti tu figuru. Za navedenu funkcionalnost zadužena je funkcija *make-move* koja poziva samu sebe i na taj način održava igru u toku sve dok se manualno ne otkuca komanda “exit” kojom se program napušta, ili jedna od evaluacionih funkcija: *check-winner-state-horizontal*, *check-winner-state-vertical* ili *check-winner-state-diagonal* ne naznači da je jedan od igrača ostvario uslove za pobedu (pet vezanih figura, po vertikali, horizontali ili dijagonali). Dodatna provera je da li je jedan od igrača spao na manje od četri figure. Da bi se potez primenio neophodno je da bude validan, više o tome u opisu funkcija.

## Funkcije i operator promene stanja

**(make-move xo)**
Ključna funkcija u programu, kao argument dobija boolean xo koji odredjuje igrača na potezu (true: x false: o) čija je negirana vrednost prosledjena rekurzivno ovoj istoj funkciji nakon uspešno završenog poteza, dok se ne dođe do jednog od gorenavedenih uslova za prekid igre (korisnik prekida igru kucanjem “exit” u terminalu, ili je neki od igrača pobedio). Funkcija zahteva od korisnika unos poteza u formi početnih i završnih “koordinata” - ((B 3) (C 3)) na primer. Nakon unosa poteza, poziva se pomoćna funkcija *form-move* kojom konvertujemo slova u brojeve i vršimo proveru granica i ispravnosti formatiranja. Ukoliko je potez ispravan, funkcija ***validate-state*** vraća true kao povratnu vrednost jer se potez nalazi u grupi svih mogućih poteza. Potez se primenjuje, dolazi do efekata nad globalnim promeljivama i funkcija *make-move* poziva samu sebe zbog održavanja kontinualnog i naizmeničnog igranja. Pomoćne funkcije *check-winner-state-horizontal*, *check-winner-state-vertical* i *check-winner-state-diagonal* vraćaju povratnu vrednost koja potvrdjuje situaciju pobednika, ako ima pobednika igra se prekida i izlazi iz izvorne funkcije, a samim tim i rekurzije.

**validate-state (source destination all-states)**
Funkcija koja vrši proveru ispravnosti stanja gde su argumetni source (x y) i destionation (new-x new-y) koordinate trenutnog i ciljnog stanja. Argumenat all-states predstavlja sve moguće poteze koji potiču iz trenutnog stanja i generiše se funkcijom *generate-states*.


**generate-states (matrix lvl xo)**
**generate-moves-for-row (lvl seclst lst xo row res)**
Funkcija za generisanje poteza u jednom redu, ulazni parametri su lvl (koji red se evaluaira), seclst (predzadnji elemenat), lst (prethodni elemenat), xo (boolean koji odredjuje igrača na potezu a samim tim i način evaluacije), row - (kodirani red), res (rezultat). Rezultat funkcije je lista u formatu (((trenutna figura - koordinate)((moguca nova pozicija 1) (moguca nova pozicija 2)...))(...)). Ovoj funkciji se prosledjuju kodirane matrice horizontalnih i vertikalnih koordinata koje su formirane od globalnih promenljivih. Rezultat ove funkcije predstavlja sve moguce poteze u vertikalnom/horizontalnom smeru i kombinovanje svih mogućih poteza se vrši u funkciji *generate-states*. Sama provera se vrši posebno po redovima (horizontalna matrica) i kolonama (vertikalna matrica). Kodirane matrice se formiraju posebno od globalnih promenljivih *states* i *states-vertical*.

`(let*(
(horizontal (states-to-matrix 1 dimension states))
(vertical (states-to-matrix 1 dimension states-vertical))
...
(validate-state current move (generate-states horizontal 1 xo)
(validate-state (list (cadr current) (car current)) (list (cadr move) (car move)) (generate-states vertical 1 xo)))`

## Operator promene stanja

**merge-all-states(horizontal-matrix vertical-matrix states-h states-v xo)**
Funkcija koja objedinjuje sva moguća stanja u odnosu na prosledjeno stanje u jednu listu, odnosno **operator stanja**. Argumenti su kodirane matrice vertikalnog i horizontalnog pogleda, kao i kopije trenutnog stanja, odnosno stanja za koje se traže si mogući potezi, kao i boolean koji govori koji je igrač na potezu. Ova funkcija vrši i objedinjuje rezultate dva različita poziva funkcije make-all-states čime su pokrieni svi potezi u vertikalnom i horizontalnom smeru, za svaku figuru ponaosob. Potezi u horizontalnom smeru (levo-desno) se pribavljaju iz horizontalne matrice, a potezi u vertikalnom smeru (gore-dole) se pribavljaju iz vertikalne matrice. Za svaki smer postoji poseban poziv funkije make-all-states.

**make-all-states (states-h states-v all-states xo invert)**
Funkcija koja za argumente ima xo boolean koji odrdjuje igrača na potezu i sve moguće poteze tog igrača u odnosu na trenutno stanje. Svi mogući potezi su formirani istom analogijom kao u prethodno opisanom slučaju. Koriščenjem funkcije *generate-states* koja posebno razmatra kodiranu horizontalnu i vertikalnu matricu, a zatim kombinovanjem svih mogućih poteza sa dva odvojena poziva funkcije *make-all-states* za horizontalno i vertikalno kodiranje uz različitu vrednost invert argumenta. Rekurzivnim prolaskom kroz listu i pozivanje fukncije *make-states* za svaku moguću izvornu poziciju i sve njene validne odredišne pozicije vrši se formiranje liste svih mogućih poteza koja je ujedno i povratna vrednost funkcije *make-all-states*. Parametar invert je boolean koji daje informaciju da li se formiraju stanja koja su dobijena generisanjem iz vertikalne ili horizontalne matrice, u slučaju vertikalne matrice (mirrored) je neophodno okrenuti koordinate pri formiranju svih stanja u povratku iz rekurzije.

## Modularnost | Blackbox struktuiranost
Sve funkcije su nezavisne i mogu da se koriste u sprezi sa drugim funkcijama ne uzimajući u obzir način i logiku implementacije. Nivo apstrakcije ključnih funkcija je na visokom nivou i one se pritom oslanjaju na pomoćne funkcije nižih nivoa implementacije koje zapravo rešavaju probleme i imaju jasno definisane ulazne argumente. Pri planiranju implementacije funkcija nižeg nivoa uzeta je u obzir struktura prenosa podataka sa ciljem maksimizovanja reupotrebljivosti navedenih funkcija u implementaciji što više funkcija višeg niva. Povratne vrednosti ključnih funkcija su jasno definisanih i konkretnih formata što znatno olakšava kasniju upotrebu; na primer u formiranju heuristike.


## Min-max sa Alpha-beta odsecanjem

Naredni potez AI igrača određuje se pozivanja funkcije

`alpha-beta(states alpha beta depth xo)` 

koja za ulazne argumente uzima trenutno stanje igre, početne vrednosti alfa i beta granica, željenu dubinu pretraživanja i stranu na kojoj igra AI, a kao izlaz vraća stanje koje treba zauzeti kada se odigra potez koji je algoritam procenio za najbolji. Pošto se igrač na potezu uzima za maksimizirajućeg igrača, alfa beta poziva min-value pomoćnu funkciju, koja se zatim smenjuje sa pomoćnom funkcijom max-value do tražene dubine.

`max-value (state-par alpha beta depth xo)`

`min-value (state-par alpha beta depth xo)`

Svaka od navedenih funkcija prolazi kroz listu stanja generisanih funkcijom merge-all-states pomoću loop petlje, te se naizmeničnim međusobnim pozivanjem dolazi do zadate dubine, kada se na mesto daljeg napredovanja u dobinu računa heuristička vrednost za prosleđeno stanje. Prilikom povratka kroz rekurziju, aktuelizuju se vrednosti alfa i beta parametara, i vršu odsecanje tamo gde se ostvari uslov izjednačavanja ili prekoračenja vrednosti alfa parametra u odnosu na beta parametar. Za razliku od alpha-beta funkcije koja kao povratnu vrednost vraća stanje u koje treba preći, povratne vrednosti funkcija max-value i min-value su brojne vrednosti dobijene na osnovu heurističke funkcije ukoliko se radi o poslednjem nivou pretraživanja, ili vrednosti proračunate na osnovu potomaka i u skladu sa alfa i beta parametrima za više nivoe.

## Funkcija za procenu heurističke vrednosti stanja

Funkcija za procenu heurističke vrednosti stanja sama po sebi zahteva efikasno a pritom i napredno rešenje kako bi se izbegli i predugo vreme proračuna i nedovoljno ozbiljno razmatranje svih parametara koji utiču na valjanost poteza. Poziv funkcije

`heuristic-value (states-horizontal states-vertical xo)`

za ulazne argumente prihvata horizontale i vertikalne nekodirane liste stanja kao i igrača koji je na potezu, a kao izlaz šalju brojnu vrednost formiranu kombinovanjem različitih faktora. U ove faktore ubrajaju se broj vertikalno, horizontalno i dijagonalno poređanih figura, kao i broj potencijalnih sendvič scenarija. Ključne pomoćne funkcije koje se koriste za realizovanje heuristic-value funkcije su:

`heuristic-state-horizontal (row-matrix rownum xo)`
`heuristic-state-vertical (column-matrix columnum xo)`
`heuristic-value-diagonal (diagonals result)`
`heuristic-state-sandwich (row-matrix rownum xo vertical-bool)`

Prve tri navedene funkcije kao povratne vrednosti prosleđuju liste čiji elementi predstavljaju broj figura neophodnih da bi se obrazovao niz od pet figura. Njihova maltene identična struktura povratnih vrednosti omogućava nam korišćenje ključne podfunkcije za konverziju takvih listi u brojne heurističke vrednosti bez ikakvog prilagođavanja. Navedena funkcija za konverziju, 

`list-to-heuristic (list level multiplier result)`

prolazi kroz prosleđenu listu rekurzivno za svaki od mogućih brojeva elemenata u nizu, i u odnosu na udaljenost od ciljnog broja elemenata množi sa različitim faktorima skaliranjima. Kako se po listi argumenata da videti, na osnovu argumenata prosleđenih ovoj funkciji možemo podesiti stil igre na ofanzivniji ili defanzivniji. Zbir povratnih vrednosti svih prethodno pomenutih funkcija se sabiraju i vraćaju kao rezultat glavne funkcije heuristic-value.
