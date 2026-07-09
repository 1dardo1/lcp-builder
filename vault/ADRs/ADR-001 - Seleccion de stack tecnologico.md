---
tags: [adr, lcp-builder]
estado: Aceptada
---

# ADR-001: Selección de stack tecnológico para la aplicación de creación de archivos .lcp

**Estado:** Aceptada
**Fecha:** 2026-06-17
**Decisores:** Equipo de desarrollo

## Contexto

El proyecto consiste en construir una aplicación con interfaz gráfica para generar archivos `.lcp` (paquetes JSON comprimidos con una estructura específica) para la plataforma Comp/Con del TTRPG Lancer.

El proyecto tiene dos objetivos explícitos y de distinto peso:

1. **Objetivo principal (prioritario):** usar el proyecto como vehículo de aprendizaje de arquitectura de software, para construir una pieza de portfolio orientada a un futuro puesto como arquitecto de software.
2. **Objetivo secundario (no determinante):** entregar una herramienta útil al cliente/perfil objetivo, máster de Lancer sin conocimientos técnicos, que necesita generar contenido para sus partidas mediante formularios visuales en lugar de editar JSON a mano.

Se deja constancia explícita de que, en caso de conflicto entre ambos objetivos, el primero prevalece sobre el segundo. Esta es una decisión de producto consciente, no una limitación accidental.

### Restricciones identificadas

- **Sin servidor:** no hay presupuesto para mantener infraestructura backend. Cualquier solución que dependa de un servidor propio queda descartada.
- **Sin plazos:** no existe presión de tiempo de entrega, lo que permite priorizar el aprendizaje sobre la velocidad de desarrollo.
- **Spec-first:** la estructura del JSON ya está definida por la comunidad/desarrolladores de Comp/Con. El primer paso del proyecto (fuera del alcance de este ADR) es localizar y comprender esa especificación antes de diseñar el dominio.
- **No reutilización de soluciones existentes:** existen herramientas de comunidad para crear LCPs, pero se descarta deliberadamente estudiar su implementación para no contaminar el proceso de diseño propio. Se acepta esto como coste consciente a cambio de maximizar el aprendizaje del proceso de diseño desde cero.

### Requisitos de plataforma

Inicialmente se consideró un requisito amplio ("funcionar en Windows, Mac, Linux, Android e iOS"). Al contrastarlo con el perfil objetivo real, se concluyó que:

- **Requisito real del cliente:** Linux (escritorio, con posibilidad de cambiar de sistema en el futuro) y Android (móvil/tablet, no confirmado si la tablet es Android o iPad).
- **Requisito autoimpuesto de aprendizaje:** cobertura multiplataforma total (incluyendo iOS) e internacionalización (español/inglés), pese a que tanto el equipo de desarrollo como el cliente hablan español. Se mantiene como reto de aprendizaje personal, asumiendo la complejidad añadida de forma consciente.

**Verificación de viabilidad de iOS (sin coste para el alcance del proyecto):** se confirma que iOS ha sido una plataforma prioritaria para Flutter desde su diseño original, por lo que añadirla no implica forzar el framework fuera de su propósito. El equipo de desarrollo dispone de Mac, lo que cubre el requisito de hardware para compilar. Respecto al coste de distribución: el Programa de Desarrollador de Apple (de pago) no es obligatorio para el alcance de este proyecto. Sin cuenta de pago existen dos limitaciones: instalación directa vía cable/Xcode con caducidad de 7 días (la app deja de abrir y debe reinstalarse), y un máximo de 3 apps instaladas por este método en un mismo dispositivo. Dado que ningún cliente real del proyecto usa iOS, estas limitaciones afectan únicamente al equipo de desarrollo durante sus propias pruebas, no a la entrega del producto. Se acepta esta fricción como coste de desarrollo, no como bloqueante.

En consecuencia, se decide ampliar el alcance multiplataforma de "deseo de aprendizaje sin verificar" a "alcance confirmado y planificado": la aplicación se construirá para soportar Linux, Windows, macOS, Android, iPhone e iPad, entendiendo que las dos primeras (Linux, Android) responden a una necesidad real y las restantes a un objetivo de aprendizaje verificado como técnicamente viable sin coste bloqueante. La secuenciación de trabajo entre plataformas (qué se construye primero) se documenta por separado en ADR-002.

## Decisión

Se construirá la aplicación con **Flutter y Dart**, aplicando una arquitectura con el dominio (lógica de negocio) aislado de la capa de interfaz, siguiendo principios de Clean Architecture / Arquitectura Hexagonal.

## Opciones consideradas

### Descartadas en una fase exploratoria previa

| Opción | Motivo de descarte |
|---|---|
| Aplicación web | Requiere servidor para estar disponible; incompatible con la restricción de no mantener infraestructura. |
| Python | Soporte deficiente para desarrollo móvil nativo. |
| Electron | Resuelve bien escritorio multiplataforma (Node.js + motor de renderizado web), pero no tiene soporte para Android, que es un requisito real del cliente. |
| LibGDX | Es un motor de videojuegos. La aplicación es un conjunto de formularios y componentes de gestión de datos, no un juego; usarlo sería forzar una herramienta fuera de su propósito de diseño ("fighting the framework"). |
| .NET MAUI (C#) | Sin soporte oficial para Linux, que es la plataforma de escritorio real y confirmada del cliente. Descartada a pesar de ser la opción inicialmente preferida por afinidad con Java y transferencia directa al stack .NET usado en el trabajo actual del equipo de desarrollo: la viabilidad técnica frente al requisito real prevalece sobre la preferencia personal. |

### Opción A: Flutter (Dart)

| Dimensión | Valoración |
|---|---|
| Soporte Linux + Android | Confirmado y maduro. |
| Lenguaje | Dart. Nuevo para el equipo de desarrollo, pero de sintaxis orientada a objetos similar a Java/C#, con curva de aprendizaje reportada como corta para perfiles con ese bagaje. |
| Consistencia de UI | Motor de renderizado propio: la interfaz se ve y comporta igual en todas las plataformas. |
| Madurez del ecosistema | Alta, framework consolidado en producción multiplataforma. |
| Transferencia profesional directa | Ninguna (Dart no se usa en el puesto de trabajo actual del equipo de desarrollo). |
| Alineación con objetivo de aprendizaje | Permite centrar el esfuerzo en arquitectura y patrones de diseño (el objetivo prioritario) en vez de en dominar un paradigma de lenguaje nuevo y complejo. |

**Pros:** soporte confirmado de las dos plataformas reales del cliente, consistencia visual, curva de aprendizaje del lenguaje baja, libera capacidad mental para centrarse en arquitectura.
**Contras:** no hay transferencia directa al stack tecnológico del trabajo actual; Dart es un lenguaje de bajo uso fuera del ecosistema Flutter.

### Opción B: Tauri (Rust + WebView)

| Dimensión | Valoración |
|---|---|
| Soporte Linux + Android | Linux maduro. Soporte Android listo para producción solo desde Tauri 2.0 (relativamente reciente). |
| Lenguaje | Rust para el núcleo/lógica de negocio. Paradigma de gestión de memoria (ownership/borrow checker) sin equivalente en los lenguajes que el equipo de desarrollo conoce (Java, C#, Python, JS/TS). |
| Peso del binario | Más ligero que Electron, al no empaquetar un runtime completo de Node. |
| Madurez del ecosistema | Menor que Flutter, especialmente en el soporte móvil. |

**Pros:** binarios ligeros, lógica de negocio en un lenguaje de sistemas seguro.
**Contras:** curva de aprendizaje alta por el paradigma de Rust, que se sumaría a la curva de aprender arquitectura limpia al mismo tiempo; soporte Android más reciente y por tanto con menor recorrido probado.

## Trade-off analysis

La decisión se reduce a un único trade-off central: **rapidez de adopción del lenguaje vs. naturaleza del lenguaje en sí**.

Dart ofrece una curva de aprendizaje corta que permite al equipo de desarrollo dedicar su energía cognitiva al objetivo realmente prioritario del proyecto: practicar separación de dominio y capas de arquitectura. Rust, por el contrario, introduce un paradigma de gestión de memoria nuevo y exigente que competiría directamente por la misma energía cognitiva, desplazando el foco del aprendizaje de "arquitectura" a "sintaxis y paradigma de un lenguaje de sistemas".

Dado que el objetivo declarado y prioritario del proyecto es la arquitectura, no el dominio de un lenguaje de bajo nivel, Flutter/Dart es la opción que mejor sirve al objetivo real del proyecto, incluso renunciando a la transferencia profesional directa que sí ofrecía la alternativa de C#/.NET (descartada por motivos técnicos, no de preferencia).

## Consequences

- **Lo que se gana:** soporte confirmado para las plataformas reales del cliente (Linux + Android); capacidad de centrar el esfuerzo de aprendizaje en arquitectura de software sin la fricción añadida de un paradigma de lenguaje nuevo y complejo; consistencia visual entre plataformas gracias al motor de renderizado propio de Flutter; cobertura completa de escritorio y móvil (incluyendo iOS) sin coste económico bloqueante, gracias a que el equipo de desarrollo ya dispone del hardware (Mac) necesario.
- **Lo que se pierde:** la transferencia directa de conocimiento al stack .NET usado en el puesto de trabajo actual del equipo de desarrollo, que sí habría ofrecido C#, queda descartada como beneficio de este proyecto.
- **Fricción de desarrollo aceptada:** sin cuenta de pago del Programa de Desarrollador de Apple, las instalaciones de prueba en dispositivos iOS caducan cada 7 días y deben reinstalarse vía Xcode; máximo 3 apps por dispositivo con este método. Afecta solo al equipo de desarrollo durante pruebas, no a la entrega al cliente real (que no usa iOS).
- **Deuda de proceso aceptada:** se ha decidido no estudiar las implementaciones de soluciones de comunidad existentes para LCP, lo que implica asumir en solitario el riesgo de errores de diseño que esas soluciones ya podrían haber resuelto. Esto es una decisión consciente en favor del aprendizaje del proceso completo.

## Action items

1. [x] Localizar y validar la especificación oficial/comunitaria del formato `.lcp` antes de diseñar el dominio — resuelto con la Wiki de `massif-press/lancer-data` (https://github.com/massif-press/lancer-data/wiki), fuente citada en `vault/Modelo de Dominio/00 - Indice.md`.
2. [ ] Confirmar el sistema operativo real de la tablet del cliente (Android vs iPad); no bloquea el alcance, ya que ambas plataformas quedan cubiertas.
3. [x] Diseñar el modelo de dominio (entidades y lógica de negocio del LCP) de forma aislada de cualquier dependencia de Flutter, como primer ejercicio de separación de capas — completo en `vault/Modelo de Dominio/` (19 secciones) e implementado en `app/lib/domain/` (27 archivos Dart).
4. [x] Documentado como ADR-002 el orden de desarrollo entre plataformas (común → Linux/Android → iOS/Windows/macOS).
