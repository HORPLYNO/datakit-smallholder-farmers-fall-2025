# Data Cleaning – Etap przygotowania danych

Dokument opisuje proces przygotowania danych wykorzystywanych w dalszych etapach analizy słów i budowy słowników dla języków:
- Luganda (`lug`),
- Runyankole (`nyn`),
- Kiswahili (`swa`),
- angielskiego (`eng`).

Kroki zostały wykonane głównie w Power Query, a następnie dane są wykorzystywane w notebookach Jupyter (`*_word_frequency.ipynb`).

---

# 1. Pobranie danych źródłowych

Dane wejściowe zostały pobrane z publicznego adresu URL udostępnionego w dokumentacji projektu Producers Direct.

Pobrany plik zapisano lokalnie jako:

**`raw_challenge_2_seasonality.csv`**

Plik zawiera pełny zbiór rekordów pytań rolniczych, wraz z metadanymi użytkowników, informacjami o odpowiedziach, językiem pytania (`question_language`) oraz polem tematycznym (`question_topic`).

---

# 2. Wczytanie danych do Power Query

Plik `raw_challenge_2_seasonality.csv` został zaimportowany do Power Query w celu przeprowadzenia wstępnego czyszczenia i przygotowania danych.

Na tym etapie:
- rozpoznano nazwy i typy kolumn,
- zweryfikowano, że kluczowe pola (m.in. `question_language`, `question_topic`, treść pytania) są dostępne,
- przygotowano dane do dalszej redukcji kolumn i deduplikacji.

---

# 3. Usunięcie zbędnych kolumn

W pierwszym kroku czyszczenia usunięto kolumny, które nie były potrzebne w dalszej analizie tekstowej lub zawierały szczegółowe metadane użytkowników i odpowiedzi.

Użyta operacja w Power Query:

= Table.RemoveColumns(#"Changed Type",
{
    "question_user_gender", "response_user_gender", "response_id",
    "response_user_id", "response_language", "response_content",
    "response_topic", "response_user_type", "response_user_status",
    "response_user_country_code", "response_user_dob",
    "response_user_created_at", "question_user_dob",
    "question_user_type", "question_user_status",
    "question_user_created_at", "response_sent",
    "question_user_id"
})

Cel tego kroku:
- redukcja rozmiaru tabeli,
- usunięcie pól, które nie są wykorzystywane w dalszej analizie lingwistycznej,
- ograniczenie zakresu danych do informacji rzeczywiście potrzebnych w kolejnym etapie (analiza treści pytań, język, tematyka).

---

# 4. Usunięcie duplikatów

Po usunięciu zbędnych kolumn wykonano deduplikację na poziomie całej tabeli:

= Table.Distinct(#"Removed Columns")

W efekcie:
- wyeliminowano zduplikowane rekordy pytań,
- zapewniono, że analiza częstości słów oraz późniejsze statystyki nie będą zniekształcone wielokrotnym liczeniem tych samych obserwacji.

---

# 5. Utworzenie kolumny `topic_category` (robocza kategoryzacja tematyczna)

Aby ułatwić ewentualny podział tematyczny w późniejszych wizualizacjach (np. na dashboardzie) oraz eksplorację danych, utworzono nową kolumnę **`topic_category`**.

**Ważne założenie:**  
Zestaw kategorii **nie pochodzi** z danych źródłowych ani oficjalnej taksonomii Producers Direct.  
Kategorie zostały **samodzielnie zdefiniowane na potrzeby tej analizy** jako roboczy, uproszczony podział tematyczny pytań rolniczych.

Logika tworzenia kolumny `topic_category` obejmowała normalizację `question_topic` oraz dopasowanie do przygotowanych list roboczych kategorii takich jak: cereals, legumes, vegetables, fruits, roots_tubers, livestock, cash_crops, fodder_forage, trees.  
Pytania, które nie pasowały do żadnej kategorii, otrzymywały etykietę `"other/unknown"`.

Poniżej znajduje się kod (język M / Power Query) użyty do stworzenia tej kolumny:

```m
let
    topic =
        if [question_topic] = null then
            null
        else
            Text.Lower(Text.Trim([question_topic])),

    cereals = {
        "maize", "wheat", "barley", "rice",
        "millet", "finger-millet", "oat", "rye", "cereal"
    },

    legumes = {
        "bean", "pea", "cowpea", "pigeon-pea", "pigeon",
        "chickpea", "mung-bean", "soya", "lupin",
        "snap-pea", "snow-pea", "french-bean", "peanut"
    },

    vegetables = {
        "amaranth", "asparagus", "aubergine", "beetroot",
        "broccoli", "butternut-squash", "cabbage", "carrot",
        "cauliflower", "celery", "chard", "chilli",
        "collard-greens", "courgette", "cucumber",
        "garlic", "ginger", "greens", "kale", "leek",
        "lettuce", "okra", "onion", "parsley",
        "pumpkin", "radish", "spinach", "squash",
        "tomato", "vegetable",
        "nightshade", "black-nightshade", "african-nightshade",
        "capsicum", "corriander"
    },

    fruits = {
        "apple", "apricot", "avocado", "banana", "blackberry",
        "cranberry", "gooseberry", "grape", "guava",
        "jackfruit", "lemon", "mango", "melon", "mulberry",
        "olive", "orange", "passion-fruit", "paw-paw",
        "peach", "pear", "pineapple", "strawberry",
        "watermelon"
    },

    roots_tubers = {
        "cassava", "sweet-potato", "potato", "taro", "yam"
    },

    livestock = {
        "animal", "cattle", "goat", "sheep", "pig",
        "poultry", "chicken", "duck", "turkey",
        "rabbit", "fish", "tilapia", "ostrich",
        "guinea-fowl", "guinea-pig", "bee", "camel",
        "livestock"
    },

    cash_crops = {
        "coffee", "tea", "cocoa", "cotton", "tobacco",
        "cashew-nut", "macademia", "castor-bean",
        "flax", "pyrethrum", "miraa", "sisal",
        "rapeseed", "sesame", "sunflower", "safflower",
        "sugar-cane", "chia"
    },

    fodder_forage = {
        "boma-rhodes", "brachiaria-grass", "grass",
        "napier-grass", "sudan-grass", "setaria",
        "lucern", "desmodium", "clover",
        "leucaena", "caliandra", "purple-vetch", "vetch"
    },

    trees = {
        "acacia", "bamboo", "eucalyptus", "tree", "cyprus"
    }

in
    if topic = null or topic = "" then
        "other/unknown"
    else if List.Contains(cereals, topic) then
        "cereals"
    else if List.Contains(legumes, topic) then
        "legumes"
    else if List.Contains(vegetables, topic) then
        "vegetables"
    else if List.Contains(fruits, topic) then
        "fruits"
    else if List.Contains(roots_tubers, topic) then
        "roots_tubers"
    else if List.Contains(livestock, topic) then
        "livestock"
    else if List.Contains(cash_crops, topic) then
        "cash_crops"
    else if List.Contains(fodder_forage, topic) then
        "fodder_forage"
    else if List.Contains(trees, topic) then
        "trees"
    else
        "other/unknown"
```

---

# 6. Utworzenie tabel językowych (Reference w Power Query)

Po wykonaniu czyszczenia (usunięcie kolumn, deduplikacja, dodanie `topic_category`) dane zostały rozdzielone na osobne tabele dla każdego języka z użyciem funkcji **Reference**, dzięki czemu wszystkie tabele dziedziczą tę samą logikę czyszczenia.

Utworzono:
- `raw_seasonality_lug` – `question_language = "lug"`
- `raw_seasonality_nyn` – `question_language = "nyn"`
- `raw_seasonality_swa` – `question_language = "swa"`
- `raw_seasonality_eng` – `question_language = "eng"`

---

# 7. Cel rozdzielenia danych na języki

Rozdzielenie danych na cztery osobne tabele jest kluczowe dla późniejszej analizy:
- umożliwia prowadzenie osobnych pipeline’ów czyszczenia i analizy słów,
- upraszcza zarządzanie listami stop-words specyficznymi dla języków,
- pozwala łatwiej porównywać struktury słownictwa między językami.

Każda tabela dziedziczy:
- identyczne kroki czyszczenia,
- tę samą logikę tworzenia `topic_category`,
- strukturę zgodną z danym językiem.

---

# 8. Analiza słów w notebookach Jupyter i czyszczenie z udziałem GPT

Przygotowane w Power Query tabele językowe (`raw_seasonality_eng`, `raw_seasonality_lug`, `raw_seasonality_nyn`, `raw_seasonality_swa`) są eksportowane do plików CSV i wykorzystywane jako wejście w notebookach:

- `ang_word_frequency.ipynb`  
- `lug_word_frequency.ipynb`  
- `nyn_word_frequency.ipynb`  
- `swa_word_frequency.ipynb`  

Celem tego etapu jest:
- zbudowanie uporządkowanych list słów występujących w pytaniach,  
- odfiltrowanie słów mało informacyjnych (stop-words, ogólne słownictwo, słowa niezwiązane z kategoriami tematycznymi),  
- przygotowanie list słów kandydujących do słownika klasyfikacyjnego, z wykorzystaniem modelu GPT (ChatGPT) do półautomatycznej selekcji.

Proces jest identyczny dla wszystkich czterech języków, różnią się jedynie nazwy plików wejściowych/wyjściowych.

---

## 8.1. Etap 1 – wygenerowanie wstępnej listy częstości (Top 3000 słów)

### Wejście (na przykładzie ENG):
- plik: `questions_eng.csv`  

### Kroki w notebooku:

1. **Wczytanie danych**  
   Ładowanie pliku CSV do pandas DataFrame.

2. **Czyszczenie tekstu**  
   - lowercase  
   - usuwanie znaków nieliterowych (regEx)  
   - redukcja spacji  
   - ignorowanie pustych wartości  

3. **Tokenizacja**  
   Każde pytanie dzielone jest na unikalne tokeny (słowa), aby uniknąć wielokrotnego zliczania słowa w obrębie jednego pytania.

4. **Zliczanie częstości**  
   Dla każdego słowa liczona jest liczba pytań, w których wystąpiło.

5. **Ranking i zapis Top 3000**  
   Wynik zapisywany jest do:
   - `eng_top_words.csv`
   - analogicznie: `lug_top_words.csv`, `nyn_top_words.csv`, `swa_top_words.csv`

---

## 8.2. Półautomatyczne czyszczenie listy z użyciem modelu GPT

Pliki `*_top_words.csv` są analizowane przy udziale ChatGPT w celu:
- identyfikacji słów *niezwiązanych* z kategoriami tematycznymi,
- odfiltrowania słów mało informacyjnych,
- stworzenia listy niestandardowych stop-words.

### Procedura

1. **Eksport listy Top 3000 do GPT**  
   Dla każdego języka lista ok. 3000 najczęstszych słów (`*_top_words.csv`) jest eksportowana i przekazywana do ChatGPT.

2. **Przekazanie kategorii tematycznych**  
   Razem z listą słów GPT otrzymuje opis roboczych kategorii, do których docelowo mają być przypisywane pytania.  
   Kategorie odpowiadają logice użytej później w kodzie Power Query i obejmują m.in.:

   - **`market_price`** – pytania o ceny, sprzedaż, kupno, jednostki, rynek (prices / markets / selling),  
   - **`planting_growing`** – sadzenie, sianie, uprawa, nasiona, gleba, rozwój upraw, nawozy,  
   - **`livestock`** – hodowla zwierząt (krowy, kury, kozy, świnie itp.), żywienie, utrzymanie,  
   - **`pests_disease`** – szkodniki, choroby roślin i zwierząt, środki ochrony, opryski, leczenie,  
   - **`timing_harvest`** – czas, dojrzewanie, zbiory, plon, okresy rozrodu itp.,  
   - **`weather`** – pogoda, deszcz, susza, słońce, pory roku i sezonowość,  
   - kategoria domyślna **`other/unknown`** – dla słów, których nie da się wiarygodnie przypisać do żadnej z powyższych.

   Zadaniem GPT jest **wskazanie słów, których NIE jest w stanie jednoznacznie przypisać do żadnej z tych kategorii** – to właśnie te słowa trafiają na listę „non-category”.

3. **Zapis listy słów „non-category”**  
   Słowa zakwalifikowane przez GPT jako:
   - zbyt ogólne,
   - nieinformatywne,
   - niezwiązane z powyższymi kategoriami tematycznymi

   są zapisywane w plikach:

   - `eng_non_category_words.csv`
   - `lug_non_category_words.csv`
   - `nyn_non_category_words.csv`
   - `swa_non_category_words.csv`

Lista `*_non_category_words.csv` pełni rolę rozszerzonej, kontekstowej listy stop-words dla danego języka. W kolejnym etapie (8.3) jest ona używana do odfiltrowania tych słów przed wyznaczeniem kolejnych ~5000 najbardziej informacyjnych terminów.

---

## 8.3. Etap 2 – zastosowanie listy stop-words i wyznaczenie kolejnych ~5000 słów

### Wejście:
- pełna tabela dla języka (`questions_eng.csv`),
- oraz lista stop-words (`eng_non_category_words.csv`).

### Kroki:

1. **Ponowne wczytanie danych**
2. **Ponowne czyszczenie tekstu** – ta sama funkcja co wcześniej  
3. **Wczytanie listy stop-words**  
4. **Filtrowanie tokenów** – usuwanie słów z listy  
5. **Ponowne obliczenie częstości**  
6. **Zapis kolejnych ~5000 słów po filtrowaniu** jako:
   - `eng_next5000_words.csv`
   - `lug_next5000_words.csv`
   - `nyn_next5000_words.csv`
   - `swa_next5000_words.csv`

Lista ta zawiera słowa o wyższej wartości informacyjnej.

---

## 8.4. Rola wygenerowanych list w dalszych etapach i klasyfikacja pytań przy udziale GPT

W rezultacie dla każdego języka powstaje zestaw trzech kluczowych plików pośrednich:

- `*_top_words.csv` — najczęstsze słowa przed filtrowaniem (Top ~3000),  
- `*_non_category_words.csv` — słowa wskazane przez GPT jako mało informacyjne lub niezwiązane z tematyką rolniczą,  
- `*_next5000_words.csv` — kolejne słowa (~5000) po odfiltrowaniu stop-words.

Zestawy te stanowią wejście do kolejnego etapu, którego celem jest **klasyfikacja słów i całych pytań do roboczych kategorii tematycznych**, prowadzona z wykorzystaniem modelu GPT.  
Dzięki temu możliwe jest zbudowanie słowników dla dalszych analiz oraz automatyczne przypisywanie kategorii tematycznych w Power Query.

### Klasyfikacja słów z użyciem GPT

1. Do GPT przekazano pełną listę słów `*_next5000_words.csv` wraz z opisem roboczych kategorii odpowiadających typowym typom pytań rolniczych, m.in.:

   - **`market_price`** — ceny, sprzedaż, kupno, jednostki, rynek,  
   - **`planting_growing`** — sadzenie, sianie, uprawa, nasiona, gleba, nawozy,  
   - **`livestock`** — hodowla zwierząt, żywienie, utrzymanie,  
   - **`pests_disease`** — szkodniki, choroby, środki ochrony, opryski, leczenie,  
   - **`timing_harvest`** — czas, dojrzewanie, zbiory, plon, okresy rozrodu,  
   - **`weather`** — pogoda, deszcz, susza, słońce, sezonowość,  
   - kategoria domyślna **`other` / `other/unknown`** — dla słów bez jednoznacznego dopasowania.

2. Na podstawie pliku `*_next5000_words.csv` oraz opisu kategorii tematycznych GPT wygenerował gotowy fragment kodu M z listami słów-kluczy dla każdej kategorii (m.in. `LUG_Q_MARKET_PRICE`, `LUG_Q_PLANTING_GROWING`, `LUG_Q_LIVESTOCK`, `LUG_Q_PESTS_DISEASE`, `LUG_Q_TIMING_HARVEST`, `LUG_Q_WEATHER`). Poniżej pokazano przykład takiego kodu dla języka Angielskiego, który następnie wykorzystano bezpośrednio do zbudowania kolumny klasyfikującej pytania w Power Query.

```m
// =============== 1) Prices / markets / selling ===============
    ENG_Q_MARKET_PRICE = {
        "price", "prices",
        "market", "markets",
        "sell", "selling",
        "buy", "buying",
        "cost", "costs",
        "profit", "profits",
        "income",
        "kilo", "kilogram", "kilograms",
        "bag", "bags", "sack", "sacks"
    },

    // =============== 2) Planting / growing crops ===============
    ENG_Q_PLANTING_GROWING = {
        // farming / cultivation
        "plant", "plants", "planting",
        "sow", "sowing",
        "germinate", "germination",
        "grow", "growing", "growth",
        "farm", "farms", "farming",
        "farmer", "farmers",
        "land", "soil",
        "field", "fields",
        "acre", "acres",
        "weed", "weeds", "weeding",
        "spacing",
        "mulching",
        "pruning",
        // fertilizer / inputs
        "fertilizer", "fertiliser",
        "manure", "compost", "dung",
        "urea", "dap", "can", "npk",
        "input", "inputs",
        // crop names as context of growing
        "maize", "corn",
        "beans", "bean",
        "banana", "bananas",
        "plantain",
        "cassava",
        "coffee", "tea",
        "sorghum", "millet",
        "rice", "paddy",
        "potato", "potatoes",
        "tomato", "tomatoes",
        "cabbage", "cabbages",
        "onion", "onions",
        "groundnut", "groundnuts",
        "sunflower", "sunflowers",
        "simsim", "sesame",
        "sugarcane",
        "yam", "yams",
        "vegetable", "vegetables",
        "soybean", "soybeans",
        "fruit", "fruits",
        "avocado", "avocados",
        "orange", "oranges",
        "mango", "mangoes",
        "pawpaw", "papaya"
    },

    // =============== 3) Livestock ===============
    ENG_Q_LIVESTOCK = {
        "cow", "cows",
        "goat", "goats",
        "sheep",
        "pig", "pigs",
        "cattle",
        "chicken", "chickens",
        "hen", "hens",
        "broiler", "broilers",
        "layers",
        "chick", "chicks",
        "turkey", "turkeys",
        "duck", "ducks",
        "rabbit", "rabbits",
        "fish", "tilapia", "catfish",
        "poultry",
        "heifer", "heifers",
        "bull", "bulls",
        "calf", "calves"
    },

    // =============== 4) Pests / diseases / treatments ===============
    ENG_Q_PESTS_DISEASE = {
        // pests
        "pest", "pests",
        "aphid", "aphids",
        "borer", "borers",
        "weevil", "weevils",
        "mite", "mites",
        "tick", "ticks",
        "worm", "worms",
        "lice", "louse",
        // diseases / problems
        "disease", "diseases",
        "fungus", "fungi",
        "rot", "rots", "rotten",
        "wilt", "wiltering",
        "blight",
        "virus",
        "bacteria",
        "nematode",
        "coccidiosis",
        "newcastle",
        "mastitis",
        "diarrhoea", "diarrhea",
        // treatments / chemicals
        "spray", "spraying",
        "herbicide",
        "pesticide",
        "insecticide",
        "drug", "drugs",
        "vaccine", "vaccination",
        "treat", "treatment",
        "control"
    },

    // =============== 5) Time / maturity / harvest ===============
    ENG_Q_TIMING_HARVEST = {
        // time / duration
        "day", "days",
        "week", "weeks",
        "month", "months",
        "year", "years",
        "season", "seasons",
        "time", "period",
        // maturity / harvest
        "harvest", "harvesting",
        "yield", "yields",
        "mature", "maturity",
        "ripe", "ripen"
    },

    // =============== 6) Weather / season / climate ===============
    ENG_Q_WEATHER = {
        "rain", "rains", "rainfall",
        "drought",
        "sun", "sunshine",
        "hot", "heat",
        "cold",
        "frost",
        "dry", "wet",
        "climate",
        "flood", "floods", "flooding"
    },

```

3. Zwrócone przez GPT listy słów-kluczy zostały następnie wykorzystane do zbudowania kolumny klasyfikującej **całe pytanie** (`question_content`) w Power Query. Dla każdego języka przygotowano zestaw list typu `ENG_Q_MARKET_PRICE`, `ENG_Q_PLANTING_GROWING`, `ENG_Q_LIVESTOCK`, `ENG_Q_PESTS_DISEASE`, `ENG_Q_TIMING_HARVEST`, `ENG_Q_WEATHER` (analogicznie dla innych języków), a następnie użyto funkcji pomocniczej `ContainsAny`, aby sprawdzić, czy tekst pytania zawiera jakiekolwiek słowo z danej listy. Na tej podstawie tworzona jest kategoria pytania (`"pests_disease"`, `"market_price"`, `"planting_growing"`, `"livestock"`, `"timing_harvest"`, `"weather"`, `"other"`).

Poniżej pokazano przykładową implementację tej logiki dla **języka angielskiego**:

```m
let
    t = 
        if [question_content] = null 
        then null 
        else Text.Lower(Text.Trim([question_content])),

    // Helper: check if text contains any keyword from a list
    ContainsAny = (txt as nullable text, keywords as list) as logical =>
        if txt = null then false 
        else 
            List.AnyTrue(
                List.Transform(
                    keywords, 
                    (k) => Text.Contains(txt, k, Comparer.OrdinalIgnoreCase)
                )
            ),

     // ================= KEYWORD LISTS (generated with GPT) =================
    // The full keyword lists used for classification are defined in the query:
    //   - ENG_Q_MARKET_PRICE
    //   - ENG_Q_PLANTING_GROWING
    //   - ENG_Q_LIVESTOCK
    //   - ENG_Q_PESTS_DISEASE
    //   - ENG_Q_TIMING_HARVEST
    //   - ENG_Q_WEATHER

    // =============== FINAL CATEGORY ASSIGNMENT ===============
    result =
        if t = null or t = "" then "other" else
        // priority: 1) pests/disease, 2) market, 3) planting/growing, 4) livestock, 5) timing/harvest, 6) weather
        if ContainsAny(t, ENG_Q_PESTS_DISEASE)      then "pests_disease"    else
        if ContainsAny(t, ENG_Q_MARKET_PRICE)       then "market_price"     else
        if ContainsAny(t, ENG_Q_PLANTING_GROWING)   then "planting_growing" else
        if ContainsAny(t, ENG_Q_LIVESTOCK)          then "livestock"        else
        if ContainsAny(t, ENG_Q_TIMING_HARVEST)     then "timing_harvest"   else
        if ContainsAny(t, ENG_Q_WEATHER)            then "weather"          else
        "other"
in
    result
```

## 9. Scalanie tabel językowych w finalną strukturę (`proc_challenge_2_seasonality`)

Po zakończeniu czyszczenia danych, klasyfikacji tematycznej oraz utworzeniu kolumny `topic_category` w poszczególnych tabelach językowych  
(`raw_seasonality_lug`, `raw_seasonality_nyn`, `raw_seasonality_swa`, `raw_seasonality_eng`), dane zostały scalone ponownie w jeden spójny zbiór.

Scalanie przeprowadzono w Power Query przy użyciu operacji **Append Queries**, łącząc wszystkie cztery tabele w jedną strukturę:

### **`proc_challenge_2_seasonality`**

Tabele zostały połączone pionowo (row-wise), ponieważ posiadały jednolity układ kolumn:

- `question_id`  
- `question_language`  
- `question_content`  
- `question_topic`  
- `question_sent`  
- `question_user_country_code`  
- `topic_category` – kategoria przypisana na podstawie słownika słów wygenerowanego przez GPT  
- `topic_type` – informacja o źródle lub typie kategorii (np. GPT / manual)

Finalna tabela **`proc_challenge_2_seasonality`** stanowi kompletny i ujednolicony zbiór danych, wykorzystywany w kolejnych etapach analizy, modelowania oraz przygotowania dashboardów.

---

Finalny plik CSV **`proc_challenge_2_seasonality.csv`** będzie następnie wykorzystany do przygotowania pomocniczej tabeli przestawnej (pivot), wykorzystywanej wyłącznie jako źródło danych dla dashboardu w Tableau.  
Szczegółowy opis sposobu zbudowania tabeli, wraz z prostym wyjaśnieniem kroków, zostanie przedstawiony w osobnym pliku: **`seasonality_pivot_explained.md`**.