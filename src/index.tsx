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

type ContextMenuAction = {
  id: string;
  title: string;
  titleSize?: number;
  iconSize?: number;
  color?: string;
  iconTint?: string;
  icon?: ImageRequireSource;
  submenu?: ContextMenuAction[];
};

interface Params {
  readonly minWidth?: number;
  readonly safeAreaBottom?: number;
  readonly viewTargetId?: RefObject<any>;
  readonly rect?: { x: number; y: number; width: number; height: number };
  readonly menuBackgroundColor?: string;
  readonly menuItemHeight?: number;
  readonly menuCornerRadius?: number;
  readonly bottomMenuItems: ContextMenuAction[];
}

export function showContextMenu(params: Params): Promise<string | undefined> {
  if (Platform.OS === 'android' && params.viewTargetId) {
    throw new Error('viewTargetId is not supported on Android');
  }
  if (Platform.OS === 'android' && !params.rect) {
    throw new Error('rect must be present');
  }
  if (Platform.OS === 'ios' && !params.rect && !params.viewTargetId) {
    throw new Error('either rect or viewTargetId must be present');
  }
  return new Promise<string | undefined>((resolve) => {
    ContextMenu.showMenu(
      {
        ...params,
        minWidth: params.minWidth ?? 200,
        menuCornerRadius: params.menuCornerRadius ?? 12,
        menuItemHeight: params.menuItemHeight ?? 36,
        safeAreaBottom: params.safeAreaBottom ?? 0,
        viewTargetId: params.viewTargetId
          ? findNodeHandle(params.viewTargetId.current)
          : undefined,
        menuBackgroundColor: params.menuBackgroundColor
          ? processColor(params.menuBackgroundColor)
          : processColor('white'),
        bottomMenuItems: params.bottomMenuItems.map((item) => {
          return {
            ...item,
            titleSize: item.titleSize ?? 14,
            iconSize: item.iconSize ?? 16,
            color: item.color
              ? processColor(item.color)
              : processColor('black'),
            iconTint: item.iconTint
              ? processColor(item.iconTint)
              : processColor('black'),
            icon: item.icon
              ? Image.resolveAssetSource(item.icon).uri
              : undefined,
            submenu: item.submenu?.map((m) => ({
              ...m,
              titleSize: m.titleSize ?? 14,
              iconSize: m.iconSize ?? 16,
              color: m.color ? processColor(m.color) : processColor('black'),
              iconTint: m.iconTint
                ? processColor(m.iconTint)
                : processColor('black'),
              icon: m.icon ? Image.resolveAssetSource(m.icon).uri : undefined,
            })),
          };
        }),
      },
      (info: any) => {
        console.log('[Index.]', info);
        resolve(info);
      }
    );
  });
}
