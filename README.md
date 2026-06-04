# Inclusión financiera y digitalización: análisis global

## Descripción

Proyecto desarrollado para la asignatura **Visualización de Datos** de la **Universitat Oberta de Catalunya (UOC)**.

El objetivo del proyecto es analizar la relación entre la inclusión financiera, la digitalización, el nivel de renta y diferentes características sociodemográficas a escala global. A través de una narrativa visual interactiva, se exploran las desigualdades geográficas y sociales en el acceso a servicios financieros y se estudian los factores que contribuyen a explicarlas.

La visualización ha sido desarrollada utilizando Tableau Public y publicada mediante GitHub Pages.

---

## Preguntas de investigación

El proyecto busca responder a las siguientes preguntas:

1. ¿Dónde existe mayor inclusión financiera?
2. ¿Qué relación existe entre la digitalización y la inclusión financiera?
3. ¿Existen diferencias significativas entre países según su nivel de renta?
4. ¿Qué colectivos presentan mayor exclusión financiera?
5. ¿Cómo influyen la renta per cápita y la conectividad digital en el acceso a servicios financieros?
6. ¿Cómo han evolucionado la inclusión financiera y la conectividad digital durante la última década?

---

## Conjunto de datos

Los datos utilizados proceden principalmente de:

* Global Findex Database (Banco Mundial)
* World Development Indicators (Banco Mundial)

Se han utilizado indicadores relacionados con:

* Inclusión financiera
* Uso de Internet
* Pagos digitales
* Renta per cápita
* Nivel de renta de los países
* Género
* Edad
* Nivel educativo

Los datos fueron procesados y transformados mediante R para generar las tablas utilizadas posteriormente en Tableau.

---

## Tecnologías utilizadas

* R
* Tableau Public
* HTML5
* CSS3
* GitHub Pages

---

## Estructura del proyecto

```text
.
├── index.html
├── style.css
├── Data/
├── Pract1_tratamiento.R
├── README.md
└── LICENSE
```

---

## Visualización interactiva

Visualización publicada en GitHub Pages:

[https://nataliaayusocastillo.github.io/inclusion-financiera-global/]

Visualizaciones desarrolladas con Tableau Public:

[Enlace a Tableau Public](https://public.tableau.com/app/profile/natalia.ayuso.castillo/viz/PRACT2_17804361907030/]

---

## Aspectos de diseño

El proyecto aplica diversos principios de visualización de datos estudiados durante la asignatura:

* Mantra de Shneiderman: overview first, zoom and filter, details on demand.
* Principios Gestalt de proximidad, similitud y continuidad.
* Reducción de elementos no informativos y mejora del ratio tinta-dato.
* Uso de colores consistentes y accesibles.
* Integración de elementos interactivos para favorecer la exploración de los datos.

---

## Principales hallazgos

* Existe una relación positiva entre digitalización e inclusión financiera.
* Los países de renta alta presentan niveles significativamente superiores de inclusión financiera.
* Persisten desigualdades asociadas al género, la edad y especialmente al nivel educativo.
* La conectividad digital parece desempeñar un papel relevante en la expansión del acceso a servicios financieros.
* La inclusión financiera ha mejorado de forma generalizada entre 2011 y 2024, aunque continúan existiendo diferencias regionales importantes.

---

## Autor

Natalia Ayuso Castillo

Máster Universitario de Ciencia de Datos (UOC)

Asignatura: Visualización de Datos

Curso 2025–2026

---

## Licencia

Este proyecto se distribuye bajo licencia MIT.
