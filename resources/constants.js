export const alertNoData = "W danych nie ma absolwentów pasujących do podanych kryteriów.";

export const labels = {
  status: {
    rok_abs: "Rok ukończenia szkoły",
    label: "Status edukacyjno-zawodowy",
    value: "Odsetek absolwentów (kończących szkołę w danym roku)"
  },
  bezrobocie: {
    rok_abs: "Rok ukończenia szkoły",
    label: "Bezrobocie rejestrowane",
    value: "Odsetek absolwentów (kończących szkołę w danym roku)"
  },
  sr_wynagr: {
    rok_abs: "Rok ukończenia szkoły",
    label: "Statystyka",
    value: "Średnie wynagrodzenie miesięczne z umowy o pracę"
  },
  matura_zdana: {
    rok_abs: "Rok ukończenia szkoły",
    label: "Wynik egzaminu maturalnego",
    value: "Odsetek absolwentów (kończących szkołę w danym roku)"
  },
  dyplom_zaw: {
    rok_abs: "Rok ukończenia szkoły",
    label: "Uzyskanie dyplomu/certyfikatu/świadectwa zawodowego",
    value: "Odsetek absolwentów (kończących szkołę w danym roku)"
  },
  typ_szk_kont: {
    rok_abs: "Rok ukończenia szkoły",
    label: "Forma kontynuowania nauki",
    value: "Odsetek absolwentów (kończących szkołę w danym roku)"
  },
  dyscyplina_kont: {
    rok_abs: "Rok ukończenia szkoły",
    label: "Dyscyplina studiów",
    value: "Odsetek absolwentów (kończących szkołę w danym roku) kontynuujących naukę na studiach"
  },
  filters: {
    typ_szk: "Typ szkoły:",
    rok_abs: "Rok ukończenia szkoły:",
    szk_specjalna: "Czy szkoła specjalna?",
    plec: "Płeć",
    nazwa_zaw: "Zawód:",
    czas: "Miesiąc od ukończenia szkoły:"
  }
};
export const pallets = {
  status: {
    "Tylko nauka": "#009899",
    "Nauka i praca": "#feae51",
    "Tylko praca": "#f66831",
    "Bezrobocie": "#0063aa",
    "Brak danych o aktywności": "#b1b1b1"
  },
  bezrobocie: {
    "Zarejestrowany jako bezrobotny": "#d73568",
    "Brak statusu bezrobotnego": "#feae51"
  },
  sr_wynagr: {
    "średnia": "#00a7db"
  },
  matura_zdana: {
    "Uzyskanie świadectwa dojrzałości": "#ec625a",
    "Brak świadectwa dojrzałości": "#3a4050"
  },
  dyplom_zaw: {
    "Świadectwo czeladnicze": "#009899",
    "Dyplom zawodowy": "#ec625a",
    "Tylko certyfikat kwalifikacji": "#f7af41",
    "Brak certyfikatów i dyplomu": "#b1b1b1"
  },
  typ_szk_kont: {
    "Szkoła policealna": "#f66831",
    "KKZ": "#f7af41",
    "KUZ": "#f7af41",
    "Liceum dla dorosłych": "#3d4f7d",
    "Branżowa szkoła II stopnia": "#f66831",
    "Studia": "#3d4f7d"
  }
};
export const palletsFg = {
  status: {
    "Tylko nauka": "#FFFFFF",
    "Nauka i praca": "#000000",
    "Tylko praca": "#FFFFFF",
    "Bezrobocie": "#FFFFFF",
    "Brak danych o aktywności": "#000000"
  },
  bezrobocie: {
    "Zarejestrowany jako bezrobotny": "#FFFFFF",
    "Brak statusu bezrobotnego": "#000000"
  },
  sr_wynagr: {
    "średnia": "#000000"
  },
  matura_zdana: {
    "Uzyskanie świadectwa dojrzałości": "#FFFFFF",
    "Brak świadectwa dojrzałości": "#FFFFFF"
  },
  dyplom_zaw: {
    "Świadectwo czeladnicze": "#FFFFFF",
    "Dyplom zawodowy": "#FFFFFF",
    "Tylko certyfikat kwalifikacji": "#000000",
    "Brak certyfikatów i dyplomu": "#000000"
  },
  typ_szk_kont: {
    "Szkoła policealna": "#000000",
    "KKZ": "#000000",
    "KUZ": "#000000",
    "Liceum dla dorosłych": "#000000",
    "Branżowa szkoła II stopnia": "#000000",
    "Studia": "#000000"
  }
};
export const rspoSchoolTypes = {
  "Liceum ogólnokształcące": "%22institutionTypeIdList%22:[14,90],%22categoryIdList%22:[1]",
  "Technikum": "%22institutionTypeIdList%22:[16]",
  "Branżowa szkoła II stopnia": "%22institutionTypeIdList%22:[94]",
  "Szkoła policealna": "%22institutionTypeIdList%22:[19]",
  "Branżowa szkoła I stopnia": "%22institutionTypeIdList%22:[93]",
  "Szkoła specjalna przysposabiająca do pracy": "%22institutionTypeIdList%22:[20]",
  "Liceum dla dorosłych": "%22institutionTypeIdList%22:[14],%22categoryIdList%22:[2]",
};
