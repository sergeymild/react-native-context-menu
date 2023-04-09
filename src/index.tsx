import {
  findNodeHandle,
  Image,
  ImageRequireSource,
  NativeModules,
  Platform,
  processColor,
} from 'react-native';
import type { RefObject } from 'react';

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
  readonly viewTargetId?: RefObject<any>;
  readonly rect: { x: number; y: number; width: number; height: number };
  readonly bottomMenuItems: {
    id: string;
    title: string;
    color?: string;
    iconTint?: string;
    icon?: ImageRequireSource;
    font?: string;
  }[];
}

export function showContextMenu(params: Params): Promise<number> {
  return new Promise<number>((resolve) => {
    ContextMenu.showMenu(
      {
        ...params,
        viewTargetId: params.viewTargetId
          ? findNodeHandle(params.viewTargetId.current)
          : undefined,
        bottomMenuItems: params.bottomMenuItems.map((item) => {
          return {
            ...item,
            color: item.color ? processColor(item.color) : undefined,
            iconTint: item.iconTint ? processColor(item.iconTint) : undefined,
            icon: item.icon
              ? Image.resolveAssetSource(item.icon).uri
              : undefined,
          };
        }),
      },
      (info: any) => {
        console.log('[Index.]', info);
        resolve(2);
      }
    );
  });
}
