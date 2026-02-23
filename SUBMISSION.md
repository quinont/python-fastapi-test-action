# Submission

**Link del repositorio:** 
- https://github.com/quinont/python-fastapi-test-action

**Links de runs de CI (PR y main):**
- **PR:** https://github.com/quinont/python-fastapi-test-action/pull/7
  - Pipelines:
     - pipeline de ci https://github.com/quinont/python-fastapi-test-action/actions/runs/22289054667
     - pipeline de despliegue en dev https://github.com/quinont/python-fastapi-test-action/actions/runs/22289078670
     - pipeline durante el PR (test de integracion) https://github.com/quinont/python-fastapi-test-action/actions/runs/22289110470
- **Main:** 
  - pipeline de despliegue y generacion de tag: https://github.com/quinont/python-fastapi-test-action/actions/runs/22289133518

**Link de un tag:**
- link del tag generado en el main: https://github.com/quinont/python-fastapi-test-action/releases/tag/v0.10.0

---

## Evidencias

Lamentablemente no pude levantar un entorno de GCP; por lo tanto, no tengo las evidencias de los despliegues ni de las imágenes generadas.

## Decisiones principales

- Me enfoqué principalmente en el pipeline de GitHub Action, priorizando que contenga las ideas principales por sobre su funcionamiento real y final en GCP.
- Traté de que tanto el manejo de ramas (*branching*) como el despliegue fueran lo más simples y directos posible.
- Modifiqué el código levemente para agregar algunos tests, habilitar el *linter* y realizar análisis estáticos.

## Mejoras a futuro (con más tiempo)

Si tuviera más tiempo de desarrollo:
- Lograría que el despliegue funcionara de punta a punta en GCP de verdad.
- Aumentaría la cantidad y la cobertura de los tests de todo tipo.
- Implementaría despliegues tipo *Canary* para Cloud Run.
- Mejoraría la implementación de los manifiestos de Kubernetes.
- Optimizaría la caché del pipeline y simplificaría el Dockerfile (que actualmente también se encarga del *packaging*).
