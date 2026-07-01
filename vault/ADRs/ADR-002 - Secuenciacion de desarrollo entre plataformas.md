---
tags: [adr, lcp-builder]
estado: Aceptada
---

# ADR-002: Secuenciación del desarrollo entre plataformas

**Estado:** Aceptada (los cuatro puntos originalmente pendientes quedan cerrados; la investigación de paquetes/plugins concretos de Flutter y el plan de fases se tratan en documentos/trabajo aparte, fuera del alcance de este ADR)
**Fecha:** 2026-06-17
**Decisores:** Equipo de desarrollo

## Contexto

El ADR-001 estableció que la aplicación se construirá con Flutter/Dart, con soporte confirmado para Linux, Windows, macOS, Android, iPhone e iPad. De esas plataformas, solo Linux y Android responden a una necesidad real del cliente; el resto responde al objetivo de aprendizaje del equipo de desarrollo.

Esta diferencia de prioridad entre plataformas no debería resolverse desarrollándolas todas en paralelo desde el primer día, sino decidiendo conscientemente un orden de trabajo. Esta decisión se apoya directamente en la arquitectura elegida en el ADR-001 (Clean Architecture / Hexagonal): al existir un dominio aislado de la interfaz, es posible construir primero la lógica y la interfaz compartida, y resolver después las particularidades de cada plataforma mediante adapters específicos.

Un motivo adicional para esta secuenciación es poder disponer cuanto antes de una versión utilizable por el cliente real, que permita empezar a recoger feedback temprano sobre la herramienta, en lugar de esperar a tener las seis plataformas completas.

## Decisión (borrador inicial)

Se desarrollará en el siguiente orden:

1. **Núcleo común:** dominio, lógica de negocio y la parte de interfaz que no depende de particularidades de plataforma.
2. **Plataformas de necesidad real:** Linux y Android, hasta tener una versión utilizable por el cliente y poder empezar a recoger su feedback.
3. **Plataformas de aprendizaje:** Windows, macOS, iPhone e iPad, añadidas y validadas en una fase posterior, sin bloquear el flujo de trabajo principal.

## Adapters de plataforma: categorías identificadas

Al analizar qué necesita el dominio del mundo exterior (sistema de archivos, cámara, etc.), se identifican cuatro categorías de necesidades, no todas con el mismo coste de implementación. El dominio, en todos los casos, permanece ajeno a estas diferencias: solo espera recibir rutas de archivo (de un `.lcp`, de una imagen) o, en caso de fallo, una señal de error que pueda interpretar sin conocer la causa concreta de plataforma.

### Categoría 1: Adapters con implementación distinta por plataforma

Funcionalidades que existen conceptualmente en ambas plataformas, pero cuya implementación técnica depende de APIs propias de cada sistema operativo, por lo que requieren un adapter específico por plataforma.

- **Almacenamiento/sistema de archivos** (importar y exportar `.lcp`): Linux gestiona el acceso a archivos de forma abierta (el usuario navega libremente por el sistema); Android lo gestiona de forma más restrictiva, típicamente a través de selectores controlados por el sistema operativo.
- **Acceso a la cámara** (captura de imágenes para los formularios, en plataformas donde tiene sentido): la foto se captura en memoria/temporal y el adapter es responsable de persistirla como archivo antes de exponerla al dominio en la misma forma (ruta) que cualquier otra imagen seleccionada manualmente.

### Categoría 2: Capacidades ya resueltas de forma multiplataforma por una librería Dart pura

No requieren un adapter por plataforma porque la lógica ya es independiente del sistema operativo subyacente.

- **Compresión/descompresión del paquete `.lcp`**: cubierta por el paquete `archive`, implementado íntegramente en Dart, por lo que se comporta igual en cualquier plataforma sin necesidad de adaptación.

### Categoría 3: Funcionalidades de UI presentes en una plataforma sin equivalente funcional en otra

No son una variación de la misma función, sino una función que directamente no aplica en alguna plataforma.

- **Arrastrar y soltar (drag-and-drop) de archivos/carpetas**: tiene sentido en Linux de escritorio (el cliente puede arrastrar una carpeta desde el explorador de archivos del sistema hasta la app). No tiene equivalente funcional en Android, donde no existe un explorador de archivos del sistema con el que interactuar de esa forma. El adapter de escritorio ofrecerá ambas vías (arrastrar o explorar); el adapter de Android ofrecerá únicamente la vía de explorar, con su propio selector nativo (no se comparte implementación entre ambos, aunque cumplan una función equivalente desde el punto de vista del usuario).
- **Captura de fotos desde el formulario**: se valora como una funcionalidad propia de dispositivos móviles, dado que el uso de webcam para este fin en entornos de escritorio se considera poco frecuente. No se descarta de forma permanente: se reevaluará si el feedback de los clientes en escritorio señala esta necesidad tras probar la aplicación.

### Categoría 4: Conceptos propios de una plataforma sin equivalente en otra, relacionados con el sistema operativo

- **Gestión de permisos en tiempo de ejecución**: Android (y, previsiblemente, iOS) requiere solicitar y gestionar la concesión o denegación de permisos en tiempo de ejecución (por ejemplo, acceso a archivos o a la cámara) — un concepto sin equivalente como tal en Linux de escritorio, donde estas acciones no requieren una autorización explícita gestionada por la aplicación. Cuando un permiso es denegado, es responsabilidad del adapter de la plataforma correspondiente capturar esa denegación y comunicar el fallo al dominio sin que este conozca la causa concreta (queda pendiente, fuera del alcance de este ADR, decidir el mecanismo exacto de propagación de errores hacia el dominio — p. ej. excepciones frente a tipos de retorno explícitos de éxito/fallo).

## Criterios de "hecho" para cerrar la fase 2 (núcleo común + Linux/Android)

La fase 2 se considera completa cuando se cumplen, a la vez, los siguientes criterios:

1. **Flujo completo de creación funcionando**: abrir la app → seleccionar tipo de dispositivo a crear (por ejemplo, un arma o un sistema) → rellenar el formulario correspondiente → preguntar si se quiere crear otro dispositivo y repetir el ciclo, o finalizar → al finalizar, dar nombre a la carpeta → la aplicación comprime el contenido y lo guarda como `.lcp` en la ubicación correspondiente.
2. **Disponible en Android y Linux**. Si es necesario priorizar el desarrollo de una de las dos plataformas en algún momento dentro de esta fase, se priorizará Android, por ser el dispositivo al que el cliente tiene actualmente más acceso para hacer pruebas con comodidad.
3. **Manejo de errores comunicado al cliente**: ante cualquier fallo durante el proceso (por ejemplo, permiso de almacenamiento denegado, espacio insuficiente en el dispositivo), el cliente debe recibir información comprensible y accionable sobre qué ha ocurrido y, si es posible, cómo solucionarlo — no es suficiente con que la aplicación no se cierre inesperadamente.
4. **Verificación doble antes de entregar al cliente**: el flujo debe superar sus tests automatizados (ver punto 5) **y**, además, haber sido probado manualmente por el equipo de desarrollo en al menos un dispositivo Android real y un dispositivo Linux real. Ninguna de las dos verificaciones sustituye a la otra.
5. **Cobertura de tests como condición de cierre de cada iteración**: cada iteración de desarrollo debe incluir tests unitarios (tanto del dominio como de los adapters) y al menos un test de aceptación (end-to-end, validando el flujo desde la perspectiva del cliente) para la funcionalidad añadida en esa iteración. Si una iteración no cumple esto, no se considera completa — esta condición aplica a todo el proyecto, no solo a la fase 2, y es bloqueante.

La funcionalidad de importar un `.lcp` ya existente no se trata aquí como una exclusión de esta fase: el orden y alcance detallado de las funcionalidades a implementar dentro de cada fase se documentará en un ADR aparte (plan de fases), siguiendo un enfoque de cascada.

## Proceso de recogida de feedback del cliente

Dado que el cliente no puede comprometerse a realizar pruebas con una cadencia regular, el desarrollo no se detiene a la espera de su disponibilidad: se continúa avanzando en iteraciones según el plan de fases.

- **Entrega de versiones**: al completar cada iteración, se le hace llegar al cliente un archivo APK por mensajería para que la instale en su propio dispositivo Android. El cliente ya tiene experiencia instalando APKs por este medio, por lo que no se considera un riesgo a mitigar.
- **Cadencia de reuniones**: no se fija un calendario regular. La frecuencia con la que se propone una reunión depende del ritmo real de desarrollo (cada vez que hay avances significativos que mostrar), no de un plazo predefinido — coherente con la ausencia de plazos del proyecto establecida en el ADR-001.
- **Condición previa a la reunión**: se le pide al cliente (no se le exige) que pruebe la versión entregada antes de la reunión. Si llega a la reunión sin haberla probado, la reunión se cancela o reagenda, ya que sin esa preparación previa pierde gran parte de su utilidad.
- **Estructura de la reunión**: primero se recoge el feedback que el cliente trae ya preparado a partir de su uso previo. Después, se le observa utilizando la aplicación en directo, delante del equipo de desarrollo, para identificar puntos de dolor que el propio cliente podría no haber sabido verbalizar de antemano. Por último, se discute con él la importancia relativa de las distintas funcionalidades existentes o ausentes.
- **Mecanismo concreto de envío del APK** (más allá de "por mensajería") y el detalle de cómo se gestiona la distribución a futuro quedan fuera del alcance de este ADR, al ser una cuestión de despliegue/distribución y no de secuenciación de plataformas.

## Trade-off analysis

La decisión de posponer Windows, macOS, iPhone e iPad hasta después de validar Linux y Android con el cliente responde a un trade-off entre **velocidad y solidez de cada iteración a corto plazo** frente a **certeza total sobre el coste de añadir el resto de plataformas más adelante**.

### Qué se gana

1. **Velocidad por iteración**: mantener solo dos plataformas activas a la vez (en lugar de seis) reduce el alcance de verificación manual y de tests por ciclo, descrito en los criterios de "hecho" de este mismo ADR, haciendo cada iteración más rápida de cerrar.
2. **Evitar trabajo desechable**: el feedback real del cliente tras probar Linux/Android puede traducirse en cambios de alcance (funcionalidades pedidas o descartadas). Posponer el resto de plataformas evita construir esas mismas piezas seis veces para después tener que deshacer o rehacer trabajo en todas ellas.
3. **Una base más sólida antes de escalar**: el resto de plataformas se desarrollará apoyándose en un dominio y unos adapters ya validados en producción real (con el cliente), no sobre una hipótesis sin probar.
4. **Cobertura temprana de la diferencia escritorio/móvil**: al elegir Linux (escritorio) y Android (móvil) como las dos primeras plataformas, en lugar de dos plataformas del mismo tipo, se capturan pronto las diferencias de tamaño de pantalla e interacción (ratón/teclado frente a táctil), en lugar de descubrirlas tarde al llegar a macOS/iOS.
5. **Base de interfaz reutilizable**: Linux actúa como punto de partida para Windows y macOS (entornos de escritorio); Android actúa como punto de partida para iPhone e iPad (entornos móviles/táctiles). Se hará lo posible por reutilizar la interfaz ya construida, aunque queda pendiente confirmar en su momento si se reutiliza sin cambios o requiere ajustes.

### Qué se pierde / riesgo que se acepta

1. **Fricción de pruebas en iOS** (ya documentada en el ADR-001): sin cuenta de pago del Programa de Desarrollador de Apple, las instalaciones de prueba caducan cada 7 días y deben reinstalarse vía Xcode. Afecta solo al equipo de desarrollo durante sus propias pruebas, no a la entrega al cliente real.
2. **La protección de la arquitectura (dominio + adapters) no es total**: el patrón de dominio aislado y adapters de infraestructura (almacenamiento, cámara, permisos) protege la lógica de negocio frente a cambios de plataforma, pero **no protege necesariamente la capa de interfaz de usuario**, que es una tercera capa distinta de ambas. Incluso entre dos plataformas de escritorio (Windows y macOS), partes de la interfaz podrían necesitar ser distintas pese a la intención de reutilizarla. La magnitud real de este trabajo de adaptación de UI es desconocida hoy, precisamente porque se ha decidido posponer esa investigación hasta que llegue el turno de esas plataformas.
3. **Retraso en validar el reto de aprendizaje declarado en el ADR-001**: dado que el objetivo de cobertura multiplataforma total (incluyendo iOS) e internacionalización es un objetivo de aprendizaje autoimpuesto y no una necesidad real del cliente, posponerlo implica también posponer la validación de ese aprendizaje hasta una fase posterior del proyecto, sin plazos que lo acoten.

## Consequences

- **Lo que se gana**: iteraciones de fase 2 más rápidas y manejables (menos plataformas activas a la vez); menor riesgo de trabajo desechable ante cambios de alcance pedidos por el cliente; una base de dominio y adapters ya validada con el cliente real antes de escalar al resto de plataformas; cobertura temprana de los dos paradigmas de interacción principales (escritorio y móvil), que sirve de punto de partida para el resto.
- **Lo que se pierde o se pospone**: la validación del reto de aprendizaje de cobertura multiplataforma total e internacionalización, declarado en el ADR-001 como objetivo autoimpuesto, queda diferida sin fecha concreta. La fricción ya conocida de pruebas en iOS (caducidad de 7 días, máximo 3 apps) sigue aceptada como coste de desarrollo, no de entrega.
- **Riesgo aceptado sin mitigar todavía**: la reutilización de la interfaz de usuario entre plataformas del mismo tipo (escritorio o móvil) es una intención, no una garantía. El patrón de arquitectura elegido (dominio + adapters) no cubre este riesgo, ya que la interfaz vive en una capa distinta de ambos. Se confirmará el alcance real de reutilización o adaptación necesaria cuando llegue el turno de cada plataforma pospuesta, no antes.

## Pendiente de definir en próxima sesión

- Qué paquetes/plugins concretos de Flutter cubren cada necesidad de adapter identificada en las categorías 1 y 4 (almacenamiento de archivos, selector nativo, cámara, gestión de permisos, drag-and-drop de escritorio), y qué diferencias prácticas existen entre ellos.
- (Fuera de este ADR, pendiente como documento aparte) Plan preliminar de fases: orden detallado de funcionalidades a implementar dentro de cada plataforma, siguiendo un enfoque de cascada.

## Action items

1. [x] Identificar las categorías de necesidades de adapter por plataforma (este ADR).
2. [ ] Investigar los paquetes/plugins específicos de Flutter que cubren cada categoría para Linux y Android.
3. [x] Definir criterios de aceptación de la primera versión utilizable por el cliente.
4. [x] Definir cómo y cuándo se recoge el feedback del cliente.
5. [x] Completar las secciones de Trade-off analysis y Consequences de este ADR.
6. [ ] Redactar un nuevo ADR con el plan preliminar de fases (secuenciación de funcionalidades dentro de cada plataforma).
