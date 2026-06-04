
# 1. Preparar entorno

library(tidyverse)
library(writexl)



# 2. Importar datasets

# Tipos de interés
interest <- read_csv("C:/Users/Natalia/OneDrive/_Natalia/UOC/UOC_2025_2026/2_semestre/Visualizacion_de_datos/PRACT1/Data/Interes/API_FR.INR.RINR_DS2_es_csv_v2_17255.csv",
                     skip = 4)

# Inflación
inflation <- read_csv("C:/Users/Natalia/OneDrive/_Natalia/UOC/UOC_2025_2026/2_semestre/Visualizacion_de_datos/PRACT1/Data/inflacion/API_FP.CPI.TOTL.ZG_DS2_en_csv_v2_287.csv",
                      skip = 4)

# GDP per capita (PPP)
gdp_ppp <- read_csv("C:/Users/Natalia/OneDrive/_Natalia/UOC/UOC_2025_2026/2_semestre/Visualizacion_de_datos/PRACT1/Data/gdp_per_capita/API_NY.GDP.PCAP.PP.CD_DS2_en_csv_v2_43.csv",
                    skip = 4)

# Internet users (% población)
internet <- read_csv("C:/Users/Natalia/OneDrive/_Natalia/UOC/UOC_2025_2026/2_semestre/Visualizacion_de_datos/PRACT1/Data/internet_users/API_IT.NET.USER.ZS_DS2_en_csv_v2_325.csv",
                     skip = 4)

# Pagos digitales
findex <- read_csv("C:/Users/Natalia/OneDrive/_Natalia/UOC/UOC_2025_2026/2_semestre/Visualizacion_de_datos/PRACT1/Data/Pago_digital/GlobalFindexDatabase2025.csv")

a=findex %>%
  summarise(across(everything(), ~mean(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "pct_na") %>%
  arrange(desc(pct_na))

b= findex %>%
  select(where(~mean(is.na(.)) < 0.5))

# 3. Limpiar datasets del World Bank (interés + inflación)

# Función reutilizable (muy útil)
clean_worldbank <- function(df, value_name) {
  df %>%
    select(`Country Name`, `Country Code`, starts_with("19"), starts_with("20")) %>%
    pivot_longer(
      cols = -c(`Country Name`, `Country Code`),
      names_to = "year",
      values_to = value_name
    ) %>%
    rename(
      country = `Country Name`,
      country_id = `Country Code`
    ) %>%
    mutate(year = as.numeric(year))
}

# Aplicarlo:
interest_clean <- clean_worldbank(interest, "tipo_interes")

inflation_clean <- clean_worldbank(inflation, "inflacion")

gdp_clean <- clean_worldbank(gdp_ppp, "renta_per_capita_ppp")

internet_clean <- clean_worldbank(internet, "usuarios_internet")

# 4. Limpiar Global Findex

glimpse(findex)

findex_clean <- findex %>%
  select(
    # IDENTIFICACIÓN
    country = countrynewwb,
    country_id = codewb,
    year,
    region = regionwb24_hi,
    nivel_renta = incomegroupwb24,
    poblacion_adulta = pop_adult,
    grupo = group,
    grupo2 = group2,
    
    # ACCESO FINANCIERO
    cuenta = account_t_d,
    
    # USO SISTEMA FINANCIERO
    pagos_cuenta = fin30, # Uso de cuenta para pagos. personas que usan cuenta para:pagos, transacciones
    pagos_efectivo = fin31d, # Pago de servicios en efectivo % que paga facturas: solo en cash
    
    
    # 💰 AHORRO
    ahorro_formal = fin17a, # Ahorro en banco. % que ahorra en una institución financiera formal
    ahorro_total = save_any_t_d, #Ahorro total. % que ahorra de cualquier forma. incluye: formal, informal (familia, etc.)
    
    # PRESTAMO
    prestamo = borrow_any_t_d,
    
    # 💳 CRÉDITO
    credito_formal = fin22a, # Crédito bancario % que pide dinero a una institución financiera
    credito_informal = fin22b, # Crédito informal. préstamos de: familia, amigos
    
    # 📱 DIGITAL
    uso_digital = fin32, # Uso digital total uso de: cuentas, pagos electrónicos
    
    # 💳 INFRAESTRUCTURA
    tarjeta_debito = fin2_t_d, # Tiene tarjeta de débito % de población con tarjeta
    
    # 🌐 PAGOS DIGITALES (VARIABLE CLAVE)
    pagos_digitales = g20_any, # Pagos digitales totales. VARIABLE CLAVE % que: envía O recibe pagos digitales
    
    # 🧠 RESILIENCIA
    capacidad_emergencia = fin24aP, # Puede conseguir dinero en emergencia. % que sí podría conseguir fondos
  ) %>% 
  
  # 1️⃣ ESCALAR TODO (clave)
  mutate(
    across(
      c(
        cuenta,
        pagos_cuenta, pagos_efectivo,
        ahorro_formal, ahorro_total,
        prestamo, credito_formal, credito_informal,
        uso_digital,
        tarjeta_debito,
        pagos_digitales,
        capacidad_emergencia
      ),
      ~ .x * 100
    )
  ) %>%
  
  # 2️⃣ VARIABLES DERIVADAS
  mutate(
    inclusion_financiera = rowMeans(
      cbind(cuenta, pagos_digitales, uso_digital),
      na.rm = TRUE
    ),
    
    ratio_digital_efectivo = 100 * pagos_digitales / 
      (pagos_digitales + pagos_efectivo + 1e-6),
    
    uso_financiero = rowMeans(
      cbind(cuenta, ahorro_total, credito_formal),
      na.rm = TRUE
    ),
    
    dependencia_informal = 100 * credito_informal / 
      (credito_informal + credito_formal),
    
    vulnerabilidad = 100 - capacidad_emergencia
  )




# 6. Unir datasets
df_final <- findex_clean %>%
  left_join(interest_clean, by = c("country_id", "year")) %>%
  left_join(inflation_clean, by = c("country_id", "year")) %>%
  left_join(gdp_clean, by = c("country_id", "year")) %>%
  left_join(internet_clean, by = c("country_id", "year")) %>% 
  mutate(
    
    digitalizacion = rowMeans(
      cbind(usuarios_internet, uso_digital, pagos_digitales),
      na.rm = TRUE
    ),
    
    digital_ajustado = (pagos_digitales/100) * (usuarios_internet/100) * 100,
    
  ) %>% 
  select(
    country, country_id, year, region, nivel_renta, poblacion_adulta,
    grupo, grupo2, everything()
  ) %>%
  select(!matches("country\\.|\\.x|\\.y")) %>% 
  filter(!is.na(region)&
           !is.na(country)&
           year != 2022)

df_final_grupo <- df_final %>%
  group_by(country_id, year, grupo, grupo2) %>%
  summarise(
    country = first(country),
    region = first(region),
    nivel_renta = first(nivel_renta),
    across(where(is.numeric), ~ifelse(all(is.na(.x)), NA, mean(.x, na.rm = TRUE))),
    .groups = "drop"
  )

brecha_genero <- df_final_grupo %>%
  filter(grupo == "gender") %>%
  pivot_wider(names_from = grupo2, values_from = pagos_digitales) %>%
  mutate(brecha_genero = men - women)


# 7. Validar resultado

glimpse(df_final)
summary(df_final)


# 10 Usar mapas de países (shapefile o sf)

library(sf)
library(rnaturalearth)

world <- ne_countries(scale = "medium", returnclass = "sf")

world_clean <- world %>%
  select(
    iso_a3,
    name,
    continent,
    region_un,
    geometry
  )

map_data <- world %>%
  as.data.frame() %>%
  rename(country = name) %>% 
  select(
    iso_a3,
    continent,
    region_un,
    geometry
  )

df_geo <- world_clean %>%
  left_join(df_final_grupo, by = c("iso_a3" = "country_id")) %>% 
  select(-iso_a3)



ggplot(df_geo %>% filter(year == 2017, grupo == "all", grupo2 == "all")) +
  geom_sf(aes(fill = inclusion_financiera), color = NA) +
  scale_fill_viridis_c(option = "plasma", na.value = "grey90") +
  labs(
    title = "Inclusión financiera (2017)",
    fill = "% población"
  ) +
  theme_minimal()

# 1. Crear dataset principal
dataset_principal <- df_final_grupo %>%
  filter(
    grupo == "all",
    grupo2 == "all"
  )

write_xlsx(
  dataset_principal,
  "C:/Users/Natalia/OneDrive/_Natalia/UOC/UOC_2025_2026/2_semestre/Visualizacion_de_datos/PRACT1/Data/tablas/dataset_principal.xlsx"
)

# 2. Crear dataset brecha género

brecha_genero <- df_final_grupo %>%
  filter(
    grupo %in% c(
      "gender",
      "age_cat",
      "education"
    )
  )


brecha_genero_region <- df_final_grupo %>%
  filter(grupo == "gender") %>%
  group_by(year, region, grupo2) %>%
  summarise(
    inclusion_financiera = mean(inclusion_financiera, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_wider(
    names_from = grupo2,
    values_from = inclusion_financiera
  ) %>%
  mutate(
    women_neg = -women,
    brecha = men - women
  ) %>% 
  filter(
    is.finite(men),
    is.finite(women))

glimpse(brecha_genero_region)


brecha_genero_dot <- df_final_grupo %>%
  filter(grupo == "gender") %>%
  group_by(year, region, grupo2) %>%
  summarise(
    inclusion_financiera = mean(inclusion_financiera, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    sexo = case_when(
      grupo2 == "male" ~ "Men",
      grupo2 == "female" ~ "Women",
      TRUE ~ grupo2
    )
  ) %>%
  select(
    year,
    region,
    sexo,
    inclusion_financiera
  )

write_xlsx(
  brecha_genero_dot,
  "C:/Users/Natalia/OneDrive/_Natalia/UOC/UOC_2025_2026/2_semestre/Visualizacion_de_datos/PRACT1/Data/tablas/brecha_genero_dot.xlsx"
)



brecha_edad_region <- df_final_grupo %>%
  filter(grupo == "age_cat") %>%
  group_by(year, region, grupo2) %>%
  summarise(
    inclusion_financiera = mean(inclusion_financiera, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_wider(
    names_from = grupo2,
    values_from = inclusion_financiera
  ) %>%
  mutate(
    jovenes_neg = -`ages 15-24`,
    brecha = `age 25+` - `ages 15-24`
  ) %>%
  filter(
    is.finite(`age 25+`),
    is.finite(`ages 15-24`)
  )



brecha_edad_dot <- df_final_grupo %>%
  filter(grupo == "age_cat") %>%
  group_by(year, region, grupo2) %>%
  summarise(
    inclusion_financiera = mean(inclusion_financiera, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    grupo_edad = case_when(
      grupo2 == "ages 15-24" ~ "Jovenes",
      grupo2 == "age 25+" ~ "Adultos",
      TRUE ~ grupo2
    )
  ) %>%
  select(
    year,
    region,
    grupo_edad,
    inclusion_financiera
  ) %>%
  filter(is.finite(inclusion_financiera))


write_xlsx(
  brecha_edad_dot,
  "C:/Users/Natalia/OneDrive/_Natalia/UOC/UOC_2025_2026/2_semestre/Visualizacion_de_datos/PRACT1/Data/tablas/brecha_edad_region_dot.xlsx"
)


brecha_educacion_region <- df_final_grupo %>%
  filter(grupo == "education") %>%
  group_by(year, region, grupo2) %>%
  summarise(
    inclusion_financiera = mean(inclusion_financiera, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_wider(
    names_from = grupo2,
    values_from = inclusion_financiera
  ) %>%
  mutate(
    primaria_neg = -`prim edu or less`,
    brecha = `secondary edu or more` - `prim edu or less`
  ) %>%
  filter(
    is.finite(`secondary edu or more`),
    is.finite(`prim edu or less`)
  )


brecha_educacion_dot <- df_final_grupo %>%
  filter(grupo == "education") %>%
  group_by(year, region, grupo2) %>%
  summarise(
    inclusion_financiera = mean(inclusion_financiera, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    nivel_educativo = case_when(
      grupo2 == "prim edu or less" ~ "Educación baja",
      grupo2 == "secondary edu or more" ~ "Educación alta",
      TRUE ~ grupo2
    )
  ) %>%
  select(
    year,
    region,
    nivel_educativo,
    inclusion_financiera
  ) %>%
  left_join(
    brecha_educacion_region %>%
      select(year, region, brecha),
    by = c("year", "region")
  ) %>%
  filter(is.finite(inclusion_financiera))

write_xlsx(
  brecha_educacion_dot,
  "C:/Users/Natalia/OneDrive/_Natalia/UOC/UOC_2025_2026/2_semestre/Visualizacion_de_datos/PRACT1/Data/tablas/brecha_educacion_dot.xlsx"
)

# 3. Crear dataset colectivos

dataset_colectivos <- df_final_grupo %>%
  filter(
    grupo %in% c(
      "gender",
      "education",
      "age_cat"
    )
  )


dataset_mapa <- df_final_grupo %>%
  filter(
    year == 2021,
    grupo == "all",
    grupo2 == "all"
  )

