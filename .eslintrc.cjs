module.exports = {
  extends: [
    '@nuxtjs/eslint-config-typescript',
    'plugin:prettier/recommended',
    'plugin:nuxt/recommended',
    'plugin:yml/standard',
  ],
  root: true,
  rules: {
    'yml/quotes': ['error', { prefer: 'single' }],
  },
}
