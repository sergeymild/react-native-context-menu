import * as React from 'react';
import { useRef } from 'react';
import { viewHelpers } from 'react-native-jsi-view-helpers';

import {
  Dimensions,
  Image,
  Platform,
  StyleProp,
  StyleSheet,
  TouchableOpacity,
  View,
  ViewStyle,
} from 'react-native';
import { showContextMenu } from 'react-native-context-menu';

const emojisList = [
  '👍',
  '👎',
  '❤️',
  '🔥',
  '🥰',
  '👏',
  '😄',
  '🤔',
  '🤯',
  '😱',
  '🤬',
  '😢',
  '🎉',
  '🤩',
  '🤮',
  '💩',
  '🙏',
  '👌',
];

const Item: React.FC<{
  style: StyleProp<ViewStyle>;
  addPreview?: boolean;
  safeAreaBottom?: number;
}> = (props) => {
  const ref = useRef<TouchableOpacity>(null);
  return (
    <TouchableOpacity
      activeOpacity={Platform.OS === 'android' ? 0.4 : 1}
      style={props.style}
      ref={ref}
      onPress={async () => {
        const f = await showContextMenu({
          minWidth: 50,
          safeAreaBottom: props.safeAreaBottom,
          viewTargetId: props.addPreview ? ref : undefined,
          rect: viewHelpers.measureView(ref),
          topMenuItemSize: 30,
          gravity: 'start',
          topMenuItems: emojisList.map((s) => ({ id: s, emoji: s })),
          bottomMenuItems: [
            { id: 'copy', title: 'copy', icon: require('./trash.png') },
            { id: 'copy', title: 'copy', icon: require('./trash.png') },
            {
              id: 'delete',
              title: 'Delete',
              color: 'red',
              iconTint: 'red',
              icon: require('./trash.png'),
              submenu: [
                {
                  id: 'delete',
                  title: 'Delete for me',
                  icon: require('./trash.png'),
                },
                {
                  id: 'delete',
                  title: 'Удалить сообщение для всех',
                  icon: require('./trash.png'),
                  color: 'red',
                  iconTint: 'red',
                },
              ],
            },
          ],
        });
        console.log('[App.]', f);
      }}
    >
      <Image
        source={require('./trash.png')}
        style={{ width: 16, height: 16, tintColor: 'white' }}
      />
    </TouchableOpacity>
  );
};

export default function App() {
  const ref2 = useRef<TouchableOpacity>(null);

  return (
    <View style={styles.container}>
      <Item
        addPreview
        style={{
          position: 'absolute',
          top: 34,
          start: 0,
          width: 100,
          height: 60,
          backgroundColor: 'red',
        }}
      />

      <Item
        addPreview
        style={{
          position: 'absolute',
          top: 34,
          end: 0,
          width: 100,
          height: 60,
          backgroundColor: 'red',
        }}
      />

      <Item
        addPreview
        style={{
          position: 'absolute',
          bottom: 50,
          end: 0,
          width: 100,
          height: 60,
          backgroundColor: 'red',
        }}
      />

      <Item
        addPreview
        style={{
          position: 'absolute',
          alignSelf: 'center',
          top: (Dimensions.get('window').height - 100) / 2,
          width: 200,
          height: 100,
          borderRadius: 8,
          backgroundColor: 'red',
        }}
      />

      <Item
        addPreview
        safeAreaBottom={50}
        style={{
          position: 'absolute',
          bottom: 50,
          start: 0,
          width: 100,
          height: 60,
          backgroundColor: 'purple',
        }}
      />
      <View
        style={{
          width: '100%',
          height: 50,
          backgroundColor: 'green',
          position: 'absolute',
          bottom: 0,
          start: 0,
          end: 0,
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
    backgroundColor: 'green',
    borderRadius: 8,
    marginStart: 8,
  },
});
