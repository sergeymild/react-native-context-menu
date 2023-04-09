import * as React from 'react';
import { viewHelpers } from 'react-native-jsi-view-helpers';

import {
  findNodeHandle,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { useRef } from 'react';
import { showContextMenu } from 'react-native-context-menu';

export default function App() {
  const ref = useRef<TouchableOpacity>(null);
  const ref2 = useRef<TouchableOpacity>(null);

  return (
    <View style={styles.container}>
      <TouchableOpacity
        activeOpacity={1}
        style={styles.box}
        ref={ref}
        onPress={async () => {
          console.log('[App.--]', viewHelpers.measureView(ref));
          showContextMenu({
            viewTargetId: findNodeHandle(ref.current)!,
            rect: viewHelpers.measureView(ref),
            bottomMenuItems: [
              { id: 'copy', title: 'Copy' },
              { id: 'delete', title: 'Delete' },
            ],
          });
        }}
      />
      <TouchableOpacity
        style={{
          backgroundColor: 'purple',
          height: 56,
          position: 'absolute',
          bottom: 0,
          opacity: 1,
          alignSelf: 'center',
        }}
        activeOpacity={1}
        ref={ref2}
        onPress={async () => {
          showContextMenu({
            viewTargetId: findNodeHandle(ref2.current)!,
            rect: viewHelpers.measureView(ref2),
            bottomMenuItems: [
              { id: 'copy', title: 'Copy' },
              { id: 'delete', title: 'Delete' },
            ],
          });
        }}
      >
        <Text style={{ backgroundColor: 'red' }}>Lorem ipsum</Text>
      </TouchableOpacity>
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
  },
});
