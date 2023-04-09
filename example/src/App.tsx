import * as React from 'react';
import { useRef } from 'react';
import { viewHelpers } from 'react-native-jsi-view-helpers';

import {
  Dimensions,
  Image,
  StyleProp,
  StyleSheet,
  TouchableOpacity,
  View,
  ViewStyle,
} from 'react-native';
import { showContextMenu } from 'react-native-context-menu';

const Item: React.FC<{ style: StyleProp<ViewStyle>; addPreview?: boolean }> = (
  props
) => {
  const ref = useRef<TouchableOpacity>(null);
  return (
    <TouchableOpacity
      activeOpacity={1}
      style={props.style}
      ref={ref}
      onPress={async () => {
        console.log('[App.--]', viewHelpers.measureView(ref));
        showContextMenu({
          viewTargetId: props.addPreview ? ref : undefined,
          rect: viewHelpers.measureView(ref),
          bottomMenuItems: [
            { id: 'copy', title: 'Copy' },
            {
              id: 'delete',
              title: 'Delete',
              color: 'red',
              iconTint: 'yellow',
              icon: require('./trash.png'),
            },
          ],
        });
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
        style={{
          position: 'absolute',
          bottom: 0,
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
          width: 100,
          height: 100,
          borderRadius: 8,
          backgroundColor: 'red',
        }}
      />

      <Item
        style={{
          position: 'absolute',
          bottom: 0,
          start: 0,
          width: 100,
          height: 60,
          backgroundColor: 'red',
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
