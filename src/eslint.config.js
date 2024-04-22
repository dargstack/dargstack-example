import prettierRecommended from 'eslint-plugin-prettier/recommended'

import withNuxt from './.nuxt/eslint.config.mjs'

export default withNuxt(
  prettierRecommended, // must be last

  // {
  //   languageOptions: {
  //     globals: {
  //       ...globals.node,
  //     },
  //   },
  //   rules: {
  //     '@typescript-eslint/no-unused-vars': [
  //       'error',
  //       {
  //         argsIgnorePattern: '^_',
  //         varsIgnorePattern: '^_',
  //       },
  //     ],
  //   },
  // },
)
