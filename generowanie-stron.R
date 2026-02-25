jst <- read.csv2("jst.csv",
                 colClasses = c(id = "character", parent = "character"))
jst$children <- strsplit(jst$children, split = ",", fixed = TRUE)
jst$neighbours <- strsplit(jst$neighbours, split = ",", fixed = TRUE)

wsk <- jsonlite::read_json("wskazniki.json")
filtry <- jsonlite::read_json("zmienne-filtrujace.json")

# Funkcja przygotuj_kod_zakladki() #############################################
przygotuj_kod_zakladki <- function(w, filtry, sciezkaDoZrodla, teryt, nazwaJST,
                                   nazwaJSTMiejscownik, rspoParsJST) {
  filtry <- filtry[!(sapply(filtry, \(f) f$id) %in% w$filtersExclude)]
  filtry <- lapply(filtry,
                   function(f, ids) {
                     if ("disabled" %in% names(f)) {
                       f$disabled <- f$disabled[unlist(f$disabled) %in% ids]
                     }
                     if ("filter" %in% names(f)) {
                       f$filter <- f$filter[unlist(f$filter) %in% ids]
                     }
                     return(f)
                   },
                   ids = sapply(filtry, \(f) f$id))

  naglowekZakladki <- c(paste0("## ", w$name), "")
  opis <- unlist(lapply(w$description, \(x) c(x, "")))
  inicjalizacjaWyborow <- c(
    "```{ojs}",
    "//| echo: false",
    "//| output: false",
    sapply(filtry,
           function(f, w) {
             if ("value" %in% names(f)) {
               if (substr(f$value[1], 1, 1) == "~") {
                 f$value <- paste0(
                   f$value[1], "(", w, ".map( (g) => g.", f$id, " ))")
                 if (substr(f$value[1], 2, 2) == "[") {
                   f$value <- paste0(f$value, "]")
                 }
               }
               if (substr(f$value[1], 1, 1) == "~") {
                 f$value <- substr(f$value, 2, nchar(f$value))
               } else {
                 f$value <- paste0('"', f$value, '"')
               }
             } else {
               f$value = "null"
             }
             paste0("mutable ", w, "_", f$id, "_v = ", f$value)
           },
           w = w$id),
    "```",
    ""
  )
  filtry <- lapply(filtry,
                   function(f, w) {
                     f$value = paste0("~", w, "_", f$id, "_v")
                     return(f)
                   },
                   w = w$id)
  filtrowanie <- c(
    "```{ojs}",
    "//| echo: false",
    "//| panel: input",
    paste0('html`<span class="loading-message ', w$id, '-tab">Trwa ładowanie dokumentu...</span>`'),
    "",
    sapply(filtry,
           function(f, w) {
             dane <- w
             if ("filter" %in% names(f)) {
               dane <- paste0(
                 c(w,
                   sapply(f$filter,
                          function(ff, w) {
                            paste0(".filter( (g) => compare(", w, "_", ff, "_v, g.", ff, ") )")
                          },
                          w = w)),
                 collapse = "
          ")
             }
             dane <- paste0(dane, "
          .map( (g) => g.", f$id, " )")
             if ("values" %in% names(f)) {
               dane <- paste0('["', paste(f$values, collapse = '", "'),
                              '"].concat(
          ', dane, ")")
             }
             if ("disabled" %in% names(f)) {
               f$disabled <- paste0(c(
                 paste0("~set_diff(new Set(", w, ".map( (g) => g.", f$id, " )),"),
                 paste0("                       new Set(", w),
                 sapply(f$disabled,
                        \(ff) paste0(
                          "                               .filter( (g) => compare(",
                          w, "_", ff, "_v, g.", ff, ") )")),
                 paste0("                               .map( (g) => g.",
                        f$id, " )))")
               ), collapse = "
")
             }
             inneParametry <-
               setdiff(names(f), c("id", "type", "filter", "values"))

             return(c(
               paste0("viewof ", w, "_", f$id, " = ", f$type, "("),
               paste0("  new Set(", dane, "),"),
               "  {",
               paste0("    ", inneParametry, ": ",
                      sapply(f[inneParametry],
                             function(x) {
                               if (substr(x[1], 1, 1) == "~") {
                                 x <- substr(x, 2, nchar(x))
                               } else {
                                 x <- paste0('"', x, '"')
                               }
                               return(x)
                             }),
                      c(rep(",", length(inneParametry) - 1), "")),
               "  }",
               ")"
             ))
           },
           w = w$id),
    "```",
    ""
  )
  synchronizacjaWyborow <- c(
    "```{ojs}",
    "//| echo: false",
    "//| output: false",
    "{",
    sapply(filtry,
           function(f, w) {
             paste0("  if (!input_values_equal(", w, "_", f$id, ", ",
                    w, "_", f$id, "_v)) {
    mutable ", w, "_", f$id, "_v = ", w, "_", f$id, "
  }")
           },
           w = w$id),
    "}",
    "```",
    ""
  )
  wczytywanieDanych <- c(
    "```{ojs}",
    "//| echo: false",
    "//| output: false",
    paste0(w$id, ' = await FileAttachment("', sciezkaDoZrodla,
           'data/', teryt, '-', w$id, '.json").json()'),
    "{",
    paste0("  if (", w$id, ".length > 0) {"),
    '    d3.selectAll("div.cell-output-display:has(.loading-message)")',
    paste0('      .filter(":has(.', w$id, '-tab)")'),
    "      .remove()",
    "  }",
    "}",
    "```",
    ""
  )
  przeksztalcanieDanych <- c(
    "```{ojs}",
    "//| echo: false",
    "//| output: false",
    paste0(w$id, "F = ", w$id),
    sapply(filtry,
           function(f) {
             paste0("  .filter( (g) => compare(", w$id, "_", f$id,
                    ", g.", f$id, ") )")
           }),
    paste0(w$id, "C = [].concat("),
    paste0("  ...", w$id, "F"),
    '  .filter( (g) => Object.hasOwn(g.wartosc, "w") )',
    "  .map( (g) => g.wartosc.w.map( (x) => Object.assign({}, { rok_abs: g.rok_abs }, x) ) )",
    ")",
    "```",
    ""
  )
  komunikatyOBrakach <- c(
    "```{ojs}",
    "//| echo: false",
    paste0(w$id, "_censored = ", w$id, "F"),
    '  .filter( (g) => Object.hasOwn(g.wartosc, "cenzura") )',
    "  .map( (g) => ({rok_abs: g.rok_abs, alert: g.wartosc.cenzura}) )",
    paste0(w$id, "_missing = Array.from(set_diff("),
    "  set_diff(",
    paste0("    new Set(", w$id, "_rok_abs),"),
    paste0("    new Set(", w$id, "C.map ( (g) => g.rok_abs ))"),
    "  ),",
    paste0("  new Set(", w$id, "_censored.map( (g) => g.rok_abs ))"),
    ")).map( (g) => ({rok_abs: g, alert: alertNoData}) )",
    "",
    "{",
    paste0("  if (", w$id, "_censored.length > 0 || ", w$id, "_missing.length > 0) {"),
    '    return html`<div class="data-alerts">',
    paste0("                ${", w$id ,"_censored.concat(", w$id ,"_missing)"),
    "                  .sort( (x, y) => x.rok_abs - y.rok_abs)",
    "                  .map( (y) => html`<p><b>Rok ${y.rok_abs}:</b> ${y.alert}</p>` )}",
    "                </div>`",
    "  } else {",
    "    return html``",
    "  }",
    "}",
    "```",
    ""
  )
  plikSzablonWykresu <- paste0("plot_templates/", w$id, ".ojs")
  if (file.exists(plikSzablonWykresu)) {
    wykres <- c(readLines(paste0("plot_templates/", w$id, ".ojs")),
                "")
  } else {
    wykres <- c()
  }
  if (!("noValueTable" %in% names(w))) w$noValueTable <- "false"
  if (w$noValueTable == "true") {
    tabelaWynikow <- c()
  } else {
    tabelaWynikow <- c(
      "```{ojs}",
      "//| echo: false",
      paste0("viewof ", w$id, "_tabela_wynikow = Inputs.toggle("),
      "  {",
      '    label: "Pokaż tabelę wartości",',
      "    value: false,",
      paste0("    disabled: ", w$id, "C.length == 0"),
      "  }",
      ")",
      "{",
      paste0("  if (", w$id, "_tabela_wynikow && ", w$id, "C.length > 0) {"),
      paste0("    return aq.from(", w$id, "C)"),
      paste0("             .select(aq.names(Object.keys(", w$id, "C[0])"),
      paste0("                              .map( (c) => (labels.", w$id, "[c]) )))"),
      "             .view({",
      "               format: {",
      paste0('                 "', w$colLabels$value, '":'),
      paste0("                   ", w$valueFormat),
      "               }",
      "             })",
      "  } else {",
      "    return html``",
      "  }",
      "}",
      "```",
      ""
    )
  }
  pobieranieWynikow <- c(
    "---",
    "",
    "```{ojs}",
    "//| echo: false",
    paste0(w$id, "D = [].concat("),
    paste0("  ...", w$id, "F"),
    '  .filter( (g) => Object.hasOwn(g.wartosc, "w") )',
    "  .map( (g) => g.wartosc.w.map(",
    paste0('    (x) => Object.assign({}, x, { TERYT: "', teryt, '",'),
    paste0('                                  JST: "', nazwaJST, '",'),
    paste0(paste(sapply(filtry[order(sapply(filtry, \(x) x$id == "rok_abs"))],
                        \(f) paste0("                                  ",
                                    f$id, ": g.", f$id)),
                 collapse = ",
"), " })"),
    "               )",
    "  )",
    ")",
    "Inputs.button(",
    '  "Pobierz dane (CSV)",',
    "  {",
    "    reduce: () =>",
    paste0("      download_csv(aq.from(", w$id, "D)"),
    paste0("                   .rename(aq.names(Object.keys(", w$id, "D[0])"),
    "                                    .map( (c) =>",
    paste0("                                          Object.assign({}, labels.", w$id, ","),
    "                                                            labels.filters)[c] )))",
    paste0("                   .relocate([",
           paste(1L + seq_len(length(filtry) + 2L), collapse = ","),
           "], {before: 0})"),
    "                   .toCSV(),",
    paste0('                   "', w$id, '.csv"),'),
    paste0("    disabled: ", w$id, "C.length == 0"),
    "  }",
    ")",
    "```",
    ""
  )
  if (teryt != "000000") {
    linkDoRSPO <- c(
      "---",
      "",
      "```{ojs}",
      "//| echo: false",
      paste0('html`Sprawdź w Rejestrze Szkół i Placówek Oświatowych (RSPO), jakie szkoły wybranego typu funkcjonują w ',
             nazwaJSTMiejscownik, ': <a href="https://rspo.gov.pl/institutions?q=%7B',
             rspoParsJST, ',${rspoSchoolTypes[', w$id, '_typ_szk]}%7D", target="_blank">${', w$id, '_typ_szk}</a>`'),
      "```",
      ""
    )
  } else {
    linkDoRSPO <- c()
  }

  return(c(naglowekZakladki,
           opis,
           inicjalizacjaWyborow,
           filtrowanie,
           synchronizacjaWyborow,
           wczytywanieDanych,
           przeksztalcanieDanych,
           komunikatyOBrakach,
           wykres,
           tabelaWynikow,
           pobieranieWynikow,
           linkDoRSPO))
}
# Funkcja przygotuj_kod_strony() ###############################################
przygotuj_kod_strony <- function(jst, filtry, wskazniki, sasiedzi = NULL) {
  id = jst$id

  sciezkaDoZrodla <- paste(rep("../", c(k = 1, w = 2, p = 3)[jst$level]),
                           collapse = "")
  stopifnot("rok_abs" %in% sapply(filtry, \(f) f$id))

  naglowek <- c(
    "---",
    paste0('title: "', jst$name, '"'),
    "format: html",
    "---",
    "",
    "```{ojs}",
    "//| echo: false",
    "//| output: false",
    "import { aq, op } from '@uwdata/arquero'",
    paste0("import { alertNoData, labels, pallets, palletsFg, rspoSchoolTypes } from '",
           sciezkaDoZrodla, "resources/constants.js'"),
    paste0("import { set_diff, sort_overall_first, sort_numeric, compare, input_values_equal, download_csv, sequence } from '",
           sciezkaDoZrodla, "resources/functions.js'"),
    "```",
    ""
  )
  if (!is.null(sasiedzi)) {
    nawigacja <- c(
     "**Przejdź do sąsiednich:**",
     "",
     paste0(mapply(function(id, pt, nm) {paste0("[", nm, "](../", pt, "/", id, ".qmd)")},
                   sasiedzi$id, sasiedzi$parent, sasiedzi$genitive),
            collapse = ", "),
     "",
     "---",
     ""
    )
  } else {
    nawigacja <- c()
  }
  zakladki <- c(
    "::: {.panel-tabset}",
    "",
    unlist(lapply(wskazniki, przygotuj_kod_zakladki, filtry = filtry,
                  sciezkaDoZrodla = sciezkaDoZrodla,
                  teryt = id, nazwaJST = jst$name,
                  nazwaJSTMiejscownik = jst$locativus,
                  rspoParsJST = paste0("%22stateId%22:", jst$RSPOstateId,
                                       ifelse(is.na(jst$RSPOdistrictId), "",
                                              paste0(",%22districtId%22:",
                                                     jst$RSPOdistrictId))))),
    ":::",
    ""
  )
  stopka <- c()

  return(c(naglowek,
           nawigacja,
           zakladki,
           stopka))
}
# Generowanie plików jako takie ################################################
for (i in which(jst$level == "k")) {
  writeLines(przygotuj_kod_strony(jst[i, ], filtry = filtry, wskazniki = wsk),
             paste0("territorial_units/", jst$id[i], ".qmd"))
}
if (!("000000" %in% list.dirs("territorial_units/", full.names = FALSE))) {
  dir.create("territorial_units/000000/")
}

for (i in which(jst$level == "w")) {
  writeLines(przygotuj_kod_strony(jst[i, ], filtry = filtry, wskazniki = wsk,
                                  sasiedzi = jst[jst$id %in%
                                                   jst$neighbours[i][[1]], ]),
             paste0("territorial_units/000000/", jst$id[i], ".qmd"))
  if (!(jst$id[i] %in%
        list.dirs("territorial_units/000000/",
                  full.names = FALSE))) dir.create(paste0("territorial_units/000000/",
                                                          jst$id[i]))
  for (j in which(jst$parent == jst$id[i])) {
    writeLines(przygotuj_kod_strony(jst[j, ], filtry = filtry, wskazniki = wsk,
                                    sasiedzi = jst[jst$id %in%
                                                     jst$neighbours[j][[1]], ]),
               paste0("territorial_units/000000/", jst$id[i], "/",
                      jst$id[j], ".qmd"))
  }
}
# Zapis pliku resources/constants.js ###########################################
komunikatBrakDanych <- c(
  'export const alertNoData = "W danych nie ma absolwentów pasujących do podanych kryteriów.";',
  ""
)
etykiety <- c(
  "export const labels = {",
  paste0(paste(sapply(
    wsk,
    \(x) paste0("  ", x$id, ": {
",
                paste0("    ", names(x$colLabels), ': "', x$colLabels, '"',
                       collapse = ",
"), "
  }")),
    collapse = ",
"), ","),
  "  filters: {",
  paste(sapply(
    filtry,
    \(x) paste0("    ", x$id, ': "', x$label, '"', collapse = ",
")),
    collapse = ",
"),
  "  }",
  "};"
)
palety <- c(
  "export const pallets = {",
  wsk[sapply(wsk, \(x) "palette" %in% names(x))] |>
    sapply(\(x) paste0("  ", x$id, ": {
",
                       paste0('    "', names(x$palette), '": "', x$palette, '"',
                              collapse = ",
"), "
  }")) |>
    paste(collapse = ",
"),
  "};"
)
paletyFg <- c(
  "export const palletsFg = {",
  wsk[sapply(wsk, \(x) "paletteFg" %in% names(x))] |>
    sapply(\(x) paste0("  ", x$id, ": {
",
                       paste0('    "', names(x$paletteFg), '": "', x$paletteFg, '"',
                              collapse = ",
"), "
  }")) |>
    paste(collapse = ",
"),
  "};"
)
rspoTypySzkol <- c(
  'export const rspoSchoolTypes = {',
  '  "Liceum ogólnokształcące": "%22institutionTypeIdList%22:[14,90],%22categoryIdList%22:[1]",',
  '  "Technikum": "%22institutionTypeIdList%22:[16]",',
  '  "Branżowa szkoła II stopnia": "%22institutionTypeIdList%22:[94]",',
  '  "Szkoła policealna": "%22institutionTypeIdList%22:[19]",',
  '  "Branżowa szkoła I stopnia": "%22institutionTypeIdList%22:[93]",',
  '  "Szkoła specjalna przysposabiająca do pracy": "%22institutionTypeIdList%22:[20]",',
  '  "Liceum dla dorosłych": "%22institutionTypeIdList%22:[14],%22categoryIdList%22:[2]",',
  '};'
)
writeLines(c(komunikatBrakDanych, etykiety, palety, paletyFg, rspoTypySzkol),
           "resources/constants.js")
# Generowanie pliku z opisem bocznego menu nawigacyjnego #######################
sidebarContents <- 'website:
  sidebar:
    contents:
      - about.qmd
      - text: "---"
      - "territorial_units/000000.qmd"
      - section: "Województwa"
        contents:
'
for (i in which(jst$level == "w")) {
  sidebarContents <- paste0(
    sidebarContents,
    '         - text: "', sub("Województwo ", "", jst$name[i]), '"
           href: "territorial_units/000000/', jst$id[i], '.qmd"
           contents:
')
  for (j in which(jst$parent == jst$id[i])) {
    sidebarContents <- paste0(
      sidebarContents,
      '           - text: "', jst$name[j], '"
             href: "territorial_units/000000/', jst$id[i], "/", jst$id[j], '.qmd"
')
  }
}
writeLines(sidebarContents, "_sidebar_contents.yml")
