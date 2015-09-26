# Overview
MarkupKit is a framework for simplifying development of native iOS applications. It allows developers to construct user interfaces declaratively using a human-readable markup language, rather than programmatically in code or interactively using a visual modeling tool such as Interface Builder.

Building an interface in markup makes it easy to visualize the resulting output as well as recognize differences between revisions. It is also a metaphor that many developers are comfortable with, thanks to the ubiquity of HTML and the World Wide Web. 

For example, the following markup declares an instance of `UILabel` and sets the value of its `text` property to "Hello, World!":

    <UILabel text="Hello, World!"/>

The output produced by this markup is identical to the output of the following code:

    let label = UILabel()
    label.text = "Hello, World!"

The next section describes the structure of a MarkupKit document and explains how view instances are created and configured in markup. The remaining sections introduce the classes included with the MarkupKit framework and describe how they can be used to help simplify application development. Extensions to several UIKit classes that adapt their respective types for use in markup are also discusssed.

MarkupKit requires iOS 8 or later.

# Document Structure
MarkupKit uses XML to define the structure of a user interface. In a MarkupKit document, XML elements represent instances of `UIView` subclasses, and XML attributes represent properties of or actions associated with those views. The hierarchical nature of XML parallels the view hierarchy of a UIKit application, making it easy to understand the relationships between views. 

For example, the following markup produces an instance of `LMTableViewCell`, a MarkupKit-provided subclass of `UITableViewCell`, containing a `UIImageView`. The `image` property of the image view is set to an image named "world.png":

    <LMTableViewCell>
        <UIImageView image="world.png"/>
    </LMTableViewCell>

How the value of the "image" attribute is converted to an instance of `UIImage` is discussed in more detail later.

## Elements
Elements in a MarkupKit document represent instances of `UIView` or its subclasses. As elements are read by the XML parser, the corresponding class instances are dynamically created and added to the view hierarchy. 

In general, the `new` method is called on the named type to create the class instance. However, in some cases, it is necessary to invoke a named factory method to create the instance. This is discussed in more detail later.

MarkupKit adds the following method to the `UIView` class to facilitate construction of a view hierarchy from markup:

    - (void)appendMarkupElementView:(UIView *)view;

This method is called on the superview of every view defined in the document except for the root (which has no superview) to add the view to its parent. The default implementation does nothing; subclasses must override this method to implement view-specific behavior. 

For example, `LMTableView` (a MarkupKit-provided subclass of `UITableView`) overrides this method to call `insertCell:forRowAtIndexPath:` on itself, and  `LMScrollView` overrides it to call `setContentView:`. Other classes that support sub-elements provide similar overrides.

## Attributes
XML attributes in a MarkupKit document generally represent either view properties or actions associated with a view. For example, the following markup declares an instance of `UISwitch` and sets the value of its `on` property to `true`:

    <UISwitch on="true"/>

Property values are set using key-value coding (KVC). Type conversions for string, number, and boolean properties are handled automatically by KVC. Other types, such as enumerations, colors, fonts, and images, require special handling and are discussed in more detail below.

MarkupKit uses `setValue:forKeyPath:` to apply property values, so it is possible to set properties of nested objects in markup. For example, the following markup creates an instance of `UIButton` whose title label's `font` property is set to "Helvetica-Bold 32":

    <UIButton style="systemButton" 
        normalTitle="Press Me!" 
        titleLabel.font="Helvetica-Bold 32"/>

With the exception of a few properties whose names begin with "on" (including the `on` property itself), attributes whose names begin with "on" represent control events. The value of these attributes represents the name of the event handler, or "action", that is triggered when the event is fired. For example, the following markup declares an instance of `UISwitch` with an action handler that will be triggered when the switch's value changes:

    <UISwitch onValueChanged="handleSwitchValueChanged:"/>

Actions are also discussed in more detail below.

A few attributes have special meaning in MarkupKit and cannot be used as property names. These include "style", "class", and "id". Their respective purposes are explained in more detail later.

### Enumerations
Enumerated types are not automatically handled by KVC. However, MarkupKit provides translations for enumerations commonly used by UIKit. For example, the following markup creates an instance of `UITextField` that displays a clear button only while the user is editing and presents a software keyboard suitable for entering email addresses:

    <UITextField placeholder="Email Address" 
        clearButtonMode="whileEditing"
        keyboardType="emailAddress"/>

Enumeration values in MarkupKit are abbreviated versions of their UIKit counterparts. The MarkupKit value is simply the full name of the enum value minus the leading enum type name, with a lowercase first character. For example, "whileEditing" in the above example maps to the `UITextFieldViewModeWhileEditing` value of the `UITextFieldViewMode` enum. Similarly, `emailAddress` maps to the `UIKeyboardTypeEmailAddress` value of the `UIKeyboardType` enum. 

Note that values are translated to enum types based on the attribute's name, not its value. For example, the following markup will set the value of the label's `text` property to the literal string "whileEditing", not the `UITextFieldViewModeWhileEditing` enum value:

    <UILabel text="whileEditing"/>

### Colors

Colors in MarkupKit are represented by their hexadecimal value preceded by a hash symbol; e.g. `#ededed`. The value of any attribute whose name equals "color" or ends with "Color" is considered a color and is converted from its hexadecmial representation to an instance of `UIColor` before the property value is set.

For example, the following markup creates an instance of `UILabel` that reads "A Red Label" and sets its text color to red:

    <UILabel text="A Red Label" textColor="#ff0000"/>

### Fonts

Fonts in MarkupKit can be specified in two ways:

* As an explicitly named font, using the full name of the font, followed by a space and the font size; for example, "HelveticaNeue-Medium 24"
* As a dynamic font, using the name of the text style; e.g. "headline"

The current system font can be specified by using "System" as the font name. "System-Bold" and "System-Italic" are also supported.

The value of any attribute whose name equals "font" or ends with "Font" is converted to an instance of `UIFont` using the given font name and size or the given text style before the property value is set.

For example, the following markup creates a `UILabel` that reads "This is Helvetica 24 text" and sets its font to 24-point Helvetica:

    <UILabel text="This is Helvetica 24 text" font="Helvetica 24"/>

This markup creates a `UILabel` that reads "This is headline text" and sets its font to whatever is currently configured for the "headline" text style:

    <UILabel text="This is headline text" font="headline"/>

### Images

The value of any attribute whose name is "image" or ends with "Image" is considered an image and is converted to an instance of `UIImage` before the property value is set. The value specified in markup is considered the name of the image and is used to load the image from the application's main bundle via the `imageNamed:` method of the `UIImage` class.

For example, the following markup creates an instance of `UIImageView` and sets the value of its `image` property to an image named "background.png":

    <UIImageView image="background.png"/>
    
The image is loaded as described in the documentation for `imageNamed:`.

### Layout Margins and Content Edge Insets

`UIView` allows a developer to specify the amount of space that should be reserved around all subviews when laying out the user interface. This value is called the view's "layout margins" and is represented by an instance of the `UIEdgeInsets` structure. 

Since structure types aren't supported by XML, MarkupKit provides a shorthand for specifying layout margin values. For the "layoutMargins" attribute, a single numeric value may be specified, which will be applied to all of the edge inset structure's components (`top`, `left`, `bottom`, and `right`).

For example, the following markup creates an instance of `LMTableViewCell` with top, left, bottom, and right layout margin values of 20:

    <LMTableViewCell layoutMargins="20">
        ...
    </LMTableViewCell>

A button's content edge insets can also be specified using this shorthand. For example:

    <UIButton normalTitle="Click Me!" contentEdgeInsets="12"/>

Additionally, MarkupKit adds properties to `UIView` and `UIButton` that allow layout margin and content edge inset components to be specified individually. This is discussed in more detail later.

### Localization
If an attribute does not fall into any of the previous categories and its value begins with "@", MarkupKit attempts to look up a localized version of the value before setting the property. For example, if an application has defined a localized greeting in _Localizable.strings_ as follows:

    "hello" = "Hello, World!";

the following markup will produce an instance of `UILabel` with the value of its `text` property set to "Hello, World!":

    <UILabel text="@hello"/>

By default, MarkupKit will attempt to localize strings by calling `localizedStringForKey:value:table:` on the application's main bundle with a `nil` value for the `table` argument. The attribute's value is passed as both the `key` and the `value` arguments, so values that do not have localized versions appear exactly as they are specified in markup. 

For example, assuming that an application does not provide a localized value for "goodbye", the following markup would create an instance of `UILabel` containing the literal text "goodbye":

    <UILabel text="@goodbye"/>

In addition to the global values defined in _Localizable.strings_, the `strings` processing instruction can be used to define a set of local string values that are only visible to the current document. 

For example, if the application additionally provides the following localized value in a file named _MyStrings.strings_:
    
    "goodbye" = "Goodbye!";

this markup would produce a table view containing two rows reading "Hello, World!" and "Goodbye!":
    
    <?strings MyStrings?>
    
    <LMTableView>
        <LMTableViewCell>
            <UILabel text="@hello"/>
        </LMTableViewCell>
        
        <LMTableViewCell>
            <UILabel text="@goodbye"/>
        </LMTableViewCell>
    </LMTableView>

Multiple `strings` PIs may be specified in a single document. The values from all of the named string tables are merged into a single collection of localized string values available to the document. If the same value is defined by multiple tables (including the default, _Localizable.strings_), the most recently-defined value takes precedence.

### Factory Methods
Some UIKit classes can't be instantiated by simply invoking the `new` method on the type. For example, instances of `UIButton` must be created by calling the `buttonWithType:` method of the `UIButton` class. Similarly, `UITableView` instances are initialized by calling `initWithFrame:style` on the table view instance, not the no-arg `init` method that is invoked by `new`.

MarkupKit doesn't know anything about methods - only instances and properties/events. To handle these cases, MarkupKit supports a special attribute named "style". The value of this attribute is considered the name of a "factory method", a zero-argument method that produces instances of a given type. MarkupKit adds a number of factory methods to classes such as `UIButton` and `UITableView` to enable these types to be constructed in markup.

For example, the following markup creates an instance of a "system"-style `UIButton` by calling the `systemButton` method MarkupKit adds to the `UIButton` class:

    <UIButton style="systemButton" normalTitle="Press Me!"/>

The complete set of extensions MarkupKit adds to UIKit types is discussed in more detail later.

### Template Properties
Often, when constructing a user interface, the same set of property values are applied repeatedly to instances of a given type. For example, an application designer may want all buttons to have a similar appearance. While it is possible to simply duplicate the property definitions for each button instance, this is repetitive and does not allow the design to be easily modified later - each button instance must be located and modified individually, which can be time-consuming and error-prone.

MarkupKit allows developers to abstract common sets of property definitions into "templates", which can then be applied by name to class instances. This makes it much easier to assign common property values as well as modify them later.

Property templates are defined in property list (or _.plist_) files. Each template is represented by a dictionary defined at the top level of the property list. The dictionary's contents represent the property values that will be set when the template is applied.

Templates are added to a MarkupKit document using the `properties` processing instruction. For example, the following PI imports all templates defined by _MyStyles.plist_ into the current document:

    <?properties MyStyles?>

Templates are applied to class instances using the reserved "class" attribute. The value of this attribute refers to the name of a template defined by the property list. All property values defined by the template are applied to the class instance. Nested properties such as "titleLabel.font" are supported by property templates.

For example, assuming that _MyStyles.plist_ defines a dictionary named "label.hello" that contains the following values (abbreviated for clarity):

    "label.hello": {
        "font": "Helvetica 24"
        "textAlignment": "center"
    }
    
the following markup would produce a label reading "Hello, World!" in 24-point Helvetica with horizontally-centered text:

    <UILabel class="label.hello" text="Hello, World!"/>

Although attribute values in XML are always specified as strings, the property values in a template definition can be any supported type; for example, if a property accepts a numeric type, the value can be defined as a Number in the property list. However, this is not stricly necessary since strings will automatically be converted to the appropriate type by KVC.

Like `strings` processing instructions, multiple `properties` PIs may be specified in a single document. Their contents are merged into a single collection of templates available to the document. If the same template is defined by multiple property lists, the contents of the templates are merged into a single template. As with strings, the most recently-defined values take precedence.

### Outlets
Views defined in markup are not particularly useful on their own. The reserved "id" attribute can be used to give a name to a view instance. Assigning a view an ID defines an "outlet" for the view and makes it accessible to calling code. Using KVC, MarkupKit "injects" the named view instance into the document's owner (generally either the view controller for the root view or the root view itself), allowing application code to interact with it. Specifically, it calls `setValue:forKey` on the owner object to set the outlet value. See the _Key-Value Programming Guide_ for more information.

For example, the following markup declares an instance of `LMTableView` containing a `UITextField`. The text field is assigned an ID of "textField":

    <LMTableView>
        <LMTableViewCell>
            <UITextField id="textField" placeholder="Type something"/>
        </LMTableViewCell>
    </LMTableView>

The owning class might declare an outlet for the table view in Objective-C as follows:

    @property (nonatomic) UITextField *textField;
    
or in Swift as follows:

    var textField: UITextField!

In either case, when the document is loaded, the outlet will be populated with the text field instance, and the application can interact with it just as if it was created programmatically. 

Note that the `IBOutlet` annotation used by Interface Builder to tag outlets is also supported by MarkupKit, but is not required.

### Actions
Most non-trivial applications need to respond in some way to user interaction. UIKit controls (subclasses of the `UIControl` class) fire events that notify an application when such interaction has occurred. For example, the `UIButton` class fires the `UIControlEventTouchUpInside` event when a button instance is tapped.

While it would be possible for an application to register for events programmatically using outlets, MarkupKit provides a more convenient alternative. An attribute whose name begins with "on" (but is not equal to "on") is considered a control event. The value of the attribute represents the name of the action that will be triggered when the event is fired. The name of the attribute is simply the "on" prefix followed by the name of the event, minus the "UIControlEvent" prefix.

For example, the following markup declares an instance of `UIButton` that calls the `handleButtonTouchUpInside:` method of the document's owner when the button is tapped:

    <UIButton style="systemButton" normalTitle="Press Me!" 
        onTouchUpInside="handleButtonTouchUpInside:"/>

Like `IBOutlet`, MarkupKit supports the `IBAction` annotation used by Interface Builder, but does not require it.

## Processing Instructions
In addition to the document-wide `strings` and `properties` PIs mentioned earlier, MarkupKit also supports view-specific processing instructions. These allow developers to provide additional information to the view that can't be easily specified as an attribute value or subview. 

MarkupKit adds a `processMarkupInstruction:data:` method to the `UIView` class to facilitate PI handling at the view level. The `LMTableView` class overrides this method to support section header and footer declarations. An extension to `UISegmentedControl` overrides it to support segment title and image declarations. Both classes are discussed in more detail below.

# MarkupKit Classes
The remaining sections introduce the classes included with the MarkupKit framework:

* `LMViewBuilder` - processes a markup document, deserializing its contents into a view hierarchy that can be used by a Cocoa Touch application
* `LMTableView` and `LMTableViewCell` - table view types that simplify the definition of static table view content
* `LMScrollView` - scroll view that automatically adapts to the size of its content
* `LMRowView` and `LMColumnView` - layout views that arrange subviews in either a horizontal or vertical line, respectively
* `LMSpacer` - view that creates flexible space between other views
* `LMLayerView` - layout view that arranges subviews in layers, like a stack of transparencies

Extensions to several UIKit classes that adapt their respective types for use in markup are also discusssed.

## LMViewBuilder
`LMViewBuilder` is the class that is actually responsible for loading a MarkupKit document. It defines the following class method, which, given a document name, owner, and optional root view, returns a deserialized view hierarchy: 

    + (UIView *)viewWithName:(NSString *)name owner:(id)owner root:(UIView *)root;

The `name` parameter represents the name of the view to load. It is the name of the XML document that defines the view minus the _.xml_ extension.

The `owner` parameter represents the view's owner. It is often an instance of `UIViewController`, but this is not required. For example, custom table view cell instances often pass themselves as the owner.

The `root` parameter represents the root view that will be used when the document is loaded. This value is often `nil`, meaning that the root view will be specified by the document itself. However, when non-`nil`, it means that the root view is being provided by the caller. The reserved `<root>` tag can be used as the document's root element to refer to this view.

For example, if an instance of `LMScrollView` is passed as the `root` argument to `viewWithName:owner:root:`, this markup:

    <root>
        <UIImageView image="world.png"/>
    </root>

will produce exactly the same output as this:

    <LMScrollView>
        <UIImageView image="world.png"/>
    </LMScrollView>    

The `root` argument is typically used when a document's root view is defined by an external source. For example, a view controller that is instantiated programmatically typically creates its own view instance in `loadView`. It defines the view entirely in markup, passing a `nil` value for `root`:

    - (void)loadView
    {
        [self setView:[LMViewBuilder viewWithName:@"MyView" owner:self root:nil]];
    }

However, a view controller that is defined by a storyboard already has an established view instance when `viewDidLoad` is called. The controller can pass itself as the view's owner and the value of the controller's `view` property as the `root` argument:

    - (void)viewDidLoad
    {
        [super viewDidLoad];

        [LMViewBuilder viewWithName:@"MyView" owner:self root:[self view]];    
    }

This allows the navigational structure of the application (i.e. segues) to be defined in a storyboard, but the content of individual views to be defined in markup.

The `root` argument is also commonly used when implementing custom table view cells. In this case, the cell passes itself as both the owner and the root when loading the view: 

    - (instancetype)initWithStyle:(UITableViewCellStyle)style 
        reuseIdentifier:(NSString *)reuseIdentifier
    {
        self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

        if (self) {
            [LMViewBuilder viewWithName:@"MyCustomTableViewCell" 
                owner:self root:self];
        }

        return self;
    }

Additionally, `LMViewBuilder` defines the following two class methods, which it uses to decode color and font values:

    + (UIColor *)colorValue:(NSString *)value;
    + (UIFont *)fontValue:(NSString *)value;

## LMTableView and LMTableViewCell
The `LMTableView` and `LMTableViewCell` classes allow the structure and content of a table view to be defined in markup, rather than in code via a data source and delegate. `LMTableView` is a subclass of `UITableView` that acts as its own data source/delegate, serving cells from a statically-defined collection of table view sections. `LMTableViewCell` is a subclass of `UITableViewCell` that provides a vehicle for defining custom cell content in markup. It serves as a host for a single "content element view" that represents the actual content of the cell. 

MarkupKit provides extensions to the standard `UITableView` and `UITableViewCell` classes that allow them to be used in markup as well. These are discussed in more detail below.

### LMTableView
`LMTableView` supports the definition of statically-defined table content in markup. It inherits the following factory methods defined by the markup extensions to the `UITableView` class:

    + (LMTableView *)plainTableView;
    + (LMTableView *)groupedTableView;

These methods support the declaration of styled table view instances in markup and are discussed in more detail later.

For example, the following markup declares a plain `LMTableView` containing three rows labeled "Row 1", "Row 2", and "Row 3". All of the rows appear in a single section, which is created by default:

    <LMTableView style="plainTableView">
        <UITableViewCell textLabel.text="Row 1"/>
        <UITableViewCell textLabel.text="Row 2"/>
        <UITableViewCell textLabel.text="Row 3"/>
    </LMTableView>

The `sectionBreak` processing instruction is used to insert a new section. It corresponds to a call to the `insertSection:` method of `LMTableView`. The following markup creates a grouped table view containing two sections:

    <LMTableView style="groupedTableView">
        <UITableViewCell textLabel.text="Row 1a"/>
        <UITableViewCell textLabel.text="Row 1b"/>
        <UITableViewCell textLabel.text="Row 1c"/>

        <?sectionBreak?>

        <UITableViewCell textLabel.text="Row 2a"/>
        <UITableViewCell textLabel.text="Row 2b"/>
        <UITableViewCell textLabel.text="Row 2c"/>
    </LMTableView>

The `sectionHeaderView` processing instruction assigns a header view to the current section. It corresponds to a call to the `setView:forHeaderInSection:` method of `LMTableView`. The view element immediately following the PI is used as the header view for the section. For example, the following markup adds a section header view to the default section:

    <LMTableView style="groupedTableView">
        <?sectionHeaderView?>
        <UITableViewCell textLabel.text="Section 1"/>

        <UITableViewCell textLabel.text="Row 1"/>
        <UITableViewCell textLabel.text="Row 1"/>
        <UITableViewCell textLabel.text="Row 1"/>
    </LMTableView>

Note that, although this example uses an instance of `UITableViewCell` as a section header, header views are not limited to table view cells. Any `UIView` subclass can be used as a section header view.

The `sectionFooterView` processing instruction assigns a footer view to the current section. It corresponds to a call to the `setView:forFooterInSection:` method of `LMTableView`. The view element immediately following the PI is used as the footer view for the section:

    <LMTableView style="groupedTableView">
        <?sectionHeaderView?>
        <UITableViewCell textLabel.text="Section 1 Start"/>

        <UITableViewCell textLabel.text="Row 1"/>
        <UITableViewCell textLabel.text="Row 1"/>
        <UITableViewCell textLabel.text="Row 1"/>

        <?sectionFooterView?>
        <UITableViewCell textLabel.text="Section 1 End"/>
    </LMTableView>

As with header views, footers views are not limited to instances of `UITableViewCell`; any `UIView` subclass can be used as a footer.

The `sectionName` processing instruction is used to assign a name to a section. It corresponds to a call to the `setName:forSection:` method of `LMTableView`. This allows sections to be identified in code by name rather than index, allowing sections to be added or re-ordered without breaking controller code. For example:

    <LMTableView style="groupedTableView">
        <?sectionName firstSection?>
        <UITableViewCell textLabel.text="Row 1a"/>
        <UITableViewCell textLabel.text="Row 1b"/>
        <UITableViewCell textLabel.text="Row 1c"/>

        <?sectionBreak?>

        <?sectionName secondSection?>
        <UITableViewCell textLabel.text="Row 2a"/>
        <UITableViewCell textLabel.text="Row 2b"/>
        <UITableViewCell textLabel.text="Row 2c"/>
    </LMTableView>

Finally, the `sectionSelectionMode` processing instruction is used to set the selection mode for a section. It corresponds to a call to the `setSelectionMode:forSection:` method of `LMTableView`. Valid values for this PI include "default", "singleCheckmark", and "multipleCheckmarks". The "default" option produces the default selection behavior; the application is responsible for managing selection state. The "singleCheckmark" option ensures that only a single row will be checked in the section at a given time, similar to a group of radio buttons. The "multipleCheckmarks" option causes the checked state of a row to be toggled each time the row is tapped, similar to a group of checkboxes.

For example, the following markup creates a table view that allows a user to select a color:

    <LMTableView style="groupedTableView">
        <?sectionSelectionMode singleCheckmark?>
        <UITableViewCell textLabel.text="Red" value="#ff0000"/>
        <UITableViewCell textLabel.text="Green" value="#00ff00"/>
        <UITableViewCell textLabel.text="Blue" value="#0000ff"/>
    </LMTableView>

The `value` property is defined by the MarkupKit extensions to the `UITableViewCell` class. It is used to associate an optional value with a cell, such as the color values shown in the previous example. 

Selection state is managed via several methods MarkupKit adds to the `UITableView` class whose behavior is provided by `LMTableView`. This is discussed in more detail later.

Note that, in order to support the static declaration of content, `LMTableView` acts as its own data source and delegate. However, an application-specific delegate may still be set on an `LMTableView` instance to handle row selection events. `LMTableView` will propagate the following `UITableViewDelegate` calls to the custom delegate:

* `tableView:willSelectRowAtIndexPath:`
* `tableView:didSelectRowAtIndexPath:`
* `tableView:willDeselectRowAtIndexPath:`
* `tableView:didDeselectRowAtIndexPath:`

Also note that `LMTableView` sets the `estimatedRowHeight`, `estimatedSectionHeaderHeight`, and `estimatedSectionFooterHeight` properties to enable self-sizing content by default. It is not necessary to set these properties manually to enable self-sizing content.

Use of the `LMTableView` class is not limited to markup. `LMTableView` cells and sections can also be managed programmatically. See _LMTableView.h_ for more information.

### LMTableViewCell
`LMTableViewCell` supports the declaration of custom cell content in markup. It can be used when the content options provided by the default `UITableViewCell` class are not sufficient. For example, the following markup creates a plain table view containg a single cell that presents an instance of `UIDatePicker`:

    <LMTableView style="plainTableView">
        <LMTableViewCell>
            <UIDatePicker datePickerMode="date"/>
        </LMTableViewCell>
    </LMTableView>

The date picker will be set as the cell's content element view and will be automatically sized to fill the width and height of the cell.

`UITableViewCell` defines several factory methods that are inherited by `LMTableViewCell` and are discussed in more detail below. However, these are used primarily to create instances of the default cell view types and are not commonly used in conjunction with custom cell content.

Since `LMTableViewCell` ultimately inherits from `UIView`, it is possible to specify the amount of padding around the cell view's content using the "layoutMargins" attribute. For example, the following markup declares a plain table view containing a single cell with 20 pixels of space reserved around the label:

    <LMTableView style="plainTableView">
        <LMTableViewCell layoutMargins="20">
            <UILabel text="Hello, World!"/>
        </LMTableViewCell>
    </LMTableView>

Finally, as discussed earlier, `LMTableViewCell` can also be used as the base class for custom table view cell classes. By overriding `initWithStyle:reuseIdentifier:` and specifying the cell view as the document owner, callers can easily create custom table view cells whose content and behavior is expressed in markup rather than in code. 

See _LMTableViewCell.h_ for more information.

## LMScrollView
The `LMScrollView` class extends the standard `UIScrollView` class to simplify the definition of a scroll view's content in markup. It presents a single content view at a time, optionally scrolling in one or both directions. As noted earlier, `LMScrollView` defines a `contentView` property representing this content, and overrides `appendMarkupElementView:` to set the value of this property in markup.

In addition to `contentView`, `LMScrollView` defines the following properties:

    @property (nonatomic) BOOL fitToWidth;
    @property (nonatomic) BOOL fitToHeight;

When both properties are set to `false` (the default), the scroll view will automatically display scroll bars when needed, allowing the user to pan in both directions to see the content in its entirety. For example:

    <LMScrollView>
        <UIImageView image="large_image.png"/>
    </LMScrollView>

When `fitToWidth` is set to `true`, the scroll view will ensure that the width of its content matches its own width, causing the content to wrap and scroll in the vertical direction. The vertical scroll bar will be displayed when necessary, but the horizontal scroll bar will never be shown, since the width of the content will never exceed the width of the scroll view:

    <LMScrollView fitToWidth="true">
        <UILabel text="Lorem ipsum dolor sit amet, consectetur adipiscing..."
            numberOfLines="0"/>
    </LMScrollView>

Similarly, when `fitToHeight` is `true`, the scroll view will ensure that the height of its content matches its own height, causing the content to wrap and scroll in the horizontal direction. The vertical scroll bar will never be shown, and the horizontal scroll bar will appear when necessary.

See _LMScrollView.h_ for more information.

## LMLayoutView
Autolayout is an iOS feature that allows developers to create applications that automatically adapt to device orientation or content changes. An application built using autolayout generally has little or no hard-coded view widths or heights, but instead dynamically arranges user interface elements based on their preferred or "intrinsic" content sizes.

Autolayout in iOS (as well as Mac OS X) is implemented via layout constraints, which are instances of the `NSLayoutConstraint` class. While layout constraints are powerful, they can be cumbersome to work with. MarkupKit provides several classes that simplify the process of adding autolayout to an iOS application. They encode specific layout behaviors in `UIView` subclasses whose sole responsibility is managing the arrangement of an application's user interface elements: 

* `LMRowView` - view that arranges subviews in a horizontal line
* `LMColumnView` - view that arranges subviews in a vertical line
* `LMLayerView` - view that arranges subviews in layers, like a stack of transparencies

These classes use layout constraints internally, but abstract the details away from the developer. When used in markup, they can help the developer more easily visualize the resulting output. However, they can also be created and manipulated programmatically to provide dynamic layout behavior.

All layout view types extend the abstract `LMLayoutView` class, which defines the following methods:
    
    - (void)addArrangedSubview:(UIView *)view;
    - (void)insertArrangedSubview:(UIView *)view atIndex:(NSUInteger)index;
    - (void)removeArrangedSubview:(UIView *)view;

These methods manage the list of the layout view's "arranged subviews", which are the subviews whose size and position will be managed automatically by the layout view. `LMLayoutView` also defines a read-only property that returns the current list of arranged subviews:

    @property (nonatomic, readonly, copy) NSArray *arrangedSubviews;

Additionally, `LMLayoutView` provides the following property:

    @property (nonatomic) BOOL layoutMarginsRelativeArrangement;

This value specifies that subviews will be arranged relative to the view's layout margins. The default value is `true`. However, in some cases, `UIKit` provides default non-overridable values for a view's margins. In these cases, setting this flag to `false` instructs the view to ignore margins altogether and align subviews to the layout view's edges directly. 

Views whose `hidden` property is set to `true` are ignored when performing layout. Layout views listen for changes to this property on their arranged subviews and automatically relayout as needed.

Layout views do not consume touch events. Touches that occur within a layout view but do not intersect with a subview are ignored, allowing the event to pass through the view. This allows layout views to be "stacked", and is discussed in more detail later.

`LMLayoutView` overrides `appendMarkupElementView:` to call `addArrangedSubview:` so that layout views can be easily constructed in markup. Additionally, layout views can be nested to create complex layouts that automatically adjust to orientation or screen size changes. 

All three layout view types are discussed in more detail in the following sections. See _LMLayoutView.h_ for more information.

## LMRowView and LMColumnView
The `LMRowView` and `LMColumnView` classes lay out subviews in either a horizontal or vertical line, respectively. Both classes extend the abstract `LMBoxView` class, which itself extends `LMLayoutView` and adds the following properties:

    @property (nonatomic) LMBoxViewAlignment alignment;
    @property (nonatomic) CGFloat spacing;

The `alignment` property specifies how content should be aligned within a box view. It must be one of the following values, defined by the `LMBoxViewAlignment` enumeration:

* `LMBoxViewAlignmentTop` 
* `LMBoxViewAlignmentBottom` 
* `LMBoxViewAlignmentLeft` 
* `LMBoxViewAlignmentRight` 
* `LMBoxViewAlignmentLeading` 
* `LMBoxViewAlignmentTrailing` 
* `LMBoxViewAlignmentCenter` 
* `LMBoxViewAlignmentBaseline` 
* `LMBoxViewAlignmentFill` 

`LMBoxViewAlignmentTop`, `LMBoxViewAlignmentBottom`, and `LMBoxViewAlignmentBaseline` apply to `LMRowView` instances, which align content vertically within a row. `LMBoxViewAlignmentLeft`, `LMBoxViewAlignmentRight`, `LMBoxViewAlignmentLeading`, and `LMBoxViewAlignmentTrailing` apply to `LMColumnView` instances, which align content horizontally. 

`LMBoxViewAlignmentLeading` and `LMBoxViewAlignmentTrailing` are relative to the text direction used by the system language. For left-to-right languages, "leading" refers to the left edge and trailing to the right. For right-to-left languages, "leading" refers to the right edge and trailing to the left. 

`LMBoxViewAlignmentCenter` and `LMBoxViewAlignmentFill` apply to both row and column views. The default alignment for both view types is`LMBoxViewAlignmentFill`.

The `spacing` property represents the amount of spacing between successive subviews. For row views, this refers to the horizontal space between subelements; for column views, it refers to the vertical space between subviews.

Subviews are always pinned along the box view's primary axis. This ensures that there is no ambiguity regarding a subview's placement and allows the autolayout system to correctly calculate the view's size and position.

See _LMBoxView.h_ for more information.

### LMRowView
The `LMRowView` class arranges its subviews in a horizontal line. For example, the following markup creates a row view containing three labels:

    <LMRowView>
        <UILabel text="One"/>
        <UILabel text="Two"/>
        <UILabel text="Three"/>
    </LMRowView>

Because the default alignment setting is "fill", the top and bottom edges of each subview will be pinned to the top and bottom edges of the row (excluding layout margins), ensuring that all of the labels are the same height. 

This markup creates a row view containing three labels, all with different font sizes:

    <LMRowView alignment="baseline">
        <UILabel text="One" font="Helvetica 12"/>
        <UILabel text="Two" font="Helvetica 24"/>
        <UILabel text="Three" font="Helvetica 48"/>
    </LMRowView>
    
Because the alignment is set to "baseline", the labels will be given their intrinsic sizes, and the baselines of all three labels will line up.

### LMColumnView
The `LMColumnView` class arranges its subviews in a vertical line. For example, the following markup creates a column view containing three labels:

    <LMColumnView>
        <UILabel text="One"/>
        <UILabel text="Two"/>
        <UILabel text="Three"/>
    </LMColumnView>

Because the default alignment setting is "fill", the left and right edges of each subview will be pinned to the left and right edges of the row (excluding layout margins), ensuring that all of the labels are the same width.

The labels in this column view will be given their intrinsic sizes and will be left-aligned within the column view:

    <LMColumnView alignment="left">
        <UILabel text="One"/>
        <UILabel text="Two"/>
        <UILabel text="Three"/>
    </LMColumnView>

`LMColumnView` defines the following additional property, which specifies that nested subviews should be vertically aligned in a grid, or table: 

    @property (nonatomic) BOOL alignToGrid;

For example, the following markup would produce a table containing three rows:

    <LMColumnView alignToGrid="true">
        <LMRowView>
            <UILabel text="First row"/>
            <UILabel weight="1" text="This is row number one."/>
        </LMRowView>

        <LMRowView>
            <UILabel text="Second row"/>
            <UILabel weight="1" text="This is row number two."/>
        </LMRowView>

        <LMRowView>
            <UILabel text="Third row"/>
            <UILabel weight="1" text="This is row number three."/>
        </LMRowView>
    </LMColumnView>

Note that, when `alignToGrid` is set to `true`, the contents of the column view must be `LMRowView` instances containing the cells for each row.

Finally, `LMColumnView` defines two properties that specify the amount of space that should be reserved at the top and bottom of the view, respectively:

    @property (nonatomic) CGFloat topSpacing;
    @property (nonatomic) CGFloat bottomSpacing;
    
These properties can be used to ensure that the column view's content is not obscured by another user interface element such as the status bar or a navigation bar. 

For example, a view controller class might override the `viewWillLayoutSubviews` method to set the top spacing to the length of the controller's top layout guide, ensuring that the first subview is positioned below the guide:

    override func viewWillLayoutSubviews() {
        columnView.topSpacing = topLayoutGuide.length
    }

Bottom spacing can be set similarly using the controller's bottom layout guide.

### View Weights
MarkupKit adds the following property to the UIView class that is used by both `LMRowView` and `LMColumnView`:

    @property (nonatomic) CGFloat weight;

A view's weight specifies the amount of excess space the view would like to be given within its superview (once the sizes of all unweighted views have been determined) and is relative to all other weights specified within the superview. For row views, weight applies to the excess horizontal space, and for column views to the excess vertical space.

For example, since it has a weight of "1", the label in the following example will be given the entire vertical space of the column view:

    <LMColumnView>
        <UILabel weight="1" text="Hello, World!"/>
    </LMColumnView>
    
Since weights are relative, the following example will produce identical output:

    <LMColumnView>
        <UILabel weight="100" text="Hello, World!"/>
    </LMColumnView>

In this example, each label will be given 50% of the height of the column view:

    <LMColumnView>
        <UILabel weight="0.5" text="Hello"/>
        <UILabel weight="0.5" text="World"/>
    </LMColumnView>
    
Again, since weights are relative, the following markup will produce identical results:

    <LMColumnView>
        <UILabel weight="1" text="Hello"/>
        <UILabel weight="1" text="World"/>
    </LMColumnView>

Here, the first label will be given 1/6 of the available space, the second 1/3, and the third 1/2:

    <LMColumnView>
        <UILabel weight="1" text="One"/>
        <UILabel weight="2" text="Two"/>
        <UILabel weight="3" text="Three"/>
    </LMColumnView>

Weights in `LMRowView` are handled identically, but in the horizontal direction.

A common use for weights is to add flexible space around a view. For example, the following markup centers a label vertically within a column:

    <LMColumnView>
        <UIView weight="1"/>
        <UILabel text="Hello, World!"/>
        <UIView weight="1"/>
    </LMColumnView>

Similarly, the following markup centers a label horizontally within a row:

    <LMRowView>
        <UIView weight="1"/>
        <UILabel text="Hello, World!"/>
        <UIView weight="1"/>
    </LMRowView>

## LMSpacer 
Because spacer views are so common, MarkupKit provides a `UIView` subclass called `LMSpacer` for conveniently creating flexible space between other views. `LMSpacer` has a default weight of 1, so the previous example could be rewritten as follows, eliminating the "weight" attribute and improving readability:

    <LMRowView>
        <LMSpacer/>
        <UILabel text="Hello, World!"/>
        <LMSpacer/>
    </LMRowView>

Like layout views, spacer views do not consume touch events.
 
## LMLayerView
The `LMLayerView` class is arguably the simplest layout view. It simply arranges its subviews in layers, like a stack of transparencies. 

For example, the following markup declares an instance of `LMLayerView` with two sub-views. The `UIImageView` instance, since it is declared first, appears beneath the `UILabel` instance, effectively creating a background for the label:

    <LMLayerView>
        <UIImageView image="world.png" contentMode="scaleAspectFit"/>
        <UILabel text="Hello, World!" textAlignment="center"/>
    </LMLayerView>

However, layer views are not limited to defining background images. Because layout and spacer views do not consume touch events, layer views can be used to create interactive content that "floats"  over other user interface elements without preventing the user from interacting with the underlying views. 

For example, the following markup creates a layer view containing a scroll view and a column view. The column view contains a button that is aligned to the bottom of the window and floats over the scroll view. Because column views do not consume touch events, the user can still interact with the scroll view by touching anywhere except the button:

    <LMLayerView>
        <LMScrollView fitToWidth="true">
            <UILabel text="Lorem ipsum dolor sit amet, consectetur adipiscing..." 
                numberOfLines="0" lineBreakMode="byWordWrapping"/>
        </LMScrollView>

        <LMColumnView>
            <LMSpacer/>
            <LMColumnView layoutMargins="20">
                <UIButton style="customButton" normalTitle="Press Me!"
                    backgroundColor="#00aa00"/>
            </LMColumnView>
        </LMColumnView>
    </LMLayerView>

## UIKit Extensions
MarkupKit extends several UIKit classes to adapt them for use in markup. For example, as discussed earlier, some classes define a custom initializer and must be instantiated via factory methods. Additionally, features of some classes are not exposed as properties that can be set via KVC. MarkupKit adds the factory methods and property definitions required to allow these classes to be used in markup. These extensions are documented below.

Note that this section only describes classes that require extensions in order to work with markup. Types or features that are already markup-compliant are not discussed.

### UIView
In addition to the `appendMarkupElementView:` and `processMarkupInstruction:data:` methods added to `UIView` to support markup processing, MarkupKit also adds the following properties to allow the view's layout margin components to be set individually:

    @property (nonatomic) CGFloat layoutMarginTop;
    @property (nonatomic) CGFloat layoutMarginLeft;
    @property (nonatomic) CGFloat layoutMarginBottom;
    @property (nonatomic) CGFloat layoutMarginRight;
    
For example, the following markup creates a `LMTableViewCell` instance with a top layout margin of 16 pixels:

    <LMTableViewCell layoutMarginTop="16">
    ...
    </LMTableViewCell>

The other layout margin components retain their default values.

### UIButton
Instances of `UIButton` are created programmtically using the `buttonWithType:` method of `UIButton`. MarkupKit adds the following factory methods to `UIButton` to allow buttons be declared in markup:

    + (UIButton *)customButton;
    + (UIButton *)systemButton;
    + (UIButton *)detailDisclosureButton;
    + (UIButton *)infoLightButton;
    + (UIButton *)infoDarkButton;
    + (UIButton *)contactAddButton;

Button content including "title", "title color", "title shadow color", "image", and "background image" is set for button states including "normal", "highlighted", "disabled", and "selected" using methods such as `setTitle:forState:`, `setImage:forState:`, etc. MarkupKit adds the following properties to `UIButton` to allow this content to be defined in markup:

    @property (nonatomic) NSString *normalTitle;
    @property (nonatomic) UIColor *normalTitleColor;
    @property (nonatomic) UIColor *normalTitleShadowColor;
    @property (nonatomic) UIImage *normalImage;
    @property (nonatomic) UIImage *normalBackgroundImage;

    @property (nonatomic) NSString *highlightedTitle;
    @property (nonatomic) UIColor *highlightedTitleColor;
    @property (nonatomic) UIColor *highlightedTitleShadowColor;
    @property (nonatomic) UIImage *highlightedImage;
    @property (nonatomic) UIImage *highlightedBackgroundImage;

    @property (nonatomic) NSString *disabledTitle;
    @property (nonatomic) UIColor *disabledTitleColor;
    @property (nonatomic) UIColor *disabledTitleShadowColor;
    @property (nonatomic) UIImage *disabledImage;
    @property (nonatomic) UIImage *disabledBackgroundImage;

    @property (nonatomic) NSString *selectedTitle;
    @property (nonatomic) UIColor *selectedTitleColor;
    @property (nonatomic) UIColor *selectedTitleShadowColor;
    @property (nonatomic) UIImage *selectedImage;
    @property (nonatomic) UIImage *selectedBackgroundImage;

For example, the following markup creates a system button with a normal title of "Press Me!" and a highlighted title of "Let Go!":

    <UIButton style="systemButton" normalTitle="Press Me!" highlightedTitle="Let Go!"/>

Finally, MarkupKit adds the following properties that allow a button's content edge insets to be set individually:

    @property (nonatomic) CGFloat contentEdgeInsetTop;
    @property (nonatomic) CGFloat contentEdgeInsetLeft;
    @property (nonatomic) CGFloat contentEdgeInsetBottom;
    @property (nonatomic) CGFloat contentEdgeInsetRight;

For example:

    <UIButton normalTitle="Click Me!" contentEdgeInsetLeft="8" contentEdgeInsetRight="8"/>

### UITableView
Instances of `UITableView` are created programmatically using the `initWithFrame:style:` method of `UITableView`. MarkupKit adds the following factory methods to `UITableView` to allow table views to be declared in markup:

    + (UITableView *)plainTableView;
    + (UITableView *)groupedTableView;

As shown in previous examples, these factory methods are used to create instances of `UITableView` in the plain or grouped style, respectively:

    <UITableView id="tableView" style="plainTableView"/>

Note that `UITableView` can only be used to declare table views whose contents will be defined programmatically. For example, the table view in the previous example is given an ID so its owner can assign a data source or delegate to it after the document has been loaded. For static table view content, `LMTableView` should be used instead.

MarkuptKit also adds the following instance methods to the `UITableView` class. The methods are added to `UITableView` so casting is not required when using an `LMTableView` with `UITableViewController`, whose `tableView` property returns an instance of `UITableView`:

    - (NSString *)nameForSection:(NSInteger)section;
    - (NSInteger)sectionWithName:(NSString *)name;
    - (NSInteger)rowForCellWithValue:(id)value inSection:(NSInteger)section;
    - (NSInteger)rowForCheckedCellInSection:(NSInteger)section

The first method returns the name that is associated with a given section. The default implementation returns `nil`. However, it is overridden by `LMTableView` to return the name of the given section, when set. The second method returns the index of a named section. The third and fourth methods return the index of a row within a given section whose cell has the given value or checked state, respectively. 

### UITableViewCell 
Instances of `UITableViewCell` are created programmatically using the `initWithStyle:reuseIdentifier:` method of `UITableViewCell`. MarkupKit adds the following factory methods to `UITableViewCell` to allow table view cells to be declared in markup:

    + (UITableViewCell *)defaultTableViewCell;
    + (UITableViewCell *)value1TableViewCell;
    + (UITableViewCell *)value2TableViewCell;
    + (UITableViewCell *)subtitleTableViewCell;

For example, the following markup declares an instance of `LMTableView` that contains three "subtitle"-style `UITableViewCell` instances:

    <LMTableView style="plainTableView">
        <UITableViewCell style="subtitleTableViewCell" 
            textLabel.text="Row 1" 
            detailTextLabel.text="This is the first row."/>
        <UITableViewCell style="subtitleTableViewCell" 
            textLabel.text="Row 2"
            detailTextLabel.text="This is the second row."/>
        <UITableViewCell style="subtitleTableViewCell" 
            textLabel.text="Row 3"
            detailTextLabel.text="This is the third row."/>
    </LMTableView>

Note that, while it is possible to use the factory methods to declare instances of custom `UITableViewCell` subclasses, this is not generally recommended. It is preferable to simply declare such classes by name. For example:

    <MyCustomTableViewCell .../>

MarkupKit additionally adds the following properties to `UITableViewCell`:

    @property (nonatomic) id value;
    @property (nonatomic) BOOL checked;
    
The `value` property is used to associate an optional value with the cell. It is used primarily with `LMTableView` checkmark selection modes. Similarly, the `checked` property is used with these modes to indicate the cell's selection state. This property is `true` when the cell is checked and `false` when unchecked.

#### Accessory Views
MarkupKit adds an implementation of `appendMarkupElementView:` to `UITableViewCell` that sets the given view as the cell's accessory view, enabling the declaration of accessory views in markup. For example, the following markup creates a cell that has a `UISwitch` as an accessory view:

    <UITableViewCell textLabel.text="This is a switch">
        <UISwitch id="switch"/>
    </UITableViewCell>

Note that `LMTableViewCell` overrides `appendMarkupElementView:` to set the cell's content element view. As a result, a view specified as a child of an `LMTableViewCell` will be sized to occupy the entire contents of the cell, not just the accessory area.

### UIProgressView
Instances of `UIProgressView` are created programmatically using the `initWithProgressViewStyle:` method. MarkupKit adds the following factory methods to `UIProgressView` to allow progress views to be declared in markup:

    + (UIProgressView *)defaultProgressView;
    + (UIProgressView *)barProgressView;

For example, the following markup declares an instance of a default-style `UIProgressView`. It is given an ID so its owner can programmatically update its progress value later:

    <UIProgressView id="progressView" style="defaultProgressView"/>

### UISegmentedControl
Instances of `UISegmentedControl` are populated using the `insertSegmentWithTitle:atIndex:animated:` and `insertSegmentWithImage:atIndex:animated` methods. MarkupKit overrides the `processMarkupInstruction:data:` to allow segmented control content to be configured in markup. The `segmentTitle` progressing instruction can be used to add a segment title to a segmented control:

    <UISegmentedControl onValueChanged="updateActivityIndicatorState:">
        <?segmentTitle Yes?>
        <?segmentTitle No?>
    </UISegmentedControl>

Similarly, the `segmentImage` PI can be used to add a segment image to a segmented control:

    <UISegmentedControl onValueChanged="updateActivityIndicatorState:">
        <?segmentImage yes.png?>
        <?segmentImage no.png?>
    </UISegmentedControl>
    
In both examples, the `updateActivityIndicatorState:` method of the document's owner will be called when the control's value changes.

### UIStackView
MarkupKit adds an implementation of `appendMarkupElementView:` to `UIStackView` that simply calls `addArrangedSubview:` on itself. This allows stack view content to be specified in markup; for example:

    <UIStackView axis="horizontal">
        <UILabel text="One"/>
        <UILabel text="Two"/>
        <UILabel text="Three"/>
        <LMSpacer/>
    </UIStackView>

### CALayer
The `layer` property of `UIView` returns a `CALayer` instance that can be used to configure properties of the view. However, the `shadowOffset` property of `CALayer` is a `CGSize`. Since structs are not supported in XML, MarkupKit adds the following methods to `CALayer` to allow the layer's shadow offset width and height to be configured independently:

    @property (nonatomic) CGFloat shadowOffsetWidth;
    @property (nonatomic) CGFloat shadowOffsetHeight;

For example, the following markup creates a system button with a shadow opacity of 0.5, radius of 10, and offset height of 3:

    <UIButton style="systemButton" normalTitle="Press Me!" normalTitleColor="#ff0000"
        backgroundColor="#aa0000"
        layer.shadowOpacity="0.5" layer.shadowRadius="10" layer.shadowOffsetHeight="3"/>

# More Information
For more information, refer to [the wiki](https://github.com/gk-brown/MarkupKit/wiki) or [the issue list](https://github.com/gk-brown/MarkupKit/issues).

