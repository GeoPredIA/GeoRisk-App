# GeoPredIA - Evaluación Inteligente de Riesgos Geológicos y Socioambientales

##  Contexto y Problema

Perú es uno de los principales productores mundiales de cobre, plata y zinc. Sin embargo, la exploración y el desarrollo de nuevos proyectos mineros enfrentan riesgos que van más allá del potencial geológico. Factores ambientales y sociales pueden afectar la viabilidad de una zona, generando retrasos, mayores costos y potenciales conflictos.

La evaluación tradicional se realiza de manera fragmentada. **GeoPredIA** soluciona esto integrando analítica avanzada, flujos de automatización y una experiencia de usuario centralizada desarrollada en **Flutter & Dart**.

## Solución y Características Principales

El prototipo funcional implementado incluye las siguientes vistas y capacidades clave en la interfaz local con Flutter:

1. **Panorama (Dashboard de Riesgos):** Visualización global del portafolio, cálculo multidimensional (Riesgo Geológico, Ambiental y Social en escala de 0 a 100), KPIs en tiempo real y simulación de escenarios *"¿Qué pasa si cambian los pesos?"*.

2. **Multiagentes (Análisis Multiperspectiva):** Desglose del análisis por roles (Especialista Geológico, Especialista Ambiental y Especialista Social) coordinados por reglas o modelos de lenguaje.

3. **Monitoreo IoT:** Señales ambientales y telemetría en tiempo real (temperatura del aire, humedad, sensores de agua) conectadas para complementar la evaluación de campo.

4. **Revisión Humana:** Bandeja de pendientes y registro formal de decisiones (Aprobar, Observar, Rechazar) con trazabilidad completa de quién revisó y el sustento correspondiente.

5. **Asistente (Conversacional / SAP Joule):** Simulación de interfaz conversacional para consultar en lenguaje natural factores de riesgo, resúmenes y datos faltantes de cualquier zona de exploración.

6. **Dataset HANA:** Acceso estructurado a las fuentes base y variables del reto.

## 🛠️ Arquitectura Técnica SAP & Stack Tecnológico

La solución está diseñada sobre una arquitectura empresarial híbrida:

* **Capa de Datos:** `SAP HANA Cloud` — Fuente central del dataset sintético con variables geológicas, ambientales, sociales e históricas.

* **Capa Analítica:** `SAP Analytics Cloud (SAC)` — Scoring, KPIs de riesgo, rankings y comparaciones avanzadas.

* **Capa de Proceso:** `SAP Build Process Automation` — Flujos de revisión, formularios de aprobación y trazabilidad de decisiones humanas.

* **Capa de Experiencia e IA:** `SAP Build Work Zone (standard edition)` y `SAP Joule / Joule Studio` (asistente conversacional).

* **Frontend / Prototipo Interactivo:** Desarrollado íntegramente en **Flutter & Dart** para la ejecución local multiplataforma de demostración.

## Cómo Ejecutar el Proyecto Localmente

La configuración SAP usada por esta app está documentada en
[`SAP_INTEGRATIONS.md`](SAP_INTEGRATIONS.md). La app consume la API BTP existente
y conserva el dataset empaquetado como respaldo para demos sin conexión.

Asegúrate de tener instalado [Flutter](https://flutter.dev/?utm_source=gemini) en tu entorno de desarrollo.

1. Clona el repositorio:
   ```bash
   git clone https://github.com/tu-usuario/GeoPredIA.git
   cd GeoPredIA
   ```

2. Instala las dependencias del proyecto:
   ```bash
   flutter pub get
   ```

3. Ejecuta la aplicación en tu plataforma preferida (Web, Escritorio o Móvil):
   ```bash
   flutter run -d chrome
   ```

## 👥 Equipo de Contribuyentes

Proyecto desarrollado para el hackatón **HKT-2026-T2** por el siguiente equipo:

* **Alejandro Samir Choquehuanca Vasquez** — Ingeniería de Software, *Universidad Peruana de Ciencias Aplicadas (UPC)*
* **Walter Junior Navarro Collao** — Ingeniería Informática, *Pontificia Universidad Católica del Perú (PUCP)*
* **Rodrigo Aaron Colonio Soto** — Ciencias de la Computación, *Universidad Peruana de Ciencias Aplicadas (UPC)*
* **Eduardo Jesús Osorio Ramírez** — Ingeniería de Software, *Universidad Peruana de Ciencias Aplicadas (UPC)*

---
