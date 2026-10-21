# RC-1 · build 1.0.0+1

Una release candidate se puede entregar si no aparece un fallo crítico. No significa que la app esté perfecta.

| Criterio | Estado |
| --- | --- |
| Instalable | `build/app/outputs/flutter-apk/app-release.apk` se instaló en el emulador y abrió |
| Identificable | `pubspec.yaml` declara `version: 1.0.0+1` |
| Sin P1 | No hay bloqueantes abiertos en `docs/bugs_backlog.md` |
| Probada | CP-01 y CP-08 se comprobaron con este APK. CP-04, CP-05 y CP-07 ya se habían observado en el emulador. CP-02, CP-03 y CP-06 no se reejecutaron: el fallo simulado no queda en la build |
| Transparente | BUG-01, P3, sigue abierto: el detalle no muestra pendiente o sincronizado |

## Decisión

Sí es RC-1 para el flujo principal. La build `1.0.0+1` está identificada, el APK release instala y abre el catálogo, y no hay un P1 abierto. BUG-01 sigue abierto como P3.

Los fallos simulados de API, catálogo vacío y Firebase no forman parte del código. Esos tres casos quedan descritos en la matriz y no se volvieron a provocar sobre este APK.

La firma release del módulo Android sigue usando la configuración debug que ya traía el proyecto. No se agregó un keystore. `android/key.properties`, `*.jks` y `*.keystore` están en `.gitignore`.
