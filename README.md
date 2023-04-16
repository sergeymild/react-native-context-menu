# react-native-popup-menu

This library allows to create simple context menu

## Installation

```sh
"react-native-context-menu": "sergeymild/react-native-context-menu#0.1.0"
```

## Usage

```js
import { showContextMenu } from "react-native-context-menu";

// ...

export interface ContextMenuParams {
   readonly minWidth?: number;
    readonly safeAreaBottom?: number;
    readonly viewTargetId?: RefObject<any>;
    readonly rect?: { x: number; y: number; width: number; height: number };
    readonly menuBackgroundColor?: string;
    readonly menuItemHeight?: number;
    readonly menuCornerRadius?: number;
    readonly bottomMenuItems: {
      id: string;
      title: string;
      titleSize?: number;
      iconSize?: number;
      color?: string;
      iconTint?: string;
      icon?: ImageRequireSource;
    }[];
}

// default configuration for all popups
configurePopup(params: ContextMenuParams)

// in App

const selectedId = await showContextMenu({
  minWidth: 200,
    safeAreaBottom: props.safeAreaBottom,
    viewTargetId: props.addPreview ? ref : undefined,
    rect: viewHelpers.measureView(ref),
    bottomMenuItems: [
      { id: 'copy', title: 'Copy' },
      {
        id: 'delete',
        title: 'Delete',
        color: 'red',
        iconTint: 'red',
        icon: require('./trash.png'),
      },
    ],
});
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
