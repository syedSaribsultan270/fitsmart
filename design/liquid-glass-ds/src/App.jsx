import { lazy, Suspense } from 'react'
import { Routes, Route } from 'react-router-dom'
import Layout from './components/Layout'

const Overview = lazy(() => import('./pages/Overview'))
const Typography = lazy(() => import('./pages/Typography'))
const Colors = lazy(() => import('./pages/Colors'))
const Spacing = lazy(() => import('./pages/Spacing'))
const Iconography = lazy(() => import('./pages/Iconography'))
const Buttons = lazy(() => import('./pages/Buttons'))
const Inputs = lazy(() => import('./pages/Inputs'))
const Navigation = lazy(() => import('./pages/Navigation'))
const Feedback = lazy(() => import('./pages/Feedback'))
const Content = lazy(() => import('./pages/Content'))
const Menus = lazy(() => import('./pages/Menus'))
const Motion = lazy(() => import('./pages/Motion'))
const VisualPrinciples = lazy(() => import('./pages/VisualPrinciples'))
const Accessibility = lazy(() => import('./pages/Accessibility'))
const Patterns = lazy(() => import('./pages/Patterns'))
const LayoutSystem = lazy(() => import('./pages/LayoutSystem'))
const Elevation = lazy(() => import('./pages/Elevation'))
const Pickers = lazy(() => import('./pages/Pickers'))
const TextViews = lazy(() => import('./pages/TextViews'))
const Popovers = lazy(() => import('./pages/Popovers'))
const TabViews = lazy(() => import('./pages/TabViews'))
const TokenFields = lazy(() => import('./pages/TokenFields'))
const ComboBox = lazy(() => import('./pages/ComboBox'))
const Rating = lazy(() => import('./pages/Rating'))
const ImageViews = lazy(() => import('./pages/ImageViews'))
const Tooltips = lazy(() => import('./pages/Tooltips'))
const Breadcrumbs = lazy(() => import('./pages/Breadcrumbs'))
const EmptyStates = lazy(() => import('./pages/EmptyStates'))
const LoadingStates = lazy(() => import('./pages/LoadingStates'))
const ErrorHandling = lazy(() => import('./pages/ErrorHandling'))
const DragDrop = lazy(() => import('./pages/DragDrop'))
const UndoRedo = lazy(() => import('./pages/UndoRedo'))
const KeyboardShortcuts = lazy(() => import('./pages/KeyboardShortcuts'))
const HapticPatterns = lazy(() => import('./pages/HapticPatterns'))
const Authentication = lazy(() => import('./pages/Authentication'))
const FormsValidation = lazy(() => import('./pages/FormsValidation'))
const DataManagement = lazy(() => import('./pages/DataManagement'))
const Onboarding = lazy(() => import('./pages/Onboarding'))
const Widgets = lazy(() => import('./pages/Widgets'))
const LiveActivities = lazy(() => import('./pages/LiveActivities'))
const Notifications = lazy(() => import('./pages/Notifications'))
const MediaPlayback = lazy(() => import('./pages/MediaPlayback'))
const MapsLocation = lazy(() => import('./pages/MapsLocation'))
const PlatformSpecifics = lazy(() => import('./pages/PlatformSpecifics'))
const Internationalization = lazy(() => import('./pages/Internationalization'))
const Privacy = lazy(() => import('./pages/Privacy'))
const Performance = lazy(() => import('./pages/Performance'))
const WritingTone = lazy(() => import('./pages/WritingTone'))

function PageLoader() {
  return (
    <div style={{
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      minHeight: 200,
      color: 'var(--label-tertiary)',
      font: 'var(--text-body)',
    }}>
      Loading...
    </div>
  )
}

export default function App() {
  return (
    <Layout>
      <Suspense fallback={<PageLoader />}>
        <Routes>
          <Route path="/" element={<Overview />} />
          <Route path="/typography" element={<Typography />} />
          <Route path="/colors" element={<Colors />} />
          <Route path="/spacing" element={<Spacing />} />
          <Route path="/iconography" element={<Iconography />} />
          <Route path="/buttons" element={<Buttons />} />
          <Route path="/inputs" element={<Inputs />} />
          <Route path="/navigation" element={<Navigation />} />
          <Route path="/feedback" element={<Feedback />} />
          <Route path="/content" element={<Content />} />
          <Route path="/menus" element={<Menus />} />
          <Route path="/motion" element={<Motion />} />
          <Route path="/visual-principles" element={<VisualPrinciples />} />
          <Route path="/accessibility" element={<Accessibility />} />
          <Route path="/patterns" element={<Patterns />} />
          <Route path="/layout-system" element={<LayoutSystem />} />
          <Route path="/elevation" element={<Elevation />} />
          <Route path="/pickers" element={<Pickers />} />
          <Route path="/text-views" element={<TextViews />} />
          <Route path="/popovers" element={<Popovers />} />
          <Route path="/tab-views" element={<TabViews />} />
          <Route path="/token-fields" element={<TokenFields />} />
          <Route path="/combo-box" element={<ComboBox />} />
          <Route path="/rating" element={<Rating />} />
          <Route path="/image-views" element={<ImageViews />} />
          <Route path="/tooltips" element={<Tooltips />} />
          <Route path="/breadcrumbs" element={<Breadcrumbs />} />
          <Route path="/empty-states" element={<EmptyStates />} />
          <Route path="/loading-states" element={<LoadingStates />} />
          <Route path="/error-handling" element={<ErrorHandling />} />
          <Route path="/drag-drop" element={<DragDrop />} />
          <Route path="/undo-redo" element={<UndoRedo />} />
          <Route path="/keyboard-shortcuts" element={<KeyboardShortcuts />} />
          <Route path="/haptic-patterns" element={<HapticPatterns />} />
          <Route path="/auth" element={<Authentication />} />
          <Route path="/forms" element={<FormsValidation />} />
          <Route path="/data" element={<DataManagement />} />
          <Route path="/onboarding" element={<Onboarding />} />
          <Route path="/widgets" element={<Widgets />} />
          <Route path="/live-activities" element={<LiveActivities />} />
          <Route path="/notifications" element={<Notifications />} />
          <Route path="/media" element={<MediaPlayback />} />
          <Route path="/maps" element={<MapsLocation />} />
          <Route path="/platforms" element={<PlatformSpecifics />} />
          <Route path="/i18n" element={<Internationalization />} />
          <Route path="/privacy" element={<Privacy />} />
          <Route path="/performance" element={<Performance />} />
          <Route path="/writing" element={<WritingTone />} />
        </Routes>
      </Suspense>
    </Layout>
  )
}
