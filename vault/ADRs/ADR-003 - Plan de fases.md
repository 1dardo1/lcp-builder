---
tags: [adr, lcp-builder]
estado: Propuesta
---

# ADR-003: Plan preliminar de fases (secuenciación de funcionalidades dentro de cada plataforma)

**Estado:** Propuesta (los cuatro puntos de la decisión quedan cerrados; pendiente completar Trade-off analysis y Consequences)
**Fecha:** 2026-06-17
**Decisores:** Equipo de desarrollo

## Contexto

El ADR-002 estableció la secuenciación entre *plataformas* (núcleo común → Linux/Android → Windows/macOS/iPhone/iPad), pero dejó explícitamente fuera de su alcance una pregunta distinta: el orden y alcance detallado de las *funcionalidades* a implementar dentro de cada fase.

Esta distinción surgió al discutir los criterios de "hecho" de la fase 2 del ADR-002. Se identificó que funcionalidades como importar un `.lcp` ya existente no forman parte del flujo mínimo de creación y exportación, sino de una iteración posterior — pero en lugar de documentar esa exclusión como una nota aislada dentro del ADR-002, se decidió tratarla de forma sistemática en un documento propio, ya que afecta a la planificación completa del proyecto, no solo a un criterio puntual.

Se ha decidido que este plan de fases siga un **enfoque de cascada**: cada fase tiene un alcance cerrado y definido de antemano, y las funcionalidades pendientes de fases futuras no se mencionan como "exclusiones" dentro de la fase actual — simplemente se abordan cuando les corresponde, según el propio orden de fases que defina este documento.

## Decisión

### 1. Orden de funcionalidades dentro de la fase Linux/Android

Más allá del flujo mínimo de creación/exportación ya cubierto por los criterios de "hecho" del ADR-002, la fase Linux/Android desarrollará las siguientes funcionalidades en este orden:

1. **Crear `.lcp`** (flujo mínimo ya definido en el ADR-002). Es la funcionalidad de mayor prioridad, al ser la que más necesita el cliente para empezar a generar contenido utilizable en sus partidas.
2. **Mostrar/localizar contenido de un `.lcp` o JSON**. Al analizar el caso de uso de importar, se identificó que "mostrar el contenido para localizar un elemento concreto" no es una funcionalidad aislada, sino una **pieza común** compartida por dos flujos distintos: el de solo consultar (por ejemplo, cuando el cliente busca entre varios `.lcp` cuál contiene un arma concreta para usarla en Comp/Con, sin intención de modificar nada) y el de editar (donde es el paso previo necesario para seleccionar qué elemento modificar). Se decide implementarla justo después de crear por tres motivos, ninguno suficiente por sí solo pero sólidos en conjunto: (a) es la base de la que dependen tanto consultar como editar; (b) su desarrollo es más corto que el de editar, por lo que no retrasa significativamente la llegada de esta última; (c) proporciona al propio equipo de desarrollo una herramienta de verificación manual del contenido de los `.lcp` generados por "crear", sustituyendo la necesidad de descomprimirlos a mano o de pasarlos por la aplicación web de Comp/Con para comprobar que se generaron correctamente.
3. **Editar y eliminar un `.lcp` existente**, apoyándose en la pieza de mostrar/localizar ya construida en el punto anterior. Eliminar se contempla como una opción dentro del flujo de edición, no como una funcionalidad independiente. El flujo, desde la perspectiva del cliente, es: abrir la app → ir a la opción de modificar → seleccionar el archivo (`.lcp` o JSON suelto) → ver el contenido para localizar el elemento deseado → seleccionarlo → formulario precargado con los datos existentes (reutilizando el formulario de creación) → editar o eliminar → al finalizar, se exporta un `.lcp` actualizado.
4. **Mantenimiento y peticiones adicionales del cliente**, como punto abierto y continuo a lo largo de toda la fase.

**Nota pendiente de verificación** (no bloquea el orden anterior, pero condiciona el alcance real del punto 3): el flujo de importar contempla la posibilidad de que el cliente cargue un JSON suelto obtenido de internet, no solo un `.lcp` generado por la propia aplicación. Esto exige validar que la estructura del archivo importado es correcta antes de procesarlo, ya que un archivo así no tiene por qué cumplir la estructura esperada (a diferencia de un `.lcp` propio, que sí la cumple por construcción). Se establece la siguiente jerarquía de fuentes para resolver esa validación, en orden de preferencia: (1) especificación oficial/comunitaria escrita del formato `.lcp`, si define una forma explícita de validar estructura; (2) librería oficial de validación publicada por los desarrolladores de Lancer, si existe; (3) como último recurso, inferencia de la estructura por observación de archivos `.lcp` ya conocidos como correctos, asumiendo el riesgo de no capturar casos límite (por ejemplo, campos opcionales que en los ejemplos observados siempre tienen valor). Esta jerarquía no se puede aplicar todavía en la práctica porque el Action Item 1 del ADR-001 (localizar la especificación oficial del LCP) sigue pendiente; se resolverá en detalle cuando se complete esa investigación.

### 2. Criterios de entrada de una funcionalidad nueva en una fase

Cuando surge una funcionalidad nueva (por ejemplo, a partir del feedback del cliente) y no estaba prevista en el orden anterior, se evalúa con los siguientes criterios, en este orden:

1. **¿Ya existe algo equivalente?** Antes de considerar desarrollo nuevo, se comprueba si la necesidad ya queda cubierta por una funcionalidad existente, aunque sea mediante un atajo de uso. Por ejemplo, "duplicar un `.lcp`" no requiere desarrollo nuevo: se resuelve editando el `.lcp` original y guardando el resultado con un nombre distinto al finalizar, conservando así el original y el duplicado modificado.
2. **Dependencia de adapter de plataforma.** Si la lógica de la funcionalidad vive enteramente en el dominio (independiente de plataforma, sin tocar almacenamiento, cámara, permisos o drag-and-drop), su entrada en una fase no depende de qué plataforma esté activa en ese momento. Si, por el contrario, requiere modificar o crear un adapter específico de plataforma, se valora el riesgo de tener que rehacer ese trabajo al llegar a la fase de esa plataforma más adelante (el mismo riesgo de trabajo desechable ya identificado en el ADR-002 como motivo para posponer Windows/macOS/iPhone/iPad).
3. **Coste de desarrollo frente a beneficio.**
4. **Tipo de beneficio que aporta**, distinguiendo entre:
   - **Valor de producto**: beneficio directo para el cliente en el uso de la aplicación.
   - **Valor de producción**: beneficio para el propio proceso de desarrollo (por ejemplo, una herramienta que facilita las pruebas o acelera iteraciones futuras), sin beneficio directo inmediato para el cliente.

   En este proyecto, dado que el ADR-001 fija que no hay plazos de entrega y que el objetivo prioritario es el aprendizaje de arquitectura (no la entrega rápida al cliente), el desempate por defecto favorece el **valor de producción** sobre el valor de producto cuando ambos tipos de valor son comparables en magnitud. Esta prioridad podría invertirse si en el futuro surgiera una urgencia real y confirmada del cliente, pero no se asume esa urgencia de antemano sin verificarla.

   Caso particular a vigilar: si una funcionalidad aporta únicamente valor de producción y se pospone repetidamente "hasta el final" del proyecto, en la práctica equivale a descartarla, ya que una vez terminada la producción no queda actividad de desarrollo que pueda beneficiarse de ella. Posponer indefinidamente un beneficio de producción es, de facto, descartarlo.

### 3. Relación entre el plan de fases y el feedback del cliente

El feedback recogido en las reuniones descritas en el ADR-002 puede modificar el orden de fases planificado de dos formas distintas, según se trate de una corrección sobre algo ya construido o de una petición de funcionalidad nueva.

**Corrección sobre algo ya construido ("perfeccionar").** Por regla general, el feedback sobre una funcionalidad ya entregada se prioriza frente a continuar con el desarrollo de funcionalidad nueva. Esta regla general se apoya en cuatro motivos:

1. **Coste de arrastre**: si el problema vive en una pieza compartida entre varios flujos (por ejemplo, un tamaño de letra reutilizado en las pantallas de crear, mostrar y editar), posponer la corrección obliga a repetir el mismo arreglo cada vez que se construya una nueva pantalla que comparta esa pieza, multiplicando el coste total.
2. **Severidad de impacto en el uso**, evaluada en un espectro y no como una decisión binaria: un problema que bloquea por completo el uso de una funcionalidad se prioriza por encima de un inconveniente molesto pero no bloqueante, que a su vez se prioriza por encima de una preferencia subjetiva o estética sin impacto funcional.
3. **Incertidumbre sobre el propio coste de arrastre**: no siempre es posible predecir con certeza, en el momento de recibir el feedback, si un problema concreto va a repetirse en piezas futuras o no. Ante esa incertidumbre, se prefiere corregir pronto en lugar de esperar a tener la confirmación, asumiendo el riesgo de haber corregido algo que en última instancia no se habría repetido.
4. **Coste de tiempo comparativamente menor**: perfeccionar algo ya construido suele requerir menos tiempo que desarrollar una funcionalidad completa nueva, lo que refuerza la conveniencia de resolverlo antes de seguir avanzando.

**Petición de funcionalidad nueva.** Se evalúa con los mismos criterios ya definidos en el punto 2 de esta decisión (¿ya existe algo equivalente?, dependencia de adapter de plataforma, coste de desarrollo frente a beneficio, tipo de valor aportado), añadiendo como información adicional la prioridad que el propio cliente comunique sobre la petición.

**Papel de la opinión del cliente.** La opinión directa del cliente sobre qué priorizar no se trata como primer filtro de decisión, sino como **criterio de desempate**, reservado para los casos en los que, tras aplicar el resto de criterios de este documento, dos opciones quedan empatadas o muy similares en coste y beneficio estimado. En esos casos, el cliente puede aportar información sobre su uso real de la aplicación que el equipo de desarrollo no puede deducir desde fuera (por ejemplo, ante un texto pequeño en pantalla, si el cliente puede compensarlo haciendo zoom o si, por el contrario, fuerza la vista sin esa posibilidad). Cuando el desacuerdo es entre tipos de decisión sobre los que el cliente no tiene base para opinar (por ejemplo, perfeccionar una funcionalidad existente frente a empezar una nueva), no se le consulta, ya que el criterio se resuelve con la información ya disponible para el equipo de desarrollo.

**Disciplina de tests sin excepciones.** Cualquier corrección atendida fuera de su orden original por motivo de feedback prioritario del cliente sigue sujeta a la misma condición bloqueante de tests unitarios y de aceptación fijada en el ADR-002 para el cierre de toda iteración. La urgencia del feedback no exime de esta condición.

### 4. Nivel de detalle para las fases lejanas (Windows/macOS/iPhone/iPad)

El nivel de detalle alcanzado para la fase Linux/Android en el punto 1 de esta decisión (orden concreto de funcionalidades, flujo paso a paso desde la perspectiva del cliente) no es replicable hoy para las fases lejanas, por dos incertidumbres distintas:

1. **El contenido final de la fase Linux/Android todavía no está cerrado.** Tal y como se establece en el punto 3 de esta decisión, ese contenido se modificará con el feedback del cliente y con las correcciones priorizadas durante el desarrollo. Cualquier plan detallado para las fases lejanas construido hoy se apoyaría sobre una base (el resultado final de Linux/Android, que actúa como punto de partida de Windows/macOS y de Android/iOS respectivamente) que aún no existe en su forma definitiva.
2. **La investigación de los paquetes/plugins de Flutter para cada categoría de adapter** (almacenamiento, selector nativo, cámara, gestión de permisos, drag-and-drop) **no se ha realizado todavía para Windows, macOS ni iOS.** El Action Item correspondiente del ADR-002 se limitó explícitamente a Linux y Android; no existe aún un Action Item equivalente para el resto de plataformas.

Por estos dos motivos, el contenido de esta sección se limita a relaciones y principios que se mantienen estables independientemente de cómo se resuelvan ambas incertidumbres, en lugar de a una secuencia detallada de funcionalidades:

- **Relación de base entre plataformas hermanas:** Linux actúa como punto de partida para Windows y macOS (entornos de escritorio); Android actúa como punto de partida para iPhone e iPad (entornos móviles/táctiles). Esta relación es estable con independencia de cuál sea el contenido final de la base (puede cambiar qué funcionalidades incluye) y con independencia de qué tan distinto resulte ser el adapter técnico concreto de cada plataforma (algo que, como ya se estableció en el ADR-002, se espera que varíe entre plataformas para ciertas categorías de adapter, sin que eso invalide la relación de base).
- **Orden interno entre las cuatro plataformas lejanas:** Windows → macOS → iPad → iPhone. Este orden se basa en la disponibilidad real de hardware del equipo de desarrollo durante el ciclo de desarrollo: Windows y Mac están disponibles de forma continua; iPad e iPhone solo están disponibles puntualmente, reservados para una verificación final, por lo que el desarrollo y las pruebas del día a día en esas dos últimas plataformas se apoyarán en emulador.
- **La condición de tests (unitarios y al menos un test de aceptación por iteración) sigue aplicando sin excepción**, igual que en la fase Linux/Android, conforme a lo ya fijado en el ADR-002 como condición bloqueante para todo el proyecto.

Cualquier detalle técnico más fino —paquetes concretos de Flutter por plataforma, fiabilidad de los emuladores de iPad/iPhone para reproducir flujos de permisos y cámara de forma equivalente a un dispositivo real, orden detallado de funcionalidades dentro de cada una de estas cuatro plataformas— queda explícitamente diferido hasta que comience el desarrollo de cada plataforma lejana, en lugar de fijarse hoy sobre datos pendientes de verificar.

## Pendiente de definir en próxima sesión

- (Recordatorio de dependencia externa, no exclusivo de este ADR) Action Item 1 del ADR-001 sigue pendiente: localizar la especificación oficial del formato `.lcp`. Condiciona el detalle final de la validación de estructura mencionada en el punto 1 de la Decisión.
- (Nuevo, derivado de este ADR) Investigar los paquetes/plugins de Flutter para Windows, macOS e iOS, equivalente al Action Item 2 del ADR-002 ya realizado para Linux/Android.

## Action items

1. [x] Definir el listado y orden de funcionalidades de la fase de Linux/Android, empezando por la ubicación de "importar `.lcp`" en esa secuencia.
2. [x] Definir los criterios de entrada de nuevas funcionalidades en una fase u otra.
3. [x] Definir la relación entre el plan de fases y el feedback del cliente.
4. [x] Definir el nivel de detalle esperado para las fases lejanas (Windows/macOS/iPhone/iPad).
5. [ ] Completar las secciones de Trade-off analysis y Consequences de este ADR.
6. [ ] Investigar los paquetes/plugins de Flutter para Windows, macOS e iOS (documento aparte o ampliación del ADR-002).
