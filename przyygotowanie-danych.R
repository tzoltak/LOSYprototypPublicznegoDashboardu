library(dplyr)
library(LOSYwskazniki)

zmPrzeciecia <- c("typ_szk", "szk_specjalna",
                  "kod_zaw", "nazwa_zaw", "plec")
miesOdUkoncz <- c(6L, 18L)
zmWskazniki <- list(p4 = c("dyplom_zaw", "matura_zdana",
                           paste0("typ_szk_kont", miesOdUkoncz),
                           paste0("dyscyplina_kont", miesOdUkoncz),
                           "sr_wynagr_r1"),
                    p3 = c("status", "bezrobocie"))

pol <- woj <- pow <- data.frame()
for (rok in 2021L:2025L) {
  cat("\n########## edycja ", rok,
      " (", format(Sys.time(), "%H:%M:%S"), ") ##########\n\n",
      sep = "")
  load(paste0("../../../dane administracyjne/tabele-pośrednie-", rok,
              ifelse(rok >= 2025L, "", "-v2025"), "-bez-dupl.RData"))
  rm(p1, p2, p5, p6)
  p4 <- p4 |>
    filter(rok_abs == (rok - 2L)) |>
    mutate(plec = factor(plec, c("K", "M"), c("Kobiety", "Mężczyźni")),
           szk_specjalna = factor(szk_specjalna,
                                  c(FALSE, TRUE), c("Nie", "Tak")),
           matura_zdana = factor(matura_zdana, c(1, 0),
                                 c("Uzyskanie świadectwa dojrzałości",
                                   "Brak świadectwa dojrzałości")),
           typ_szk_kont6 = typ_szk_kont6[, colnames(typ_szk_kont6) != "KUZ"],
           typ_szk_kont18 = typ_szk_kont18[, colnames(typ_szk_kont18) != "KUZ"])
  p3 <- p3 |>
    filter(mies_od_ukoncz %in% miesOdUkoncz) |>
    semi_join(p4,
              by = c("id_abs", "rok_abs")) |>
    mutate(bezrobocie = factor(bezrobocie  %in% 1L,
                               c(TRUE, FALSE),
                               c("Zarejestrowany jako bezrobotny",
                                 "Brak statusu bezrobotnego")))
  pol <- oblicz_wskazniki_pd_jst(p4, p3, "Polska",
                                 zmGrupujace = zmPrzeciecia,
                                 zmWskaznikiP4 = zmWskazniki$p4,
                                 zmWskaznikiP3 = zmWskazniki$p3) |>
    filter(wskaznik != "dyplom_zaw" |
             !(typ_szk %in% c("Liceum ogólnokształcące",
                              "Liceum dla dorosłych",
                              "Szkoła specjalna przysposabiająca do pracy")),
           wskaznik != "matura_zdana" |
             !(typ_szk %in% c("Branżowa szkoła I stopnia",
                              "Szkoła policealna",
                              "Szkoła specjalna przysposabiająca do pracy")),
           wskaznik != "dyscyplina_kont" |
             !(typ_szk %in% c("Branżowa szkoła I stopnia",
                              "Szkoła specjalna przysposabiająca do pracy"))) |>
    zanonimizuj_wskazniki_pd(progAbs = 10, progSzk = 3,
                             wskUsuwajZestawWartosci = "dyscyplina_kont") |>
    bind_rows(pol)
  woj <- oblicz_wskazniki_pd_jst(p4, p3, "wojewodztwa",
                                 zmGrupujace = zmPrzeciecia,
                                 zmWskaznikiP4 = zmWskazniki$p4,
                                 zmWskaznikiP3 = zmWskazniki$p3) |>
    filter(wskaznik != "dyplom_zaw" |
             !(typ_szk %in% c("Liceum ogólnokształcące",
                              "Liceum dla dorosłych",
                              "Szkoła specjalna przysposabiająca do pracy")),
           wskaznik != "matura_zdana" |
             !(typ_szk %in% c("Branżowa szkoła I stopnia",
                              "Szkoła policealna",
                              "Szkoła specjalna przysposabiająca do pracy")),
           wskaznik != "dyscyplina_kont" |
             !(typ_szk %in% c("Branżowa szkoła I stopnia",
                              "Szkoła specjalna przysposabiająca do pracy"))) |>
    zanonimizuj_wskazniki_pd(progAbs = 10, progSzk = 3,
                             wskUsuwajZestawWartosci = "dyscyplina_kont") |>
    bind_rows(woj)
  pow <- oblicz_wskazniki_pd_jst(p4, p3, "powiaty",
                                 zmGrupujace = zmPrzeciecia,
                                 zmWskaznikiP4 = zmWskazniki$p4,
                                 zmWskaznikiP3 = zmWskazniki$p3) |>
    filter(wskaznik != "dyplom_zaw" |
             !(typ_szk %in% c("Liceum ogólnokształcące",
                              "Liceum dla dorosłych",
                              "Szkoła specjalna przysposabiająca do pracy")),
           wskaznik != "matura_zdana" |
             !(typ_szk %in% c("Branżowa szkoła I stopnia",
                              "Szkoła policealna",
                              "Szkoła specjalna przysposabiająca do pracy")),
           wskaznik != "dyscyplina_kont" |
             !(typ_szk %in% c("Branżowa szkoła I stopnia",
                              "Szkoła specjalna przysposabiająca do pracy"))) |>
    zanonimizuj_wskazniki_pd(progAbs = 10, progSzk = 3,
                             wskUsuwajZestawWartosci = "dyscyplina_kont") |>
    bind_rows(pow)
  rm(p3, p4)
}
save(pol, woj, pow, file = "wszystkie-dane.RData", compress = "xz")

library(dplyr)
library(LOSYwskazniki)
load("wszystkie-dane.RData")

pol <- pol |>
  filter(sapply(wartosc, \(x) attributes(x)$lAbs != 0))
pol <- pol |>
  mutate(wartosc =
           lapply(wartosc,
                  function(x) {
                    if (length(x) > 1 | any(names(x) != "średnia")) {
                      x = x / attributes(x)$lAbs
                    }
                    return(x)
                  })) |>
  select(-c("wskaznik", "obszar", "kod_zaw")) |>
  przygotuj_wskazniki_pd_toJSON(
    komunikatCenzura = "W danych było mniej niż {lAbs} absolwentów pasujących do podanych kryteriów lub ukończyli oni mniej niż {lSzk} różne szkoły, w związku z czym wyniki nie mogą zostać pokazane.") |>
  split(pol$wskaznik) |>
  lapply(jsonlite::toJSON,
         dataframe = "rows", factor = "string", na = "null", pretty = FALSE)
for (i in seq_along(pol)) {
  writeLines(pol[[i]], paste0("data/000000-", names(pol)[i], ".json"))
}

woj <- woj |>
  filter(sapply(wartosc, \(x) attributes(x)$lAbs != 0))
woj <- woj |>
  mutate(wartosc =
           lapply(wartosc,
                  function(x) {
                    if (length(x) > 1 | any(names(x) != "średnia")) {
                      x = x / attributes(x)$lAbs
                    }
                    return(x)
                  })) |>
  select(-c("wskaznik", "teryt_woj_szk", "nazwa_woj_szk", "kod_zaw")) |>
  przygotuj_wskazniki_pd_toJSON(
    komunikatCenzura = "W danych było mniej niż {lAbs} absolwentów pasujących do podanych kryteriów lub ukończyli oni mniej niż {lSzk} różne szkoły, w związku z czym wyniki nie mogą zostać pokazane.") |>
  split(list(woj = sub("^ ", "0", format(10000*woj$teryt_woj_szk)),
             wskaznik = woj$wskaznik), sep = "-") |>
  lapply(jsonlite::toJSON,
         dataframe = "rows", factor = "string", na = "null", pretty = FALSE)
for (i in seq_along(woj)) {
  writeLines(woj[[i]], paste0("data/", names(woj)[i], ".json"))
}

pow <- pow |>
  filter(sapply(wartosc, \(x) attributes(x)$lAbs != 0))
pow <- pow |>
  mutate(wartosc =
           lapply(wartosc,
                  function(x) {
                    if (length(x) > 1 | any(names(x) != "średnia")) {
                      x = x / attributes(x)$lAbs
                    }
                    return(x)
                  })) |>
  select(-c("wskaznik", "teryt_pow_szk", "nazwa_pow_szk", "kod_zaw")) |>
  przygotuj_wskazniki_pd_toJSON(
    komunikatCenzura = "W danych było mniej niż {lAbs} absolwentów pasujących do podanych kryteriów lub ukończyli oni mniej niż {lSzk} różne szkoły, w związku z czym wyniki nie mogą zostać pokazane.") |>
  split(list(pow = sub("^ ", "0", format(100*pow$teryt_pow_szk)),
             wskaznik = pow$wskaznik), sep = "-") |>
  lapply(jsonlite::toJSON,
         dataframe = "rows", factor = "string", na = "null", pretty = FALSE)
for (i in seq_along(pow)) {
  writeLines(pow[[i]], paste0("data/", names(pow)[i], ".json"))
}
