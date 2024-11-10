library(httr2)
library(dplyr)
library(tidyr)

# TODO: replace logic for geographies and series with wbwdi package once it
#       is on CRAN and att it to Suggests
# TOOD: replace logic for counterparts and geographies with econid package
#       once it is on CRAN and add it to Suggests

# Fetch countries and regions from World Bank WDI API ----

url_geographies_wdi <- paste0(
  "https://api.worldbank.org/v2/countries",
  "?per_page=32500&format=json"
)

geographies_raw <- request(url_geographies_wdi) |>
  req_perform() |>
  resp_body_json()

aggregates <- geographies_raw[[2]] |>
  bind_rows() |>
  unnest(region) |>
  filter(region == "Aggregates") |>
  pull(id)

geographies_wdi <- geographies_raw[[2]] |>
  bind_rows() |>
  select(
    geography_iso3code = id,
    geography_iso2code = iso2Code,
    geography_name = name
  ) |>
  distinct() |>
  mutate(geography_type = if_else(
    geography_iso3code %in% aggregates, "Region", "Country"
  ))

# Fetch counterparts from World Bank International Debt Statistics API  ----

url_counterparts_ids <- paste0(
  "https://api.worldbank.org/v2/sources/",
  "6/counterpart-area?per_page=32500&format=json"
)

counterparts_raw <- request(url_counterparts_ids) |>
  req_perform() |>
  resp_body_json()

counterparts_ids <- counterparts_raw$source[[1]]$concept[[1]]$variable |>
  bind_rows() |>
  select(counterpart_id = id,
         counterpart_name = value) |>
  mutate(across(where(is.character), trimws))

# Enrich counterparts with codes and types -------------------------------

# Used ChatGPT to create this tribble, but also checked for most countries
geographies_manual <- tribble(
  ~geography_name, ~geography_iso2code, ~geography_iso3code, ~geography_type,
  "African Dev. Bank", NA, NA, "Institution",
  "African Export-Import Bank", NA, NA, "Institution",
  "Anguilla", "AI", "AIA", "Country",
  "Antigua", "AG", "ATG", "Country",
  "Arab African International Bank", NA, NA, "Institution",
  "Arab Bank for Economic Dev. in Africa (BADEA)", NA, NA, "Institution",
  "Arab Fund for Economic & Social Development", NA, NA, "Institution",
  "Arab Fund for Tech. Assist. to African Countries", NA, NA, "Institution",
  "Arab International Bank", NA, NA, "Institution",
  "Arab League", NA, NA, "Institution",
  "Arab Monetary Fund", NA, NA, "Institution",
  "Arab Towns Organization (ATO)", NA, NA, "Institution",
  "Asian Dev. Bank", NA, NA, "Institution",
  "Asian Infrastructure Investment Bank", NA, NA, "Institution",
  "Bahamas", "BS", "BHS", "Country",
  "Bank for International Settlements (BIS)", NA, NA, "Institution",
  "Bolivarian Alliance for the Americas (ALBA)", NA, NA, "Institution",
  "Bondholders", NA, NA, "Institution",
  "Bosnia-Herzegovina", "BA", "BIH", "Country",
  "Brunei", "BN", "BRN", "Country",
  "Caribbean Community (CARICOM)", NA, NA, "Institution",
  "Caribbean Dev. Bank", NA, NA, "Institution",
  "Center for Latin American Monetary Studies (CEMLA)", NA, NA, "Institution",
  "Central American Bank for Econ. Integ. (CABEI)", NA, NA, "Institution",
  "Central American Bank for Econ. Integration (BCIE)", NA, NA, "Institution",
  "Central Bank of West African States (BCEAO)", NA, NA, "Institution",
  "Colombo Plan", NA, NA, "Institution",
  "Corporacion Andina de Fomento", NA, NA, "Institution",
  "Cote D`Ivoire, Republic Of", "CI", "CIV", "Country",
  "Council of Europe", NA, NA, "Institution",
  "Czechoslovakia", "CS", "CSK", "Country",
  "Dev. Bank of the Central African States (BDEAC)", NA, NA, "Institution",
  "ECO Trade and Dev. Bank", NA, NA, "Institution",
  "EUROFIMA", NA, NA, "Institution",
  "East African Community", NA, NA, "Institution",
  "Eastern & Southern African Trade & Dev. Bank (TDB)", NA, NA, "Institution",
  "Econ. Comm. of the Great Lakes Countries (ECGLC)", NA, NA, "Institution",
  "Economic Community of West African States (ECOWAS)", NA, NA, "Institution",
  "Egypt", "EG", "EGY", "Country",
  "Entente Council", NA, NA, "Institution",
  "Eurasian Development Bank", NA, NA, "Institution",
  "European Bank for Reconstruction and Dev. (EBRD)", NA, NA, "Institution",
  "European Coal and Steel Community (ECSC)", NA, NA, "Institution",
  "European Development Fund (EDF)", NA, NA, "Institution",
  "European Economic Community (EEC)", NA, NA, "Institution",
  "European Free Trade Association (EFTA)", NA, NA, "Institution",
  "European Investment Bank", NA, NA, "Institution",
  "European Relief Fund", NA, NA, "Institution",
  "European Social Fund (ESF)", NA, NA, "Institution",
  "Fondo Latinoamericano de Reservas (FLAR)", NA, NA, "Institution",
  "Food and Agriculture Organization (FAO)", NA, NA, "Institution",
  "Foreign Trade Bank of Latin America (BLADEX)", NA, NA, "Institution",
  "German Dem. Rep.", "DD", "DDR", "Country",
  "Germany, Fed. Rep. of", "DE", "DEU", "Country",
  "Global Environment Facility", NA, NA, "Institution",
  "Guadeloupe", "GP", "GLP", "Country",
  "Hong Kong", "HK", "HKG", "Country",
  "Inter-American Dev. Bank", NA, NA, "Institution",
  "International Bank for Economic Cooperation (IBEC)", NA, NA, "Institution",
  "International Coffee Organization (ICO)", NA, NA, "Institution",
  "International Finance Corporation", NA, NA, "Institution",
  "International Fund for Agricultural Dev.", NA, NA, "Institution",
  "International Investment Bank (IIB)", NA, NA, "Institution",
  "International Labour Organization (ILO)", NA, NA, "Institution",
  "International Monetary Fund", NA, NA, "Institution",
  "Iran, Islamic Republic Of", "IR", "IRN", "Country",
  "Islamic Dev. Bank", NA, NA, "Institution",
  "Islamic Solidarity Fund for Dev. (ISFD)", NA, NA, "Institution",
  "Korea, D.P.R. of", "KP", "PRK", "Country",
  "Korea, Republic of", "KR", "KOR", "Country",
  "Lao People's Democratic Rep.", "LA", "LAO", "Country",
  "Latin Amer. Conf. of Saving & Credit Coop. (COLAC)", NA, NA, "Institution",
  "Latin American Agribusiness Dev. Corp. (LAAD)", NA, NA, "Institution",
  "Macao", "MO", "MAC", "Country",
  "Micronesia Fed Sts", "FM", "FSM", "Country",
  "Montreal Protocol Fund", NA, NA, "Institution",
  "Multiple Lenders", NA, NA, "Other",
  "Neth. Antilles", "AN", "ANT", "Country",
  "New Caledonia (Fr.)", "NC", "NCL", "Country",
  "Nordic Development Fund", NA, NA, "Institution",
  "Nordic Environment Finance Corporation (NEFCO)", NA, NA, "Institution",
  "Nordic Investment Bank", NA, NA, "Institution",
  "OPEC Fund for International Dev.", NA, NA, "Institution",
  "Org. of Arab Petroleum Exporting Countries (OAPEC)", NA, NA, "Institution",
  "Other Multiple Lenders", NA, NA, "Other",
  "Pacific Is. (Us)", NA, NA, "Institution",
  "Plata Basin Financial Dev. Fund", NA, NA, "Institution",
  "Reunion", "RE", "REU", "Country",
  "Sao Tome & Principe", "ST", "STP", "Country",
  "South Asian Development Fund (SADF)", NA, NA, "Institution",
  "St. Kitts And Nevis", "KN", "KNA", "Country",
  "St. Vincent & The Grenadines", "VC", "VCT", "Country",
  "Surinam", "SR", "SUR", "Country",
  "Trinidad & Tobago", "TT", "TTO", "Country",
  "USSR", "SU", "SUN", "Country",
  "UN-Children's Fund (UNICEF)", NA, NA, "Institution",
  "UN-Development Fund for Women (UNIFEM)", NA, NA, "Institution",
  "UN-Development Programme (UNDP)", NA, NA, "Institution",
  "UN-Educ., Scientific and Cultural Org. (UNESCO)", NA, NA, "Institution",
  "UN-Environment Programme (UNEP)", NA, NA, "Institution",
  "UN-Fund for Drug Abuse Control (UNFDAC)", NA, NA, "Institution",
  "UN-Fund for Human Rights", NA, NA, "Institution",
  "UN-General Assembly (UNGA)", NA, NA, "Institution",
  "UN-High Commissioner for Refugees (UNHCR)", NA, NA, "Institution",
  "UN-INSTRAW", NA, NA, "Institution",
  "UN-Industrial Development Organization (UNIDO)", NA, NA, "Institution",
  "UN-Office on Drugs and Crime (UNDCP)", NA, NA, "Institution",
  "UN-Population Fund (UNFPA)", NA, NA, "Institution",
  "UN-Regular Programme of Technical Assistance", NA, NA, "Institution",
  "UN-Regular Programme of Technical Coop. (RPTC)", NA, NA, "Institution",
  "UN-Relief and Works Agency (UNRWA)", NA, NA, "Institution",
  "UN-UNETPSA", NA, NA, "Institution",
  "UN-World Food Programme (WFP)", NA, NA, "Institution",
  "UN-World Intellectual Property Organization", NA, NA, "Institution",
  "UN-World Meteorological Organization", NA, NA, "Institution",
  "Venezuela, Republic Bolivarian", "VE", "VEN", "Country",
  "Virgin Is.(US)", "VI", "VIR", "Country",
  "West African Development Bank - BOAD", NA, NA, "Institution",
  "West African Monetary Union (UMOA)", NA, NA, "Institution",
  "World Bank-IBRD", NA, NA, "Institution",
  "World Bank-IDA", NA, NA, "Institution",
  "World Bank-MIGA", NA, NA, "Institution",
  "World Health Organization", NA, NA, "Institution",
  "World Trade Organization", NA, NA, "Institution",
  "Yemen, Republic Of", "YE", "YEM", "Country",
  "Yugoslavia", "YU", "YUG", "Country"
)

counterparts_ids_enriched <- counterparts_ids |>
  left_join(
    bind_rows(geographies_wdi, geographies_manual),
    join_by(counterpart_name == geography_name)
  )

# Some counterparts have better names from WDI (e.g. Germany)
counterparts_ids_cleaned <- counterparts_ids_enriched |>
  left_join(
    geographies_wdi,
    join_by(geography_iso2code, geography_iso3code, geography_type)
  ) |>
  mutate(counterpart_name = if_else(
    !is.na(geography_name), geography_name, counterpart_name
  )) |>
  select(-geography_name)

global_ifis <- c(
  "International Monetary Fund",
  "Bank for International Settlements (BIS)"
)

global_mdbs <- c(
  "World Bank-IDA",
  "World Bank-IBRD",
  "World Bank-MIGA",
  "International Finance Corporation",
  "International Fund for Agricultural Dev.",
  "European Bank for Reconstruction and Dev. (EBRD)",
  "African Dev. Bank",
  "Asian Dev. Bank",
  "Inter-American Dev. Bank",
  "Asian Infrastructure Investment Bank"
)

counterparts <- counterparts_ids_cleaned |>
  mutate(
    counterpart_type = case_when(
      counterpart_name %in% global_ifis ~ "Global IFIs",
      counterpart_name %in% global_mdbs ~ "Global MDBs",
      counterpart_name %in% c("Bondholders") ~ "Bondholders",
      counterpart_name %in% c("World") ~ "All Creditors",
      geography_type == "Country" ~ "Country",
      geography_type == "Region" ~ "Region",
      .default = "Other"
    )
  ) |>
  rename(geography_id = geography_iso3code)

# Use processed counterparts to enrich geographies -----------------------

geographies <- geographies_wdi |>
  rename(geography_id = geography_iso3code) |>
  bind_rows(
    counterparts |>
      filter(!is.na(geography_id)) |>
      select(contains("geography"), geography_name = counterpart_name)
  ) |>
  distinct() |>
  arrange(geography_id)

# Prepare series data ----------------------------------------------------------

url_series_ids <- paste0(
  "https://api.worldbank.org/v2/sources/",
  "6/series?per_page=32500&format=json"
)

series_ids_raw <- request(url_series_ids) |>
  req_perform() |>
  resp_body_json()

series_ids <- series_ids_raw$source[[1]]$concept[[1]]$variable |>
  bind_rows() |>
  select(
    series_id = "id",
    series_name = "value"
  )

url_series_wdi <- paste0(
  "https://api.worldbank.org/v2/indicators",
  "?per_page=32500&format=json"
)

indicators_wdi_raw <- request(url_series_wdi) |>
  req_perform() |>
  resp_body_json(simplifyVector = TRUE)

indicators_wdi <- indicators_wdi_raw[[2]] |>
  as_tibble() |>
  rename(series_id = id, indicator_name = name) |>
  unnest_wider(source) |>
  rename(
    source_id = id,
    source_name = value,
    source_note = sourceNote,
    source_organization = sourceOrganization
  ) |>
  select(-unit) |>
  mutate(
    source_id = as.integer(source_id),
    source_note = na_if(source_note, ""),
    source_organization = na_if(source_organization, "")
  )

series_extended <- series_ids |>
  left_join(indicators_wdi, join_by(series_id))

series <- series_extended |>
  select(series_id, series_name, source_id, source_name,
         source_note, source_organization)

# Prepare series-topics data ---------------------------------------------------

series_topics <- indicators_wdi |>
  select(series_id, topics) |>
  unnest_longer(topics) |>
  unnest_wider(topics) |>
  rename(topic_id = id, topic_name = value) |>
  mutate(
    topic_id = as.integer(topic_id),
    topic_name = trimws(topic_name)
  ) |>
  inner_join(series_ids |> select(series_id), join_by(series_id))

# Store all data in single rda file --------------------------------------------

save(
  geographies, series, counterparts, series_topics,
  file = "R/sysdata.rda"
)
