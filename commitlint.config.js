module.exports = {
  extends: ['@commitlint/config-conventional'],

  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',     // Nueva característica
        'fix',      // Corrección de bug
        'chore',    // Tareas de mantenimiento (ej. actualizar dependencias)
        'docs',     // Cambios en documentación
        'style',    // Formateo de código (espacios, punto y coma, etc.)
        'refactor', // Refactorización de código
        'perf',     // Mejoras de rendimiento
        'test',     // Agregar o modificar tests
        'build',    // Cambios en el sistema de build o dependencias externas
        'ci',       // Cambios en archivos de configuración de CI (GitHub Actions, GitLab CI)
        'revert'    // Revertir un commit anterior
      ]
    ],

    'type-empty': [2, 'never'],

    'subject-empty': [2, 'never'],

    'header-max-length': [2, 'always', 72],
  }
};
