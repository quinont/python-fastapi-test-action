# Proceso de Despliegue

Para este proyecto decidí configurar dos ambientes principales en github: **develop** y **production**.

Dado que estamos utilizando Trunk-Based Development (TBD), la premisa es que todo lo que se encuentre en la rama `main` debe ser desplegado a producción.

Toda la lógica de estos despliegues se encuentra centralizada y definida en el archivo `.github/workflows/env-deploy.yml`.

### Diferencias entre los despliegues de ambientes

- **Production (Producción):** El despliegue a producción es **obligatorio y automático** con cada push a la rama `main`. Sin embargo, he configurado una capa adicional de control: una vez que se dispara el flujo, el mismo queda pausado esperando una **aprobación manual** por parte de un administrador en GitHub para poder ejecutar el job final que modifica el entorno productivo.
- **Develop (Desarrollo):** El despliegue al entorno de desarrollo se diseñó para ser totalmente **opcional y manual**. Se puede gatillar a voluntad desde cualquier rama secundaria (vía _workflow_dispatch_) y no requiere la aprobación de ningún usuario para realizarse, facilitando así las pruebas rápidas del código nuevo.

---

## Nota importante sobre el entorno GCP

> **Aclaración:** Es sumamente importante destacar que **no pude levantar ni probar el entorno final directamente en GCP**.
> Por lo tanto, parte del proceso de despliegue en los workflows no fue validado de forma "end-to-end". Es muy probable que existan detalles de configuración dando vueltas que requieran pequeños ajustes al ser ejecutados en una cuenta real de Google Cloud.

---

## Variables de Entorno y Secretos en GitHub

Para gestionar de forma limpia las diferencias entre `develop` y `production`, utilicé la funcionalidad de **Environments (Entornos)** propios de GitHub. 

Para configurar que el despliegue a producción requiriera una aprobación, primero creé un "Environment" llamado `production` en la configuración del repositorio en GitHub. Dentro de este, activé la regla de protección "*Required reviewers*" y agregué mi usuario como el único habilitado para aprobar dicho despliegue.

El uso de Environments de GitHub también me permitió definir variables y secretos específicos según el entorno, logrando que el código del workflow sea agnóstico y reusable. Algunas de estas variables configuradas en GitHub son:

- `SECRET_DATABASE_URL` *(Variable)*: Es el id del secreo de google secret manager para acceder a la cadena de conexión hacia la base de datos.
- `SERVICE_NAME` *(Variable)*: Es el nombre particular del servicio que se va a desplegar en el Cloud Run de ese ambiente.

De esta forma, al correr el Action, GitHub inyecta dinámicamente los valores correspondientes al entorno elegido.

Para el ambiente de producción, adicionalmente generé a nivel repositorio un secreto llamado `GCP_SA_KEY`, el cual contiene la llave (JSON) de la cuenta de servicio de GCP necesaria para que Terraform cree la infraestructura. (Esto está más detallado en `ARCHITECTURE_GCP.md`).

---

## Versionamiento de Imágenes Docker

Para tener un versionamiento de las imágenes de Artifact Registry que fuera simple, predecible y fácil de rastrear, **decidí atar las versiones de las imágenes directamente a los tags de Git** (ocupando la salida generada por el job auxiliar `common-lint-version.yml`), en lugar de usar los hashes indescifrables de los commits de git. Esto resulta mucho más amigable para cualquiera que tenga que hacer un rollback.

> **Importante:** Dado que las versiones de las imágenes provienen directamente de los tags generados en función del historial de Git, **es vital mantener un buen criterio y disciplina en el manejo de los commits** (e.g. seguir Conventional Commits).

Para lidiar con el entorno de `develop`, como tag de la imagen ocupo el "futuro tag" que tendría la versión si ese cambio estuviera en main, seguido del sufijo `-rc` (como Release Candidate). De esta forma, si el día de mañana queremos implementar un sistema de limpieza automática en Artifact Registry, bastaría con eliminar las imágenes que terminan en `-rc` sabiendo que son pre-productivas.

Obviamente, esto último se podría haber solucionado publicando las imágenes de dev en un proyecto secundario de preproducción, pero encontré que esta estrategia de sufijos era la más directa y la que más me gustó.

---

## Autenticación vía Workload Identity Federation (WIF)

Para la comunicación entre GitHub Actions y Google Cloud decidí implementar **Workload Identity Federation (WIF)**. Esta es la mejor práctica actual de seguridad, ya que permite que GitHub reciba tokens temporales (OIDC) para autenticarse en GCP **sin necesidad de generar y guardar credenciales estáticas (Service Accounts en JSON)** de larga duración.

> **Precaución sobre el uso de WIF:**
>
> Si bien usar WIF es el camino recomendado, **es importante entender lo peligroso que puede llegar a ser si se configura de manera incompleta.**
>
> El riesgo principal es que, si en Google Cloud no aplicamos de manera correcta las **condiciones de filtro de atributos (attribute filters)** para exigir que la llamada provenga exlusivamente de este repositorio puntual (`attribute.repository == "usuario/repositorio"`), estaríamos dejando la puerta abierta. Cualquier otro repositorio de GitHub, al conocer nuestra cadena de conexión pública de WIF (`projects/123/locations/global/workloadIdentityPools/pool/providers/provider`), podría pedir un token a nuestro nombre y accionar sobre nuestra nube gcp con nuestros permisos.
>
> Revisando la configuración hacia atrás, opino que incluso dicha cadena de conexión debería configurarse idealmente como un **secreto en GitHub** (y no como una variable de entorno plana en el workflow), para ni siquiera exponer el ID del Pool a quienes tengan acceso de lectura al repositorio.
