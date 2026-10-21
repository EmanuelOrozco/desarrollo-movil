# Matriz de pruebas

Build: `1.0.0+1`  
Proyecto: productos (`practica_clase`)

| ID | Escenario | Esperado | Resultado en 1.0.0+1 |
| --- | --- | --- | --- |
| CP-01 | Catálogo normal | Se ven los productos | En el APK release instalado, la grilla cargó los productos |
| CP-02 | API falla | `ErrorView` y el botón Reintentar vuelve a consultar | El estado está en `ProductScreen`. El fallo simulado no queda en `ProductServices` |
| CP-03 | API vacía | `EmptyView` con el mensaje de catálogo vacío | El estado está en `ProductScreen`. El retorno temporal `[]` no queda en el servicio |
| CP-04 | Reinicio del favorito | El favorito sigue después de cerrar la app | Observado: `favoriteId` queda en SharedPreferences y el carrito sigue marcado |
| CP-05 | Reinicio de la nota | Drift recupera nota y rating | Observado: al reabrir, la nota y el rating guardados siguen en el detalle |
| CP-06 | Firebase falla | La nota queda en Drift con `pendingSync` en true | El repositorio guarda en local antes del remoto y, si el remoto falla, no llama a `markSynced`. La excepción temporal no queda en el data source |
| CP-07 | Sync posterior | Firestore recibe la nota y la deuda local queda resuelta | Observado: después de guardar, `pending_sync` pasó a 0 y el botón Sincronizar notas no crea otra nota |
| CP-08 | APK release | El archivo existe, se instala y la app abre | `app-release.apk` se instaló en el emulador y abrió en Productos |
