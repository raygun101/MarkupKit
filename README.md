# Overview
MarkupKit is a framework for simplifying development of Cocoa Touch applications. It allows developers to construct user interfaces declaratively using a human-readable markup language, rather than programmatically in code or interactively using a visual modeling tool such as Interface Builder.

Building an interface in markup makes it easy to visualize the resulting output and behavior as well as recognize differences between revisions. It is also a metaphor that many developers are comfortable with, thanks to the ubiquity of HTML and the World Wide Web. 

For example, the following markup declares an instance of `UILabel` and sets the value of its `text` property to "Hello, World!":

    <UILabel text="Hello, World!"/>

The next section describes the structure of a MarkupKit document and explains how view instances can be created and configured in markup. The remaining sections introduce the classes included with the MarkupKit framework and describe how they can be used to help simplify application development:

* `LMViewBuilder` - processes a markup document, deserializing its contents into a view hierarchy that can be used by a Cocoa Touch application
* `LMTableView` and `LMTableViewCell` - table view and table view cell types that simplify the definition of static table view content
* `LMScrollView` - scroll view that automatically adapts to the size of its content

Extensions to several UIKit classes that adapt their respective types for use in markup are also discusssed.

# Document Structure
MarkupKit uses XML to define the structure of a user interface. In a MarkupKit document, XML elements represent instances of `UIView` subclasses, and XML attributes represent properties of or actions associated with those views. The hierarchical nature of XML parallels the view hierarchy of a UIKit application, making it easy to understand the relationships between views. 

For example, the following markup produces an instance of `LMTableViewCell` containing a `UIImageView` whose `image` property is set to an image named "world.png":

    <LMTableViewCell>
        <UIImageView image="world.png"/>
    </LMTableViewCell>

How the value of the "image" attribute is converted to an instance of `UIImage` is discussed in more detail later.

## Elements
Elements in a MarkupKit document represent instances of `UIView` or its subclasses. As elements are read by the XML parser, the corresponding class instances are dynamically created and added to the view hierarchy. 

In general, the `new` method is called on the named type to create the class instance. However, in some cases, it is necessary to invoke a named factory method to create the instance. This is discussed in more detail later.

MarkupKit adds the following method to the `UIView` class to facilitate construction of the view hierarchy:

    - (void)appendMarkupElementView:(UIView *)view;

This method is called on the superview of every view defined in the document except for the root, which has no superview, to add the view to its parent. The default implementation does nothing; subclasses must override this method to implement view-specific behavior. 

For example, `LMTableView` overrides this method to call `insertCell:forRowAtIndexPath:` on itself, and  `LMScrollView` overrides it to call `setContentView:`. Other classes that support sub-elements provide similar implementations.

## Attributes
XML attributes in a MarkupKit document generally represent either view properties or actions associated with a view. For example, the following markup declares an instance of `UISwitch` and sets the value of its `on` property to `true`:

    <UISwitch on="true"/>

Property values are set using key-value coding (KVC). Type conversions for string, number, and boolean properties are handled automatically by KVC. Other types, such as enumerations, colors, fonts, and images, require special handling and are discussed in more detail below.

MarkupKit uses `setValue:forKeyPath:` to apply property values, so it is possible to set properties of nested objects in markup. For example, the following markup creates an instance of `UIButton` whose title label's `font` property is set to "Helvetica-Bold 32":

    <UIButton style="systemButton" 
        normalTitle="Press Me!" 
        titleLabel.font="Helvetica-Bold 32"/>

With the exception of the `on` property itself, attributes whose names begin with "on" represent control events. The value of these attributes represents the name of the event handler, or "action", that is triggered when the event is fired. For example, the following markup declares an instance of `UISwitch` with an action handler that will be triggered when the switch's value changes:

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

### Layout Margins

`UIView` allows a developer to specify the amount of space that should be reserved around all subviews when laying out the user interface. This value is called the view's "layout margins" and is represented by an instance of the `UIEdgeInsets` structure. 

Since structure types aren't supported by XML, MarkupKit provides a shorthand for specifying layout margin values. For the "layoutMargins" attribute, a single numeric value may be specified, which will be applied to all of the edge inset structure's components (`top`, `left`, `bottom`, and `right`).

For example, the following markup creates an instance of `LMTableViewCell` with top, left, bottom, and right layout margin values of 20:

    <LMTableViewCell layoutMargins="20">
        ...
    </LMTableViewCell>
    
Layout margin components may also be specified individually; this is discussed in more detail later.

### Localization
Localization is performed automatically by MarkupKit. If an attribute does not fall into any of the previously mentioned categories, MarkupKit attempts to look up a localized version of the attribute's value before setting the property value.

For example, if an application has defined a localized greeting in _Localizable.strings_ as follows:

    "hello" = "Hello, World!";

the following markup will produce an instance of `UILabel` with the value of its `text` property set to "Hello, World!":

    <UILabel text="hello"/>

By default, MarkupKit will attempt to localize strings by calling `localizedStringForKey:value:table:` on the application's main bundle with a `nil` value for the `table` argument. The attribute's value is passed as both the `key` and the `value` arguments, so values that do not have localized versions appear exactly as they are specified in markup. 

For example, assuming that an application does not provide a localized value for "goodbye", the following markup would create an instance of `UILabel` containing the literal text "goodbye":

    <UILabel text="goodbye"/>

It is possible to define a set of local string values in a MarkupKit document using the `strings` processing instruction (PI). This PI tells MarkupKit to load an additional set of string values for use by the current document.

For example, if the application additionally defines the following localized value in a file named _MyStrings.strings_:
    
    "goodbye" = "Goodbye!";

This markup would produce a table view containing two rows reading "Hello, World!" and "Goodbye!":
    
    <?strings MyStrings?>
    
    <LMTableView>
        <LMTableViewCell>
            <UILabel text="hello"/>
        </LMTableViewCell>
        
        <LMTableViewCell>
            <UILabel text="goodbye"/>
        </LMTableViewCell>
    </LMTableView>

Multiple `strings` PIs may be specified in a MarkupKit document. The values from all of the named string tables are merged into a single collection of localized string values available to the document. If the same value is defined by multiple tables (including the default, _Localizable.strings_), the most recently-defined value takes precedence.

### Factory Methods
Some UIKit classes can't be instantiated by simply invoking the `new` method on the type. For example, instances of `UIButton` must be created by calling the `buttonWithType:` method of the `UIButton` class. Similarly, `UITableView` instances are initialized by calling `initWithFrame:style` on the table view instance, not the no-arg `init` method that is invoked by `new`.

MarkupKit doesn't know anything about methods - only instances and properties/events. To handle these cases, MarkupKit supports a special attribute named "style". The value of this attribute is considered the name of a "factory method", a no-arg method that produces instances of a given type. MarkupKit adds a number of factory methods to classes such as `UIButton` and `UITableView` to enable these types to be constructed in markup.

For example, the following markup creates an instance of a "system"-style `UIButton` by calling the `systemButton` method MarkupKit adds to the `UIButton` class:

    <UIButton style="systemButton" normalTitle="Press Me!"/>

The complete set of extensions MarkupKit adds to UIKit types is discussed in more detail later.

### Template Properties
Often, when constructing a user interface, the same set of property values are applied repeatedly to instances of a given type. For example, an application designer may want all buttons to have a similar appearance. While it is possible to simply duplicate the property definitions for each button instance, this is repetitive and does not allow the design to be easily modified later - each button instance must be located and modified individually, which can be time-consuming and error-prone.

MarkupKit allows developers to abstract common sets of property definitions into "templates", which can then be applied by name to class instances. This makes it much easier to apply common property definitions as well as modify them later.

Property templates are defined in property list (or _.plist_) files. Each template is represented by a dictionary defined at the top level of the property list. The dictionary's contents represent the property values that will be set when the template is applied.

Templates are added to a MarkupKit document using the `properties` processing instruction. For example, the following PI imports all templates defined by _MyStyles.plist_ into the current document:

    <?properties MyStyles?>

Templates are applied to individual class instances using the reserved "class" attribute. The value of this attribute refers to the name of a template defined by the property list. All property values defined by the template are applied to the class instance. Note that nested properties such as "titleLabel.font" are supported.

For example, assuming that _MyStyles.plist_ defines a dictionary named "label.hello" that contains the following values:

    "font": "Helvetica 24"
    "textAlignment": "center"
    
the following markup would produce a label reading "Hello, World!" in 24-point Helvetica with horizontally-centered text:

    <UILabel class="label.hello" text="Hello, World!"/>

Although attribute values in XML are always specified as strings, the property values in a template definition can be any supported type; for example, if a property accepts a numeric type, the value can be defined as a Number in the property list. However, this is not stricly necessary since strings will automatically be converted to the appropriate type by KVC.

Like `strings` processing instructions, multiple `properties` PIs may be specified in a MarkupKit document. Their contents are merged into a single collection of templates available to the document. If the same template is defined by multiple property lists, the contents of the templates are merged into a single template. As with strings, the most recently-defined values take precedence.

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

While it would be possible for an application to register for events programmatically using outlets, MarkupKit provides a more convenient alternative. An attribute whose name begins with "on" (but is not equal to "on") is considered a control event. The value of the attribute represents the name of the action that will be triggered when the event is fired. The name of the attribute is simply the "on" prefix followed by the name of the control event, minus the "UIControlEvent" prefix.

For example, the following markup declares an instance of `UIButton` that calls the `handleButtonTouchUpInside:` method of the document's owner when the button is tapped:

    <UIButton style="systemButton" normalTitle="Press Me!" 
        onTouchUpInside="handleButtonTouchUpInside:"/>

Like `IBOutlet`, MarkupKit supports the `IBAction` annotation used by Interface Builder, but does not require it.

## Processing Instructions
In addition to the document-wide `strings` and `properties` PIs mentioned earlier, MarkupKit also supports view-specific processing instructions. These allow developers to provide additional information to the view that can't be easily specified as an attribute value or subview. 

MarkupKit adds a `processMarkupInstruction:data:` method to the `UIView` class to facilitate PI handling at the view level. The `LMTableView` class overrides this method to support section header and footer declarations. An extension to `UISegmentedControl` overrides it to support segment title and image declarations. Both classes are discussed in more detail below.

# LMViewBuilder
`LMViewBuilder` is the class that is actually responsible for loading a MarkupKit document. It defines a single method that returns the deserialized view hierarchy:

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

## LMTableView and LMTableViewCell
The `LMTableView` and `LMTableViewCell` classes allow the structure and content of a table view to be defined in markup, rather than in code via a data source and delegate. `LMTableView` is a subclass of `UITableView` that acts as its own data source, serving cells from a statically-defined collection of table view sections. `LMTableViewCell` is a subclass of `UITableViewCell` that provides a vehicle for defining custom cell content in markup. It serves as a host for a single "content element view" that represents the actual content of the cell. 

MarkupKit provides extensions to the standard `UITableView` and `UITableViewCell` classes that allow them to be used in markup as well. These are discussed in more detail below.

### LMTableView
`LMTableView` supports the definition of statically-defined table content in markup. It inherits the following factory methods defined by the markup extensions to the `UITableView` class:

    + (LMTableView *)plainTableView;
    + (LMTableView *)groupedTableView;

These methods support the declaration of styled table view instances in markup and are discussed in more detail later.

For example, the following markup declares a plain table view containing three rows labeled "Row 1", "Row 2", and "Row 3", all of which appear in a single default section:

    <LMTableView style="plainTableView">
        <UITableViewCell textLabel.text="Row 1"/>
        <UITableViewCell textLabel.text="Row 2"/>
        <UITableViewCell textLabel.text="Row 3"/>
    </LMTableView>

The `header` processing instruction can be used to assign a title to the default section, or to create additional sections. This example uses the "grouped" table view style: 

    <LMTableView style="groupedTableView">
        <?header Section 1?>
        <UITableViewCell textLabel.text="Row 1a"/>
        <UITableViewCell textLabel.text="Row 1b"/>
        <UITableViewCell textLabel.text="Row 1c"/>

        <?header Section 2?>
        <UITableViewCell textLabel.text="Row 2a"/>
        <UITableViewCell textLabel.text="Row 2b"/>
        <UITableViewCell textLabel.text="Row 2c"/>
    </LMTableView>

The `footer` processing instruction can be used to set the footer title for the current section:

    <LMTableView style="groupedTableView">
        <?header Section 1?>
        <UITableViewCell textLabel.text="Row 1a"/>
        <UITableViewCell textLabel.text="Row 1b"/>
        <UITableViewCell textLabel.text="Row 1c"/>
        <?footer Section 1 End?>

        <?header Section 2?>
        <UITableViewCell textLabel.text="Row 2a"/>
        <UITableViewCell textLabel.text="Row 2b"/>
        <UITableViewCell textLabel.text="Row 2c"/>
        <?footer Section 2 End?>
    </LMTableView>

Use of the `LMTableView` class is not limited to markup. `LMTableView` cells and sections can also be managed programmatically. See _LMTableView.h_ for more information.

### LMTableViewCell
`LMTableViewCell` supports the declaration of custom cell content in markup. It can be used when the content options provided by the default `UITableViewCell` class are not sufficient. For example, the following markup creates a plain table view containg a single cell that presents an instance of `UIDatePicker`:

    <LMTableView style="plainTableView">
        <LMTableViewCell>
            <UIDatePicker datePickerMode="date"/>
        </LMTableViewCell>
    </LMTableView>

The date picker will be automatically sized to fill the width and height of the cell.

`UITableViewCell` defines several factory methods that are inherited by `LMTableViewCell` and are discussed in more detail below. However, these are used primarily to create instances of the default cell view types and are not commonly used in conjunction with custom cell content.

Since `LMTableViewCell` ultimately inherits from `UIView`, it is possible to specify the amount of padding around the cell view's content using the "layoutMargins" attribute. For example, the following markup declares a plain table view containing a single cell with 20 pixels of space reserved around the label:

    <LMTableView style="plainTableView">
        <LMTableViewCell layoutMargins="20">
            <UILabel text="Hello, World!"/>
        </LMTableViewCell>
    </LMTableView>

Note that `LMTableViewCell` instances are self-sizing. However, to enable self-sizing, the `estimatedRowHeight` property of the table view that contains the cells must be set to a non-zero value. `LMTableView` enables self-sizing cell behavior by default.

Finally, as discussed earlier, `LMTableViewCell` can also be used as the base class for custom table view cell classes. By overriding `initWithStyle:reuseIdentifier:` and specifying the cell view as the document owner, callers can easily create custom table view cells whose content and behavior is expressed in markup rather than in code. 

See _LMTableViewCell.h_ for more information.

## LMScrollView
The `LMScrollView` class extends the standard `UIScrollView` class to simplify the definition of a scroll view's content in markup. It presents a single content view at a time, optionally scrolling in one or both directions. As mentioned earlier, `LMScrollView` defines a `contentView` property representing this content, and overrides `appendMarkupElementView:` to set the value of this property in markup.

In addition to `contentView`, `LMScrollView` defines the following two properties:

    @property (nonatomic) BOOL fitToWidth;
    @property (nonatomic) BOOL fitToHeight;

When both properties are set to `false` (the default), the scroll view will automatically display scroll bars when needed, allowing the user to pan in either direction to see the entire image:

    <LMScrollView>
        <UIImageView image="large_image.png"/>
    </LMScrollView>

When `fitToWidth` is set to `true`, the scroll view will ensure that the width of its content matches its own width, causing the content to wrap and scroll in the vertical direction:

    <LMScrollView fitToWidth="true">
        <UILabel text="Lorem ipsum dolor sit amet, consectetur adipiscing..."
            numberOfLines="0"/>
    </LMScrollView>

Similarly, when `fitToHeight` is `true`, the scroll view will ensure that the height of its content matches its own height, causing the content to wrap and scroll in the horizontal direction.

See _LMScrollView.h_ for more information.

## UIKit Extensions
MarkupKit extends several UIKit classes to adapt them for use in markup. For example, some classes define a custom default initializer and must be instiated via factory methods. Additionally, features of some classes are not exposed as properties that can be set via KVC. MarkupKit adds the factory methods and property definitions required to allow these classes to be used in markup. These extensions are documented below.

Note that this section only describes classes that require extensions in order to work with markup. Classes that do not require extension are not discussed.

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

### UIButton
Instances of `UIButton` are created programmtically using the `buttonWithType:` method of `UIButton`. MarkupKit adds the following factory methods to `UIButton` to allow buttons be declared in markup:

    + (UIButton *)customButton;
    + (UIButton *)systemButton;
    + (UIButton *)detailDisclosureButton;
    + (UIButton *)infoLightButton;
    + (UIButton *)infoDarkButton;
    + (UIButton *)contactAddButton;

Note that these methods only produce instances of 

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

### UITableView
Instances of `UITableView` are created programmatically using the `initWithFrame:style:` method of `UITableView`. MarkupKit adds the following factory methods to `UITableView` to allow table views to be declared in markup:

    + (UITableView *)plainTableView;
    + (UITableView *)groupedTableView;

As shown in previous examples, these factory methods are used to create instances of `UITableView` in the plain or grouped style, respectively:

    <LMTableView style="plainTableView">
    ...
    </LMTableView>

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

### UIProgressView
Instances of `UIProgressView` are created programmatically using the `initWithProgressViewStyle:` method. MarkupKit adds the following factory methods to `UIProgressView` to allow progress views to be declared in markup:

    + (UIProgressView *)defaultProgressView;
    + (UIProgressView *)barProgressView;

For example, the following markup declares an instance of a default-style `UIProgressView`. It is given an ID so its owner can programmatically update its progress value later:

    <UIProgressView id="progressView" style="defaultProgressView"/>

### UISegmentedControl
Instances of `UISegmentedControl` are populated using the `insertSegmentWithTitle:atIndex:animated:` and `insertSegmentWithImage:atIndex:animated` methods. MarkupKit overrides the `processMarkupInstruction:data:` to allow segmented controls to be populated in markup. The `segmentTitle` progressing instruction can be used to add a segment title to a segmented control:

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

### CALayer
The `layer` property of `UIView` returns a `CALayer` instance that can be used to configure properties of the view. However, the `shadowOffset` property of `CALayer` is a `CGSize`. Since structs are not supported in XML, MarkupKit adds the following methods to `CALayer` to allow the layer's shadow offset width and height to be configured independently:

    @property (nonatomic) CGFloat shadowOffsetWidth;
    @property (nonatomic) CGFloat shadowOffsetHeight;

For example, the following markup creates a system button with a shadow opacity of 0.5, radius of 10, and offset height of 3:

    <UIButton style="systemButton" normalTitle="Press Me!" normalTitleColor="#ff0000"
        backgroundColor="#aa0000"
        layer.shadowOpacity="0.5" layer.shadowRadius="10" layer.shadowOffsetHeight="3"/>

# More Information
For more information, refer to [the wiki](wiki) or [the issue list](issues).

