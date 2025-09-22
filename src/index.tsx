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

export type ContextMenuAction = {
  id: string;
  title: string;
  titleSize?: number;
  fontFamily?: string;
  iconSize?: number;
  color?: string;
  iconTint?: string;
  icon?: ImageRequireSource;
  submenu?: ContextMenuAction[];
};

export type TopMenuItem = {
  id: string;
  icon?: ImageRequireSource;
  iconTint?: string;
  emoji?: string;
};

interface Params {
  minWidth?: number;
  safeAreaBottom?: number;
  viewTargetId?: RefObject<any>;
  rect?: { x: number; y: number; width: number; height: number };
  menuBackgroundColor?: string;
  menuItemHeight?: number;
  topMenuItemSize?: number;
  separatorColor?: string;
  separatorHeight?: number;
  menuCornerRadius?: number;
  menuEdgesMargin?: number;
  gravity?: 'start' | 'end';
  bottomMenuItems: ContextMenuAction[];
  topMenuItems: TopMenuItem[];
  disableBlur?: boolean;
  leadingIcons?: boolean;
}

type ItemPressed = { id: string; type: 'top' | 'bottom' };

export function showContextMenu(params: Params) {
  if (Platform.OS === 'android' && !params.rect) {
    throw new Error('rect must be present');
  }
  if (Platform.OS === 'ios' && !params.rect && !params.viewTargetId) {
    throw new Error('either rect or viewTargetId must be present');
  }
  return new Promise<ItemPressed | undefined>((resolve) => {
    ContextMenu.showMenu(
      {
        ...params,
        minWidth: params.minWidth ?? 100,
        disableBlur: params.disableBlur ?? false,
        leadingIcons: params.leadingIcons ?? false,
        menuCornerRadius: params.menuCornerRadius ?? 12,
        menuItemHeight: params.menuItemHeight ?? 36,
        topMenuItemSize: params.topMenuItemSize ?? 36,
        safeAreaBottom: params.safeAreaBottom ?? 0,
        menuEdgesMargin: params.menuEdgesMargin ?? 8,
        separatorColor: params.separatorColor
          ? processColor(params.separatorColor)
          : undefined,
        separatorHeight: params.separatorHeight,
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
        topMenuItems: params.topMenuItems?.map((item) => {
          return {
            ...item,
            iconTint: item.iconTint
              ? processColor(item.iconTint)
              : processColor('black'),
            icon: item.icon
              ? Image.resolveAssetSource(item.icon).uri
              : undefined,
          };
        }),
      },
      (id: string, type: 'top' | 'bottom') => {
        resolve({ id, type } as ItemPressed);
      }
    );
  });
}
