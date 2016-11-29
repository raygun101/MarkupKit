FRAMEWORK=MarkupKit

BUILD=build
FRAMEWORK_PATH=$FRAMEWORK.framework

# iOS
rm -Rf $BUILD
rm -f $FRAMEWORK_PATH.tar.gz

xcodebuild archive -project $FRAMEWORK.xcodeproj -scheme $FRAMEWORK -sdk iphoneos SYMROOT=$BUILD
xcodebuild build -project $FRAMEWORK.xcodeproj -target $FRAMEWORK -sdk iphonesimulator SYMROOT=$BUILD

cp -RL $BUILD/Release-iphoneos $BUILD/Release-universal

lipo -create $BUILD/Release-iphoneos/$FRAMEWORK_PATH/$FRAMEWORK $BUILD/Release-iphonesimulator/$FRAMEWORK_PATH/$FRAMEWORK -output $BUILD/Release-universal/$FRAMEWORK_PATH/$FRAMEWORK

tar -czv -C $BUILD/Release-universal -f $FRAMEWORK.framework.tar.gz $FRAMEWORK_PATH

#tvOS
rm -Rf $BUILD.tvOS
rm -f $FRAMEWORK_PATH.tvOS.tar.gz

xcodebuild archive -project $FRAMEWORK.xcodeproj -scheme $FRAMEWORK.tvOS -sdk appletvos SYMROOT=$BUILD.tvOS
xcodebuild build -project $FRAMEWORK.xcodeproj -target $FRAMEWORK.tvOS -sdk appletvsimulator SYMROOT=$BUILD.tvOS

cp -RL $BUILD.tvOS/Release-appletvos $BUILD.tvOS/Release-universal

lipo -create $BUILD.tvOS/Release-appletvos/$FRAMEWORK_PATH/$FRAMEWORK $BUILD.tvOS/Release-appletvsimulator/$FRAMEWORK_PATH/$FRAMEWORK -output $BUILD.tvOS/Release-universal/$FRAMEWORK_PATH/$FRAMEWORK

tar -czv -C $BUILD.tvOS/Release-universal -f $FRAMEWORK.framework.tvOS.tar.gz $FRAMEWORK_PATH

# Templates
rm -f XcodeTemplates.tar.gz

tar -czv -f XcodeTemplates.tar.gz Xcode
