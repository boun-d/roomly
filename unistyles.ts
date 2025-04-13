import { UnistylesRegistry } from 'react-native-unistyles'
import { breakpoints } from './breakpoints'
import { dark } from './themes'

type AppBreakpoints = typeof breakpoints
type AppThemes = {
  dark: typeof dark
}

declare module 'react-native-unistyles' {
  export interface UnistylesBreakpoints extends AppBreakpoints {}
  export interface UnistylesThemes extends AppThemes {}
}

UnistylesRegistry
  .addBreakpoints(breakpoints)
  .addThemes({
    dark,
  })
  .addConfig({
    adaptiveThemes: true
  })