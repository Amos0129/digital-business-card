import path from 'node:path'
import { fileURLToPath } from 'node:url'
import react from 'eslint-plugin-react'
import _import from 'eslint-plugin-import'
import { fixupPluginRules } from '@eslint/compat'
import globals from 'globals'
import tsParser from '@typescript-eslint/parser'
import js from '@eslint/js'
import { FlatCompat } from '@eslint/eslintrc'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)
const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
  allConfig: js.configs.all
})

// eslint-disable-next-line
export default [
  ...compat.extends(
    'eslint:recommended',
    'plugin:react/recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:prettier/recommended'
  ),
  {
    plugins: {
      react,
      import: fixupPluginRules(_import)
    },

    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node
      },

      parser: tsParser,
      ecmaVersion: 2020,
      sourceType: 'module',

      parserOptions: { ecmaFeatures: { jsx: true } }
    },

    settings: { react: { version: 'detect' } },

    rules: {
      'max-len': [
        'error',
        {
          code: 120, // 設置每行的最大長度
          ignorePattern: '^import\\s.+\\sfrom\\s.+;$' // 忽略 import 語句的長度限制
        }
      ],

      'react/self-closing-comp': 'error',

      'arrow-body-style': ['error', 'as-needed'],
      'implicit-arrow-linebreak': ['off'],

      'import/no-anonymous-default-export': [
        'error',
        {
          allowArrowFunction: true,
          allowAnonymousClass: true,
          allowAnonymousFunction: true
        }
      ],

      'linebreak-style': ['error', 'windows'],
      'react/display-name': 'off',
      'react/react-in-jsx-scope': 'off',
      'react/prop-types': 'off'
    }
  }
]
