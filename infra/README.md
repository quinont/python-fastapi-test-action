# Infraestructura

Esta carpeta contiene la infraestructura como código necesaria para el despliegue de la aplicación, integrando los siguientes servicios:

- **Cloud SQL (PostgreSQL):** Para la base de datos.
- **Cloud Run:** Para correr el servicio.
- **Cloud Artifact Registry:** Para guardar las imágenes de los contenedores.
- **Workload Identity Federation:** Para poder autenticar GitHub Actions contra GCP.

Para obtener más detalles sobre la arquitectura, puedes revisar el archivo [ARCHITECTURE_GCP.md](../docs/ARCHITECTURE_GCP.md).

## NOTA

Lamentablemente, no pude llegar a generar un proyecto en GCP e instalar todo lo necesario para poder ejecutar la infraestructura y probar el despliegue con GitHub. De todas formas, dejo los archivos que considero que son necesarios para poder trabajar en esto.

## Cómo ejecutar

Primero, es necesario generar una cuenta de servicio con privilegios de **Owner** en un proyecto de GCP.

Luego, se debe generar la llave (key) de la cuenta de servicio y guardarla como un archivo JSON en GitHub. Esta llave debe estar configurada como un secreto en el entorno de *production*. El nombre del secreto debe ser `GCP_SA_KEY`.

A continuación, vamos a generar un bucket en Cloud Storage para almacenar los archivos de estado (`tfstate`) de Terraform. De esta forma, no tendremos que complicarnos demasiado con la gestión de estados de terraform desde GitHub.

Con el nombre del bucket a mano, debemos ir a los archivos `backend.tf` de las carpetas `infra/envs/prod`, `infra/envs/dev` e `infra/envs/common` y reemplazar el valor `"TU-BUCKET-DE-ESTADO-AQUI"` por el nombre de nuestro bucket.

También debemos modificar el archivo `variables.tf` en esas mismas tres carpetas y reemplazar `"TU-PROYECTO-AQUI"` por el ID de nuestro proyecto de GCP.

Con estos pasos, ya podremos comenzar a trabajar con Terraform.

## Terraform Local

Para poder ejecutar Terraform localmente es necesario:
- Tener instalado terraform y el sdk de google cloud.
- Autenticarse con la cuenta de servicio (o si somos owner con nuestra cuenta de usuario) en gcloud.

Una vez realizado esto, debemos dirigirnos a alguna de las carpetas de entorno (`infra/envs/prod`, `infra/envs/dev` o `infra/envs/common`) y ejecutar los siguientes comandos:

```bash
terraform init
terraform plan
terraform apply
```

## Terraform desde GitHub Actions

Así como lo podemos correr localmente, una vez configuradas todas las variables y secretos en GitHub, también podremos ejecutar esto de forma automatizada desde la rama `main` del proyecto.

Cuando se modifique cualquier archivo dentro de la carpeta `infra`, se ejecutará el workflow de Terraform ([terraform.yml](../.github/workflows/terraform.yml)).

Este workflow corre `terraform lint` y `fmt` para validación en cualquier rama distinta a `main`. En cambio, para la rama `main`, ejecuta el `terraform apply` ocupando la credencial que generamos.

> **NOTA:** Dado que no pude levantar la infraestructura en GCP, opté por dejar el código del `apply` comentado en el archivo `terraform.yml`. De ser necesario ejecutarlo, mi idea es que al borrar los comentarios debería funcionar sin problemas (o eso espero).

**Otro dato importante a tener en cuenta:** Dado que configuré los procesos del entorno de *production* para requerir aprobación manual, y como tenemos tres configuraciones de Terraform separadas (`common`, `dev` y `prod`), va a ser necesario aprobar los cambios tres veces consecutivas durante el despliegue.