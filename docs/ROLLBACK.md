# Rollback

Dado que nuestra fuente de verdad es Git, propongo dos alternativas para realizar un rollback en caso de incidentes.

> **Nota:** Este proceso solo contempla el ambiente de **producción**, ya que es el único que afecta directamente a los clientes. El ambiente de desarrollo (*develop*) no se consideró por no ser crítico.

---

## Opción no recomendada: Rollback vía Git

Este proceso consiste en revertir el historial de cambios creando un nuevo *commit* que deshaga los problemas introducidos en `main`.

```bash
# Obtener el hash del commit al que se desea revertir
git log

# Crear un revert del commit problemático
git revert <hash_del_commit>

# Subir el cambio a main
git push origin main
```

Si la rama `main` se encuentra bloqueada por reglas de protección, deberíamos realizar el revert en una rama secundaria y luego enviar un *Pull Request* para aplicar el cambio.

---

## Opción recomendada: Rollback vía GitHub Actions

Dado que almacenamos nuestras imágenes de containers en Artifact Registry, la opción más eficiente es simplemente indicarle a Cloud Run que vuelva a usar la imagen de una versión anterior estable.

Para automatizar esto, creé el workflow `.github/workflows/rollback.yml`. Este flujo permite regresar a versiones pasadas de la aplicación en segundos, evitando generar nuevos *commits* forzados o resolver conflictos de Git bajo presión.

### Ejecución

1. Ir a la pestaña de GitHub Actions y seleccionar el workflow **Rollback**.
2. Ejecutar el workflow de forma manual (*Run workflow*).
3. Ingresar como parámetro el **Tag de Git** de la versión a la que se desea regresar.
4. El proceso desplegará automáticamente esa imagen en producción.

> **Importante:** Esta acción es una medida de emergencia temporal para mitigar un incidente grave. Mientras el *rollback* está en producción, el equipo debe trabajar inmediatamente en un *fix* sobre el código y enviarlo a `main`. **La premisa principal sigue siendo que la rama `main` siempre debe reflejar lo que está corriendo en producción.**

---

## Mejoras a futuro (TODO)

Al terminar de plantear todo el código, me di cuenta de que los flujos de *despliegue* y de *rollback* son prácticamente idénticos por debajo. 

Una excelente mejora futura sería unificar toda la lógica en un solo workflow central, y simplemente llamarlo pasando parámetros desde ambos flujos (tal cual se hizo con el archivo reutilizable `common-lint-version.yml`).
