# GKE Runbook

Para poder trabajar con GKE se generó la carpeta `k8s`, que cuenta con 3 subcarpetas:

- `app`: Contiene los manifiestos para desplegar la app.
- `database`: Contiene los manifiestos para desplegar la base de datos.
- `terraform`: Módulo de Terraform para crear el cluster de GKE.

## Consideraciones

Se tomaron las siguientes consideraciones por simplicidad del ejemplo:

- **Namespaces:** La app y la base de datos se despliegan en `default`. En producción, es recomendable usar namespaces separados por servicio.
- **Base de Datos:** Se levanta dentro del cluster. Kubernetes está pensado para aplicaciones *stateless*; en producción conviene usar herramientas como Cloud SQL.
- **Formatos:** Se utilizaron manifiestos YAML crudos por cuestiones de tiempo. Lo ideal sería unificarlos en un *template* de Helm para facilitar futuros despliegues.
- **Exposición (IMPORTANTE):** Se ocupa un Ingress de GCP, pero esta API se está deprecando. Se recomienda encarecidamente migrar a la **Gateway API**.

---

## Cómo desplegar en GKE

Para desplegar en GKE inicialmente es necesario:

1. Tener el rol de **Editor** (o superior) para la API de GKE.
2. Tener `kubectl` y `gcloud` instalados y configurados.
3. Tener el cluster de GKE creado y en ejecución.

### Pasos de Despliegue

1. Obtener acceso y credenciales del cluster:
   ```bash
   gcloud container clusters get-credentials [CLUSTER_NAME] --region [REGION]
   ```
2. Aplicar los manifiestos de la base de datos:
   ```bash
   kubectl apply -f k8s/database/
   ```
   > **Nota:** La primera vez puede ser necesario inicializar la base de datos con el script `server/db/init.sql`. Se puede ejecutar manualmente abriendo un túnel con `kubectl port-forward` hacia el servicio de la DB.

3. Generar una nueva versión de la imagen y actualizar `k8s/app/deployment.yaml`.
4. Aplicar los manifiestos de la aplicación:
   ```bash
   kubectl apply -f k8s/app/
   ```

---

## Actualización a una nueva imagen

Para actualizar el entorno con una nueva versión de la aplicación:

1. Generar la nueva imagen y modificar el *deployment* para que apunte a ella:
   ```bash
   kubectl set image deployment/fastapi-app app=[NEW_IMAGE_NAME]
   ```
2. Monitorear el progreso hasta que se levanten los nuevos *pods*:
   ```bash
   kubectl rollout status deployment/fastapi-app
   ```

---

## Rollback a una versión anterior

Si ocurre un problema y necesitamos revertir la aplicación rápidamente:

1. Para volver inmediatamente a la versión anterior (n-1):
   ```bash
   kubectl rollout undo deployment/fastapi-app
   ```
   *(Si se desea ir a una versión específica antigua, usar el comando `set image` con el tag requerido).*
2. Esperar a que se terminen de levantar los pods estables.

---

## Mejoras a futuro (TODO)

- **Gestión de Secretos:** Integrar una herramienta como [External Secrets Operator](https://github.com/external-secrets/external-secrets) para mapear de forma nativa los secretos de Google Secret Manager hacia Kubernetes.
- **Base de Datos Externa:** Migrar la base de datos fuera del cluster hacia Cloud SQL, utilizando *Cloud SQL Auth Proxy* y *Workload Identity* de GCP para la conexión segura de los pods.
- **Helm Charts:** Migrar los manifiestos YAML a un *chart* de Helm para simplificar enormemente la administración y actualización del entorno.
- **Red:** Quitar el Ingress actual y pasar la configuración a *Gateway API*.