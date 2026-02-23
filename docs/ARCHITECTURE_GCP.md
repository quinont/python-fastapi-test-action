# Arquitectura GCP

## Diagrama de Arquitectura

```mermaid
graph TD
    subgraph Internet
        Internet[Internet]
    end

    subgraph GitHub
        GA[GitHub Actions]
    end

    subgraph Google Cloud Platform
        WIF[Workload Identity Federation]
        AR[Cloud Artifact Registry]
        CR[Cloud Run]
        SM[Secret Manager]
        SQL[(Cloud SQL - PostgreSQL)]
    end

    GA -->|1. Autentica vía| WIF
    GA -->|2. Sube imagen a| AR
    GA -->|3. Despliega en| CR
    CR -->|4. Consume imagen de| AR
    CR -.->|5. Obtiene credenciales de| SM
    CR <-->|6. Lee y Escribe datos en| SQL
    CR -->|7. Expone servicio públicamente| Internet
```

## Resumen de la Solución

La arquitectura implementada en este proyecto utiliza **Cloud Run** como servicio público principal con una base de datos **Cloud SQL (PostgreSQL)** por detrás.

- **GitHub Actions** se encarga de aplicar modificaciones en el código del servicio desplegado en Cloud Run.
- **Cloud Artifact Registry** se utiliza para guardar las imágenes de los contenedores Docker.
- Actualmente la infraestructura se divide en dos ambientes: `dev` y `prod`. Si bien en este momento las configuraciones son las mismas, mi idea a futuro es poder tener una base de datos más grande para producción o restringir el acceso para no hacerlo tan público en desarrollo, entre otras mejoras.

## Estructura de la carpeta `infra`

La carpeta `infra` está dividida en dos subdirectorios principales:

- **`envs/`**: Contiene las configuraciones específicas de cada ambiente.
- **`modules/`**: Contiene los módulos de Terraform.

### Ambientes (`envs`)

- **`dev` y `prod`**: Sirven para levantar sus respectivos recursos de Cloud Run y Cloud SQL, además de gestionar las credenciales necesarias para que el servicio se conecte a la base de datos.
- **`common`**: Mi idea con esta carpeta es concentrar la configuración puntual del proyecto de GCP que se debe realizar una única vez (por ejemplo: habilitar APIs, configurar el Artifact Registry y Workload Identity Federation).

*Nota: En caso de que decidiéramos tener un proyecto de GCP distinto para cada ambiente, yo considero que la carpeta `common` debería ser absorbida por las carpetas de cada entorno.*

### Módulos (`modules`)

Dentro de esta carpeta se encuentran los módulos reutilizables de Terraform que se ocupan en los distintos ambientes:

- `artifact_registry`: Creación del Artifact Registry.
- `cloud_run`: Creación de Cloud Run.
- `cloud_sql`: Creación de Cloud SQL.
- `db_credentials`: Generación y gestión de credenciales para la base de datos.
- `project_services`: Habilitación de las APIs requeridas.
- `secret_manager`: Creación de secretos en Secret Manager.
- `service_account`: Creación de cuentas de servicio.
- `workload_identity`: Configuración de Workload Identity Federation.

Si bien se podrían ocupar los módulos públicos provistos por GCP, dado el contexto del proyecto y la simpleza de lo que se necesita, decidí crear mis propios módulos. Considero que esto se podría cambiar por algo más robusto en un futuro.
