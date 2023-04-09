import { ImageRequireSource, NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-context-menu' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const ContextMenu = NativeModules.ContextMenu
  ? NativeModules.ContextMenu
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

interface Params {
  readonly viewTargetId?: number;
  readonly rect: { x: number; y: number; width: number; height: number };
  readonly bottomMenuItems: {
    id: string;
    title: string;
    icon?: ImageRequireSource;
    font?: string;
  }[];
}

export function showContextMenu(params: Params): Promise<number> {
  return new Promise<number>((resolve) => {
    ContextMenu.showMenu(params, (info: any) => {
      console.log('[Index.]', info);
      resolve(2);
    });
  });
}
