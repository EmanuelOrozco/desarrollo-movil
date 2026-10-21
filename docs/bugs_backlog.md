# Backlog de bugs

Build revisada: `1.0.0+1`

Prioridad: P1 bloquea el flujo principal. P2 lo degrada y todavía hay alternativa. P3 es un detalle o una deuda secundaria.

## Abiertos

### BUG-01 · El detalle no muestra si la nota está pendiente

- Build: `1.0.0+1`
- Pasos: guardar una nota con Firebase disponible y volver a abrir el detalle.
- Esperado: la pantalla indica si la nota sigue pendiente o ya se sincronizó.
- Obtenido: la nota y el rating vuelven desde Drift. El estado `pendingSync` solo se puede ver en la base local, no en la interfaz.
- Prioridad: P3
- Estado: Abierto

## Cerrados

No hay P1 abiertos. Guardar una nota no borra el catálogo ni el favorito, y la app vuelve a abrir con la nota local.
