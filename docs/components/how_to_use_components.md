# How to use components

IA SDK components (e.g. `IaProductGrid`) can be embedded anywhere in your app's UI. Like every IA SDK screen, they
require:
* **SDK initialization** to be finished.
* **Prerequisites** (e.g. pharmacy selection) to be completed.

Until both are done, a component shows only a loading indicator.

This is easy to handle if you call `initialize` before any component is shown, e.g. when your app starts.

It gets trickier when a component can be shown before you call `initialize`, or you don't want the prerequisites
screens to appear where the component is shown, for example:

> Your app has a single SDK entry point on the third tab, where you call `initialize`. Now you want to add
> `IaProductGrid` to the first tab, which the user sees first.

This guide shows how to handle initialization and prerequisites in such cases.

> [!TIP]
> To learn more about initialization and prerequisites in general, see [Initialization](../initialization.md).

## Initialization

Components don't initialize the SDK themselves, so you must call `initialize` before a component is shown. Choose one
of the following options.

### Option 1: Call `initialize` in every place that uses the SDK
Call `initialize` both in your SDK entry point and before showing the component. This is safe because only the first
successful call has an effect, later calls return without applying their configuration. Pass the same configuration
everywhere.

```dart
await IaSdk.instance.initialize(config: config);
// Show IaProductGrid
```

### Option 2: Call `initialize` once at app start
Call `initialize` once when your app starts. After that, components and screens can be used anywhere in the app.

> [!TIP]
> If you want the prerequisites to run before any component or screen is shown, call `launchPrerequisiteFlow`, and
> show the component only if the flow wasn't cancelled. This also lets you handle errors yourself, instead of the SDK
> showing its own error screen.
> ```dart
> try {
>   final result = await IaSdk.instance.launchPrerequisiteFlow();
>   if (!result.isCancelled) {
>     // Show IaProductGrid
>   }
> } catch (error) {
>   // Handle error
> }
> ```

## Prerequisites check

If you don't want prerequisites screens (e.g. onboarding) to appear where the component is shown, e.g. on the first
tab, you can show the component only if the user has already completed prerequisites in your SDK entry point.

Use `isPrerequisiteFlowCompleted` and show the component only if it returns `true`.
* It is a one-time check that returns the current state. Call it every time the screen with the component is shown
  (e.g. when the user switches to its tab), so the component shows up once the user has completed prerequisites in
  your SDK entry point.
* It checks the prerequisites you passed in `IaSdkConfigurationInitialization.prerequisites`.
* It fails if the SDK is not initialized, so call `initialize` first.

```dart
await IaSdk.instance.initialize(config: config);
final isCompleted = await IaSdk.instance.isPrerequisiteFlowCompleted();
if (isCompleted) {
  // Show IaProductGrid
}
```

> [!CAUTION]
> Use this check only to decide whether to add the component to your layout. Don't use it to hide and show the
> component repeatedly, as that destroys its state and makes it reload.

## Platform differences
- **Prerequisites check:** On iOS, `isPrerequisiteFlowCompleted` always needs a pharmacy, and fails when it can't be
  loaded. On Android a pharmacy isn't needed with `runApofinderIfNeeded: false`, and one that can't be loaded counts
  as selected.
