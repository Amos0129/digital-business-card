import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import babel from '@rollup/plugin-babel'

const createAlias = (aliases) => Object.fromEntries(aliases.map((alias) => [alias, `/src/${alias}`]))

export default defineConfig({
  plugins: [
    react({ jsxRuntime: 'automatic', jsxImportSource: 'react' }),
    babel({
      babelHelpers: 'bundled',
      presets: ['@babel/preset-env', ['@babel/preset-react', { runtime: 'automatic' }]],
      extensions: ['.js', '.jsx'],
      exclude: 'node_modules/**'
    })
  ],
  css: {
    preprocessorOptions: {
      scss: {
        api: 'modern-compiler',
        silenceDeprecations: ['import', 'global-builtin', 'color-functions', 'mixed-decls']
      }
    }
  },
  esbuild: {
    loader: 'jsx',
    include: /src\/.*\.js$/
  },
  optimizeDeps: {
    esbuildOptions: {
      loader: {
        '.js': 'jsx',
        '.ts': 'tsx'
      }
    }
  },
  server: {
    port: 3000,
    open: true,
    sourcemap: false
  },
  build: {
    outDir: 'build',
    rollupOptions: {
      output: {
        sourcemap: 'false',
        manualChunks(id) {
          if (id.includes('/src/')) {
            return 'src'
          }
          if (id.includes('node_modules')) {
            return id.toString().split('node_modules/')[1].split('/')[0].toString()
          }
        }
      }
    }
  },
  resolve: {
    alias: createAlias(['@', 'page', 'config', 'layout', 'reducer', 'scss', 'utils', 'component'])
  }
})
