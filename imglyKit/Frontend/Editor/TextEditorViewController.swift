//
//  TextEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 17/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

private let kFontSizeInTextField = CGFloat(20)
private let kTextFieldHeight = CGFloat(40)
private let kTextLabelInitialMargin = CGFloat(40)
private let kMinimumFontSize = CGFloat(12.0)

@objc public enum TextAction: Int {
    case SelectFont
    case SelectColor
    case SelectBackgroundColor
    case Add
    case Delete
    case AcceptColor
    case RejectColor
    case AcceptFont
    case RejectFont
    case BringToFront
}

@objc(IMGLYTextEditorViewController) public class TextEditorViewController: SubEditorViewController {

    // MARK: - Properties

    private var textColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 1.0, alpha: 1.0)
    private var backgroundColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 1.0, alpha: 0.0)
    private var fontName = ""
    private var currentTextSize = CGFloat(0)
    private var maximumFontSize = CGFloat(0)
    private var panOffset = CGPoint.zero
    private var fontSizeAtPinchBegin = CGFloat(0)
    private var distanceAtPinchBegin = CGFloat(0)
    private var draggedView: TextLabel?
    private var tempTextCopy = [Filter]()
    private var createNewText = false
    private var selectBackgroundColor = false
    private var overlayConverter: OverlayConverter?
    private var pullableColorPickerView = PullableView()
    private var pullableFontSelectorView = PullableView()
    private var colorBackup = UIColor.whiteColor()
    private var fontBackup = UIFont()
    private var addTextButtonConstraint = NSLayoutConstraint()
    private var deleteButtonConstraint = NSLayoutConstraint()
    private var acceptColorButtonConstraint = NSLayoutConstraint()
    private var rejectColorButtonConstraint = NSLayoutConstraint()
    private var acceptFontButtonConstraint = NSLayoutConstraint()
    private var rejectFontButtonConstraint = NSLayoutConstraint()
    private let upperOverlayButtonConstant = CGFloat(50)
    private let lowerOverlayButtonConstant = CGFloat(20)
    private let colorButtonImageGenerator = ColorButtonImageGenerator(imageName: "imgly_icon_option_selected_color",
        backgroundImageName: "imgly_icon_option_selected_color_bg")

    public private(set) lazy var addTextButton: UIButton = {
        let bundle = NSBundle(forClass: TextEditorViewController.self)
        let button = UIButton(type: UIButtonType.Custom)
        button.accessibilityLabel = Localize("Add text")
        button.setImage(UIImage(named: "icon_add", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 2
        button.clipsToBounds = false
        button.backgroundColor = UIColor(red:0.22, green:0.62, blue:0.85, alpha:1)
        button.addTarget(self, action: "addText:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure?(button, .Add)
        return button
    }()

    public private(set) lazy var deleteTextButton: UIButton = {
        let bundle = NSBundle(forClass: TextEditorViewController.self)
        let button = UIButton(type: UIButtonType.Custom)
        button.accessibilityLabel = Localize("Delete text")
        button.setImage(UIImage(named: "icon_delete", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 2
        button.clipsToBounds = false
        button.backgroundColor = UIColor(red:0.22, green:0.62, blue:0.85, alpha:1)
        button.addTarget(self, action: "deleteText:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure?(button, .Delete)
        return button
    }()

    public private(set) lazy var acceptColorButton: UIButton = {
        let bundle = NSBundle(forClass: TextEditorViewController.self)
        let button = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "icon_confirm", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "acceptColor:", forControlEvents: .TouchUpInside)
        button.layer.cornerRadius = 2
        button.clipsToBounds = false
        button.backgroundColor = UIColor(red:0.22, green:0.62, blue:0.85, alpha:1)
        self.options.actionButtonConfigurationClosure?(button, .AcceptColor)
        return button
    }()

    public private(set) lazy var rejectColorButton: UIButton = {
        let bundle = NSBundle(forClass: TextEditorViewController.self)
        let button = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "icon_cancel", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 2
        button.clipsToBounds = false
        button.backgroundColor = UIColor(red:0.22, green:0.62, blue:0.85, alpha:1)
        button.addTarget(self, action: "rejectColor:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure?(button, .RejectColor)
        return button
    }()

    public private(set) lazy var acceptFontButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "icon_confirm", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 2
        button.clipsToBounds = false
        button.backgroundColor = UIColor(red:0.22, green:0.62, blue:0.85, alpha:1)
        button.addTarget(self, action: "acceptFont:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure?(button, .AcceptFont)
        return button
    }()

    public private(set) lazy var rejectFontButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "icon_cancel", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 2
        button.clipsToBounds = false
        button.backgroundColor = UIColor(red:0.22, green:0.62, blue:0.85, alpha:1)
        button.addTarget(self, action: "rejectFont:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure?(button, .RejectFont)
        return button
    }()

    public private(set) lazy var selectTextFontButton: TextCaptionButton = {
        let bundle = NSBundle(forClass: TextEditorViewController.self)
        let button = TextCaptionButton()
        button.accessibilityLabel = Localize("Font")
        button.textLabel.text = Localize("Font")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleView.text = "Ag"
        button.titleView.textColor = self.options.fontSelectorFontColor
        button.addTarget(self, action: "setTextFont:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure?(button, .SelectFont)
        return button
    }()

    public private(set) lazy var selectTextColorButton: ImageCaptionButton = {
        let bundle = NSBundle(forClass: TextEditorViewController.self)
        let button = ImageCaptionButton()
        button.accessibilityLabel = Localize("Text color")
        button.textLabel.text = Localize("Text")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView.image = UIImage(named: "icon_selected_color", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.imageView.image = button.imageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        button.imageView.tintColor = UIColor.whiteColor()
        button.addTarget(self, action: "setTextColor:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure?(button, .SelectColor)
        return button
    }()

    public private(set) lazy var selectBackgroundColorButton: ImageCaptionButton = {
        let bundle = NSBundle(forClass: TextEditorViewController.self)
        let button = ImageCaptionButton()
        button.accessibilityLabel = Localize("Background color")
        button.textLabel.text = Localize("Back")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView.image = UIImage(named: "icon_selected_color", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.imageView.image = button.imageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        button.imageView.tintColor = UIColor.clearColor()
        button.addTarget(self, action: "setBackgroundColor:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure?(button, .SelectBackgroundColor)
        return button
    }()

    public private(set) lazy var bringToFrontButton: ImageCaptionButton = {
        let bundle = NSBundle(forClass: TextEditorViewController.self)
        let button = ImageCaptionButton()
        button.accessibilityLabel = Localize("Bring to front")
        button.textLabel.text = Localize("Bring to front")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "bringToFront:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure?(button, .BringToFront)
        return button
    }()

    public private(set) lazy var textClipView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()

    public private(set) lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.text = ""
        textField.textColor = UIColor.whiteColor()
        textField.backgroundColor = self.backgroundColor
        textField.clipsToBounds = false
        textField.contentVerticalAlignment = UIControlContentVerticalAlignment.Top
        textField.returnKeyType = UIReturnKeyType.Done
        textField.translatesAutoresizingMaskIntoConstraints = false
        self.options.textFieldConfigurationClosure?(textField)
        return textField
    }()

    public private(set) lazy var fontSelectorView: FontSelectorView = {
        let selector = FontSelectorView()
        selector.translatesAutoresizingMaskIntoConstraints = false
        selector.selectorDelegate = self
        selector.textColor = self.options.fontSelectorFontColor
        selector.fontSelectorButtonConfigurationClosure = self.options.fontSelectorButtonConfigurationClosure
        return selector
    }()

    public private(set) lazy var colorPickerView: ColorPickerView = {
        let selector = ColorPickerView()
        selector.translatesAutoresizingMaskIntoConstraints = false
        return selector
    }()

    public private(set) lazy var textColorSelectorView: TextColorSelectorView = {
        let view = TextColorSelectorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.menuDelegate = self
        return view
    }()

    public private(set) lazy var fontQuickSelectorView: FontQuickSelectorView = {
        let view = FontQuickSelectorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.fontQuickSelectorButtonConfigurationClosure = self.options.fontQuickSelectorButtonConfigurationClosure
        return view
    }()

    private var textLabel = TextLabel()

    private var blurredContainerView = UIVisualEffectView()

    // MARK: - Initializers

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()

        InstanceFactory.fontImporter().importFonts()

        fontName = options.defaultFontName

        configureTextClipView()
        configureBottomButtons()
        configureAddButton()
        configureDeleteButton()
        configureAcceptColorButton()
        configureRejectColorButton()
        configureAcceptFontButton()
        configureRejectFontButton()
        configureGestureRecognizers()
        configurePullableColorPickerView()
        configureColorPickerView()
        configurePullableFontSelectorView()
        configureFontSelectorView()
        configureColorSelectorView()
        configureFontQuickSelectorView()
        backupTexts()
        fixedFilterStack.spriteFilters.removeAll()
        updateButtonStatus()
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.overlayConverter = OverlayConverter(fixedFilterStack: self.fixedFilterStack)
        rerenderPreviewWithoutText()
        if options.allowedTextActions.contains(.Add) && options.openNewTextDialogAutomatically {
            showNewTextDialog()
        }
        setPullableViewMarings()
    }

    private func setPullableViewMarings() {
        let closedMargin = self.view.frame.height - bottomContainerView.frame.height - pullableColorPickerView.handleHeight
        pullableColorPickerView.marginConstraint?.constant = closedMargin
        pullableColorPickerView.closedMargin = closedMargin
        pullableFontSelectorView.marginConstraint?.constant = closedMargin
        pullableFontSelectorView.closedMargin = closedMargin
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        textClipView.frame = view.convertRect(previewImageView.visibleImageFrame, fromView: previewImageView)
    }

    // MARK: - EditorViewController

    public override var options: TextEditorViewControllerOptions {
        return self.configuration.textEditorViewControllerOptions
    }

    override var enableZoomingInPreviewImage: Bool {
        return false
    }

    // MARK: - SubEditorViewController

    public override func tappedDone(sender: UIBarButtonItem?) {
        self.overlayConverter?.addSpriteFiltersFromUIElements(textClipView, previewSize: previewImageView.visibleImageFrame.size, previewImage: previewImageView.image!)
        updatePreviewImageWithCompletion {
            super.tappedDone(sender)
        }
    }

    // MARK: - Configuration

    private func configureBottomButtons() {
        // Setup button container view
        let buttonContainerView = UIView()
        buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.addSubview(buttonContainerView)
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[buttonContainerView]|", options: [], metrics: nil, views: ["buttonContainerView": buttonContainerView]))
        bottomContainerView.addConstraint(NSLayoutConstraint(item: buttonContainerView, attribute: .CenterX, relatedBy: .Equal, toItem: bottomContainerView, attribute: .CenterX, multiplier: 1, constant: 0))
        selectTextFontButton.fontName = options.defaultFontName

        var views = [String: UIView]()
        var visualFormatString = ""
        if options.allowedTextActions.contains(.SelectFont) {
            views = viewsByAddingButton(selectTextFontButton, containerView: buttonContainerView, views: views)
            visualFormatString = visualFormatStringByAddingButton(selectTextFontButton, visualFormatString: visualFormatString)
        }
        if options.allowedTextActions.contains(.SelectColor) {
            views = viewsByAddingButton(selectTextColorButton, containerView: buttonContainerView, views: views)
            visualFormatString = visualFormatStringByAddingButton(selectTextColorButton, visualFormatString: visualFormatString)
        }
        if options.allowedTextActions.contains(.SelectBackgroundColor) {
            views = viewsByAddingButton(selectBackgroundColorButton, containerView: buttonContainerView, views: views)
            visualFormatString = visualFormatStringByAddingButton(selectBackgroundColorButton, visualFormatString: visualFormatString)
        }
        if options.allowedTextActions.contains(.BringToFront) {
            views = viewsByAddingButton(bringToFrontButton, containerView: buttonContainerView, views: views)
            visualFormatString = visualFormatStringByAddingButton(bringToFrontButton, visualFormatString: visualFormatString)
        }
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|\(visualFormatString)|", options: [], metrics: [ "buttonWidth": 90 ], views: views))
    }

    private func configureAddButton() {
        let views: [String : AnyObject] = [
            "addTextButton" : addTextButton
        ]
        view.addSubview(addTextButton)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[addTextButton]", options: [], metrics: [ "buttonWidth": 40 ], views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[addTextButton(40)]", options: [], metrics: nil, views: views))
        addTextButtonConstraint = NSLayoutConstraint(item: addTextButton, attribute: .Bottom, relatedBy: .Equal, toItem: bottomContainerView, attribute: .Top, multiplier: 1, constant: -20)
        addTextButton.alpha = options.enabledOverlayButtonAlpha
        view.addConstraint(addTextButtonConstraint)
    }

    private func configureDeleteButton() {
        let views: [String : AnyObject] = [
            "deleteTextButton" : deleteTextButton
        ]
        view.addSubview(deleteTextButton)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[deleteTextButton]-20-|", options: [], metrics: [ "buttonWidth": 40 ], views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[deleteTextButton(40)]", options: [], metrics: nil, views: views))
        deleteButtonConstraint = NSLayoutConstraint(item: deleteTextButton, attribute: .Bottom, relatedBy: .Equal, toItem: bottomContainerView, attribute: .Top, multiplier: 1, constant: -20)
        view.addConstraint(deleteButtonConstraint)
    }

    private func configureAcceptColorButton() {
        let views: [String : AnyObject] = [
            "acceptColorButton" : acceptColorButton
        ]
        view.addSubview(acceptColorButton)
        acceptColorButton.hidden = true
        acceptColorButton.alpha = 0.0
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[acceptColorButton]-20-|", options: [], metrics: [ "buttonWidth": 40 ], views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[acceptColorButton(40)]", options: [], metrics: nil, views: views))
        acceptColorButtonConstraint = NSLayoutConstraint(item: acceptColorButton, attribute: .Bottom, relatedBy: .Equal, toItem: bottomContainerView, attribute: .Top, multiplier: 1, constant: -20)
        view.addConstraint(acceptColorButtonConstraint)
    }

    private func configureRejectColorButton() {
        let views: [String : AnyObject] = [
            "rejectColorButton" : rejectColorButton
        ]
        view.addSubview(rejectColorButton)
        rejectColorButton.hidden = true
        rejectColorButton.alpha = 0.0
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[rejectColorButton]", options: [], metrics: [ "buttonWidth": 40 ], views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[rejectColorButton(40)]", options: [], metrics: nil, views: views))
        rejectColorButtonConstraint = NSLayoutConstraint(item: rejectColorButton, attribute: .Bottom, relatedBy: .Equal, toItem: bottomContainerView, attribute: .Top, multiplier: 1, constant: -20)
        view.addConstraint(rejectColorButtonConstraint)
    }

    private func configureAcceptFontButton() {
        let views: [String : AnyObject] = [
            "acceptFontButton" : acceptFontButton
        ]
        view.addSubview(acceptFontButton)
        acceptFontButton.hidden = true
        acceptFontButton.alpha = 0.0
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[acceptFontButton]-20-|", options: [], metrics: [ "buttonWidth": 40 ], views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[acceptFontButton(40)]", options: [], metrics: nil, views: views))
        acceptFontButtonConstraint = NSLayoutConstraint(item: acceptFontButton, attribute: .Bottom, relatedBy: .Equal, toItem: bottomContainerView, attribute: .Top, multiplier: 1, constant: -20)
        view.addConstraint(acceptFontButtonConstraint)
    }

    private func configureRejectFontButton() {
        let views: [String : AnyObject] = [
            "rejectFontButton" : rejectFontButton
        ]
        view.addSubview(rejectFontButton)
        rejectFontButton.hidden = true
        rejectFontButton.alpha = 0.0
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[rejectFontButton]", options: [], metrics: [ "buttonWidth": 40 ], views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[rejectFontButton(40)]", options: [], metrics: nil, views: views))
        rejectFontButtonConstraint = NSLayoutConstraint(item: rejectFontButton, attribute: .Bottom, relatedBy: .Equal, toItem: bottomContainerView, attribute: .Top, multiplier: 1, constant: -20)
        view.addConstraint(rejectFontButtonConstraint)
    }


    private func viewsByAddingButton(button: UIControl, containerView: UIView, var views: [String: UIView]) -> ([String: UIView]) {
        let viewName = "_\(String(abs(button.hash)))"
        containerView.addSubview(button)
        views[viewName] = button
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[\(viewName)]|", options: [], metrics: nil, views: views))
        return views
    }

    private func visualFormatStringByAddingButton(button: UIControl, var visualFormatString: String) -> (String) {
        let viewName = "_\(String(abs(button.hash)))"
        visualFormatString.appendContentsOf("[\(viewName)(==buttonWidth)]")
        return visualFormatString
    }

    private func configureTextClipView() {
        view.addSubview(textClipView)
    }

    private func configureTextLabel() {
        textClipView.addSubview(textLabel)
        textLabel.backgroundColor = self.backgroundColor
        textLabel.textColor = self.textColor
        textLabel.textAlignment = NSTextAlignment.Center
        textLabel.clipsToBounds = true
        textLabel.userInteractionEnabled = true
        // we set the rotation to 360 degree, so the transform anchor point is set to center
        textLabel.transform = CGAffineTransformRotate(textLabel.transform, CGFloat(M_PI) * 2.0)
        textLabel.accessibilityTraits |= UIAccessibilityTraitAdjustable
    }

    private func configureTextField() {
        configureBlurredContainerView()
        blurredContainerView.contentView.addSubview(textField)

        let views = [
            "blurredContainerView" : blurredContainerView,
            "textField" : textField
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[blurredContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[blurredContainerView]|", options: [], metrics: nil, views: views))

        blurredContainerView.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[textField]-20-|", options: [], metrics: nil, views: views))
        blurredContainerView.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[textField]|", options: [], metrics: nil, views: views))

        blurredContainerView.alpha = 0.0
        UIView.animateWithDuration(0.3) {
            self.blurredContainerView.alpha = 1.0
        }
    }

    private func configureColorSelectorView() {
        view.addSubview(textColorSelectorView)
        textColorSelectorView.backgroundColor = self.currentBackgroundColor

        let views = [
            "textColorSelectorView" : textColorSelectorView
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[textColorSelectorView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[textColorSelectorView(==100)]|", options: [], metrics: nil, views: views))
        textColorSelectorView.alpha = 0.0
        textColorSelectorView.hidden = true
    }

    private func configureFontQuickSelectorView() {
        view.addSubview(fontQuickSelectorView)
        fontQuickSelectorView.backgroundColor = self.currentBackgroundColor

        let views = [
            "fontQuickSelectorView" : fontQuickSelectorView
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[fontQuickSelectorView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[fontQuickSelectorView(==100)]|", options: [], metrics: nil, views: views))
        fontQuickSelectorView.alpha = 0.0
        fontQuickSelectorView.hidden = true
        fontQuickSelectorView.selectorDelegate = self
        fontQuickSelectorView.selectedTextColor = options.fontSelectorHighlightColor
        fontQuickSelectorView.textColor = options.fontSelectorFontColor
    }

    private func configureColorPickerView() {
        pullableColorPickerView.addSubview(colorPickerView)
        colorPickerView.initialColor = selectBackgroundColor ? textLabel.backgroundColor : textLabel.textColor
        colorPickerView.pickerDelegate = self
        colorPickerView.hidden = true

        let views = [
            "pullableView" : pullableColorPickerView,
            "colorPickerView" : colorPickerView
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[pullableView]|", options: [], metrics: nil, views: views))

        let topConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: NSLayoutRelation.Equal, toItem: pullableColorPickerView, attribute: .Top, multiplier: -1.0, constant: 0.0)
        view.addConstraint(topConstraint)

        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: NSLayoutRelation.Equal, toItem: pullableColorPickerView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        view.addConstraint(bottomConstraint)

        pullableColorPickerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[colorPickerView]|", options: [], metrics: nil, views: views))
        pullableColorPickerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(pullableColorPickerView.handleHeight)-[colorPickerView]|", options: [], metrics: nil, views: views))
        pullableColorPickerView.marginConstraint = topConstraint
        pullableColorPickerView.hidden = true
        pullableColorPickerView.alpha = 0.0
    }

    private func configureFontSelectorView() {
        pullableFontSelectorView.addSubview(fontSelectorView)

        let views = [
            "pullableView" : pullableFontSelectorView,
            "fontSelectorView" : fontSelectorView
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[pullableView]|", options: [], metrics: nil, views: views))

        let topConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: NSLayoutRelation.Equal, toItem: pullableFontSelectorView, attribute: .Top, multiplier: -1.0, constant: 0.0)
        view.addConstraint(topConstraint)

        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: NSLayoutRelation.Equal, toItem: pullableFontSelectorView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        view.addConstraint(bottomConstraint)

        pullableFontSelectorView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[fontSelectorView]|", options: [], metrics: nil, views: views))
        pullableFontSelectorView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(pullableFontSelectorView.handleHeight)-[fontSelectorView]|", options: [], metrics: nil, views: views))
        pullableFontSelectorView.marginConstraint = topConstraint
        pullableFontSelectorView.hidden = true
        pullableFontSelectorView.alpha = 0.0
        fontSelectorView.selectedTextColor = options.fontSelectorHighlightColor
        fontSelectorView.textColor = options.fontSelectorFontColor
    }

    private func configureBlurredContainerView() {
        let blurEffect = UIBlurEffect(style: .Dark)
        blurredContainerView = UIVisualEffectView(effect: blurEffect)
        blurredContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurredContainerView)
    }

    private func configureGestureRecognizers() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 1
        textClipView.addGestureRecognizer(panGestureRecognizer)

        if options.canModifyTextSize {
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
            pinchGestureRecognizer.delegate = self
            textClipView.addGestureRecognizer(pinchGestureRecognizer)
        }

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        tapGestureRecognizer.delegate = self
        textClipView.addGestureRecognizer(tapGestureRecognizer)

        if options.canModifyTextRotation {
            let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "handleRotate:")
            rotationGestureRecognizer.delegate = self
            textClipView.addGestureRecognizer(rotationGestureRecognizer)
        }

        if options.canModifyText {
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
            longPressRecognizer.minimumPressDuration = 2
            textClipView.addGestureRecognizer(longPressRecognizer)
        }
    }

    private func configurePullableColorPickerView() {
        pullableColorPickerView = PullableView()
        pullableColorPickerView.translatesAutoresizingMaskIntoConstraints = false
        pullableColorPickerView.backgroundColor = self.currentBackgroundColor
        pullableColorPickerView.handleBackgroundColor = UIColor(red:0.22, green:0.62, blue:0.85, alpha:1)
        pullableColorPickerView.handleColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.view.addSubview(pullableColorPickerView)
        self.options.pullableViewConfigurationClosure?(pullableColorPickerView)
        colorPickerView.initialColor = selectBackgroundColor ? textLabel.backgroundColor : textLabel.textColor
    }

    private func configurePullableFontSelectorView() {
        pullableFontSelectorView = PullableView()
        pullableFontSelectorView.translatesAutoresizingMaskIntoConstraints = false
        pullableFontSelectorView.backgroundColor = self.currentBackgroundColor
        pullableFontSelectorView.handleBackgroundColor = UIColor(red:0.22, green:0.62, blue:0.85, alpha:1)
        pullableFontSelectorView.handleColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.view.addSubview(pullableFontSelectorView)
        self.options.pullableViewConfigurationClosure?(pullableFontSelectorView)
    }

    // MARK: - Button Handling

    @objc private func addText(sender: UIButton) {
        showNewTextDialog()
    }

    private func showNewTextDialog() {
        navigationItem.rightBarButtonItem?.enabled = false
        createNewText = true
        configureTextField()
        textField.text = ""
        textField.becomeFirstResponder()
    }

    @objc private func deleteText(sender: UIButton) {
        if textLabel.layer.borderWidth > 0 {
            textLabel.layer.borderWidth = 0
            textLabel.removeFromSuperview()
        }
        updateButtonStatus()
    }

    @objc private func setTextFont(sender: ImageCaptionButton) {
        if textLabel.layer.borderWidth > 0 {
            fontBackup = textLabel.font!
        }
        navigationItem.rightBarButtonItem?.enabled = false
        showFontSelctionViews()
    }

    @objc private func setTextColor(sender: ImageCaptionButton) {
        if textLabel.layer.borderWidth > 0 {
            colorBackup = textLabel.textColor
        }
        navigationItem.rightBarButtonItem?.enabled = false
        selectBackgroundColor = false
        showColorSelctionViews()
    }

    @objc private func setBackgroundColor(sender: ImageCaptionButton) {
        if textLabel.layer.borderWidth > 0 {
            colorBackup = textLabel.backgroundColor!
        }
        navigationItem.rightBarButtonItem?.enabled = false
        selectBackgroundColor = true
        showColorSelctionViews()
    }

    @objc private func bringToFront(sender: ImageCaptionButton) {
        if textLabel.layer.borderWidth > 0 {
            textClipView.bringSubviewToFront(textLabel)
        }
    }

    @objc private func acceptColor(sender: ImageCaptionButton) {
        navigationItem.rightBarButtonItem?.enabled = true
        hideColorSelctionViews()
    }

    @objc private func rejectColor(sender: ImageCaptionButton) {
        if textLabel.layer.borderWidth > 0 {
            if selectBackgroundColor {
                textLabel.backgroundColor = colorBackup
                selectBackgroundColorButton.imageView.tintColor = colorBackup
            } else {
                textLabel.textColor = colorBackup
                selectTextColorButton.imageView.tintColor = colorBackup
            }
        }
        navigationItem.rightBarButtonItem?.enabled = true
        hideColorSelctionViews()
    }

    @objc private func acceptFont(sender: ImageCaptionButton) {
        navigationItem.rightBarButtonItem?.enabled = true
        hideFontSelctionViews()
    }

    @objc private func rejectFont(sender: ImageCaptionButton) {
        if textLabel.layer.borderWidth > 0 {
            textLabel.font = fontBackup
            textLabel.sizeToFit()
        }
        navigationItem.rightBarButtonItem?.enabled = true
        hideFontSelctionViews()
    }

    // MARK: - Gesture Handling

    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(textClipView)
        let translation = recognizer.translationInView(textClipView)
        switch recognizer.state {
        case .Began:
            draggedView = hitLabel(location)
            if let draggedView = draggedView {
                unSelectTextLabel(textLabel)
                textLabel = draggedView
                selectTextLabel(textLabel)
            }
            updateButtonStatus()
        case .Changed:
            if let draggedView = draggedView {
                draggedView.center = CGPoint(x: draggedView.center.x + translation.x, y: draggedView.center.y + translation.y)
            }
            recognizer.setTranslation(CGPoint.zero, inView: textClipView)
        case .Cancelled, .Ended:
            draggedView = nil
        default:
            break
        }
    }

    @objc private func handlePinch(recognizer: UIPinchGestureRecognizer) {
        if recognizer.numberOfTouches() == 2 {
            let point1 = recognizer.locationOfTouch(0, inView:textClipView)
            let point2 = recognizer.locationOfTouch(1, inView:textClipView)
            let midpoint = CGPoint(x:(point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
            let scale = recognizer.scale

            switch recognizer.state {
            case .Began:
                if draggedView == nil {
                    draggedView = hitLabel(midpoint)
                }

                if let draggedView = draggedView {
                    unSelectTextLabel(textLabel)
                    textLabel = draggedView
                    selectTextLabel(textLabel)
                }
                updateButtonStatus()
            case .Changed:
                if let draggedView =  draggedView {
                    currentTextSize = draggedView.font.pointSize
                    currentTextSize *= scale
                    draggedView.font = UIFont(name: draggedView.font.fontName, size: currentTextSize)
                    draggedView.sizeToFit()
                }
                recognizer.scale = 1
            case .Cancelled, .Ended:
                draggedView = nil
            default:
                break
            }
        }
    }

    @objc private func handleRotate(recognizer: UIRotationGestureRecognizer) {
        if recognizer.numberOfTouches() == 2 {
            let point1 = recognizer.locationOfTouch(0, inView: textClipView)
            let point2 = recognizer.locationOfTouch(1, inView: textClipView)
            let midpoint = CGPoint(x:(point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
            let rotation = recognizer.rotation

            switch recognizer.state {
            case .Began:
                if draggedView == nil {
                    draggedView = hitLabel(midpoint)
                }

                if let draggedView = draggedView {
                    unSelectTextLabel(textLabel)
                    textLabel = draggedView
                    selectTextLabel(textLabel)
                    updateButtonStatus()
                }
            case .Changed:
                if let draggedView = draggedView {
                    draggedView.transform = CGAffineTransformRotate(draggedView.transform, rotation)
                }

                recognizer.rotation = 0
            case .Cancelled, .Ended:
                draggedView = nil
            default:
                break
            }
        }
    }

    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.locationInView(textClipView)
        draggedView = hitLabel(location)
        unSelectTextLabel(textLabel)
        if let draggedView = draggedView {
            textLabel = draggedView
            currentTextSize = textLabel.font.pointSize
            selectTextLabel(textLabel)
            updateFontSelectorData()
        }
        updateButtonStatus()
    }

    @objc private func handleLongPress(recognizer: UITapGestureRecognizer) {
        // don't change selection while we are in color or font picking mode
        if !pullableColorPickerView.hidden || !pullableFontSelectorView.hidden {
            return
        }
        let location = recognizer.locationInView(textClipView)
        draggedView = hitLabel(location)
        if recognizer.state == .Began {
            if let draggedView = draggedView {
                textLabel = draggedView
                if textLabel.layer.borderWidth > 0 {
                    createNewText = false
                    configureTextField()
                    textField.text = textLabel.text
                    textField.becomeFirstResponder()
                }
            }
        }
    }

    // MARK: - Helpers

    private func hideBlurredContainer() {
        UIView.animateWithDuration(0.3, animations: {
            self.blurredContainerView.alpha = 0.0
            }, completion: {
                (value: Bool) in
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.blurredContainerView.removeFromSuperview()
        })
    }

    private func calculateInitialFontSize() {
        // swiftlint:disable force_cast
        let customParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        // swiftlint:enable force_cast
        customParagraphStyle.lineBreakMode = .ByClipping

        if let text = textLabel.text {
            currentTextSize = 1.0
            var size = CGSize.zero
            if !text.isEmpty {
                repeat {
                    currentTextSize += 1.0
                    if let font = UIFont(name: fontName, size: currentTextSize) {
                        size = text.sizeWithAttributes([ NSFontAttributeName: font,  NSParagraphStyleAttributeName:customParagraphStyle])
                    }
                } while ((size.width < (textClipView.frame.size.width - kTextLabelInitialMargin)) && (size.height < (textClipView.frame.size.height - kTextLabelInitialMargin)))
            }
        }
    }

    private func setInitialTextLabelSize() {
        calculateInitialFontSize()
        textLabel.font = UIFont(name: fontName, size: currentTextSize)
        textLabel.sizeToFit()
        textLabel.frame.origin.x = kTextLabelInitialMargin / 2.0 - textClipView.frame.origin.x
        textLabel.frame.origin.y = -textLabel.frame.size.height / 2.0 + textClipView.frame.height / 2.0
    }

    private func calculateNewFontSizeBasedOnDistanceBetweenPoint(point1: CGPoint, and point2: CGPoint) -> CGFloat {
        let diffX = point1.x - point2.x
        let diffY = point1.y - point2.y
        return sqrt(diffX * diffX + diffY  * diffY)
    }

    private func selectTextLabel(label: UILabel) {
        // don't change selection while we are in color or font picking mode
        if !pullableColorPickerView.hidden || !pullableFontSelectorView.hidden {
            return
        }

        label.layer.borderColor = UIColor.whiteColor().CGColor
        label.layer.borderWidth = 1.0
        label.accessibilityTraits |= UIAccessibilityTraitSelected

        if selectBackgroundColor {
            if let backgroundColor = label.backgroundColor {
                colorPickerView.color = backgroundColor
            }
        } else {
            colorPickerView.color = label.textColor
        }
        selectTextColorButton.imageView.tintColor = label.textColor
        if let backgroundColor = label.backgroundColor {
            selectBackgroundColorButton.tintColor = backgroundColor
        }
    }

    private func unSelectTextLabel(label: UILabel) {
        // don't change selection while we are in color or font picking mode
        if !pullableColorPickerView.hidden || !pullableFontSelectorView.hidden {
            return
        }
        label.layer.borderWidth = 0
        label.accessibilityTraits &= ~UIAccessibilityTraitSelected
    }

    private func hitLabel(point: CGPoint) -> TextLabel? {
        var result: TextLabel? = nil
        for label in textClipView.subviews where label is TextLabel {
            if label.frame.contains(point) {
                result = label as? TextLabel
            }
        }
        return result
    }

    private func updateButtonStatus() {
        let enabled = textLabel.layer.borderWidth > 0
        let alpha = CGFloat( enabled ? options.enabledOverlayButtonAlpha : options.disabledOverlayButtonAlpha )
        UIView.animateWithDuration(0.15,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.deleteTextButton.alpha = alpha
            },
            completion: { finished in
                if finished {
                    self.selectBackgroundColorButton.enabled = enabled
                    self.selectTextColorButton.enabled = enabled
                    self.selectTextFontButton.enabled = enabled
                    self.deleteTextButton.enabled = enabled
                    self.bringToFrontButton.enabled = enabled
                }
           })
     }

    // MARK: - text object restore

    private func rerenderPreviewWithoutText() {
        updatePreviewImageWithCompletion { () -> (Void) in
            self.overlayConverter?.addUIElementsFromSpriteFilters(self.tempTextCopy, containerView:self.textClipView, previewSize: self.previewImageView.visibleImageFrame.size)
       }
    }

    private func backupTexts() {
        tempTextCopy = fixedFilterStack.spriteFilters
    }

    private func showColorSelctionViews() {
        self.pullableColorPickerView.hidden = false
        self.textColorSelectorView.hidden = false
        self.acceptColorButton.hidden = false
        self.rejectColorButton.hidden = false

        acceptColorButtonConstraint.constant = -upperOverlayButtonConstant
        rejectColorButtonConstraint.constant = -upperOverlayButtonConstant
        addTextButtonConstraint.constant = -upperOverlayButtonConstant
        deleteButtonConstraint.constant = -upperOverlayButtonConstant

        view.needsUpdateConstraints()
        UIView.animateWithDuration(0.2,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.addTextButton.alpha = 0.0
                self.deleteTextButton.alpha = 0.0
                self.acceptColorButton.alpha = self.options.enabledOverlayButtonAlpha
                self.rejectColorButton.alpha = self.options.enabledOverlayButtonAlpha
                self.textColorSelectorView.alpha = 1.0
                self.pullableColorPickerView.alpha = 1.0
                self.view.layoutIfNeeded()
            },
            completion: { finished in
                if finished {
                    self.addTextButton.hidden = true
                    self.deleteTextButton.hidden = true
                    self.colorPickerView.hidden = false
                }
        })

        if textLabel.layer.borderWidth > 0 {
            if selectBackgroundColor {
                colorPickerView.color = textLabel.backgroundColor!
            } else {
                colorPickerView.color = textLabel.textColor
            }
        }
    }

    private func hideColorSelctionViews() {
        if pullableColorPickerView.opened {
            pullableColorPickerView.setOpened(false, animated: true)
        }
        addTextButton.hidden = false
        deleteTextButton.hidden = false
        colorPickerView.hidden = true

        acceptColorButtonConstraint.constant = -lowerOverlayButtonConstant
        rejectColorButtonConstraint.constant = -lowerOverlayButtonConstant
        addTextButtonConstraint.constant = -lowerOverlayButtonConstant
        deleteButtonConstraint.constant = -lowerOverlayButtonConstant

        let buttonAlpha = textLabel.layer.borderWidth > 0 ? options.enabledOverlayButtonAlpha : options.disabledOverlayButtonAlpha

        view.needsUpdateConstraints()
        UIView.animateWithDuration(0.2,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.addTextButton.alpha = self.options.enabledOverlayButtonAlpha
                self.deleteTextButton.alpha = buttonAlpha
                self.acceptColorButton.alpha = 0.0
                self.rejectColorButton.alpha = 0.0
                self.pullableColorPickerView.alpha = 0.0
                self.textColorSelectorView.alpha = 0.0
                self.view.layoutIfNeeded()
            },
            completion: { finished in
                if finished {
                    self.acceptColorButton.hidden = true
                    self.rejectColorButton.hidden = true
                    self.pullableColorPickerView.hidden = true
                    self.textColorSelectorView.hidden = true
                }
        })
    }

    private func showFontSelctionViews() {
        self.pullableFontSelectorView.hidden = false
        self.fontSelectorView.hidden = false
        self.acceptFontButton.hidden = false
        self.rejectFontButton.hidden = false
        self.fontQuickSelectorView.hidden = false

        acceptFontButtonConstraint.constant = -upperOverlayButtonConstant
        rejectFontButtonConstraint.constant = -upperOverlayButtonConstant
        addTextButtonConstraint.constant = -upperOverlayButtonConstant
        deleteButtonConstraint.constant = -upperOverlayButtonConstant

        view.needsUpdateConstraints()
        UIView.animateWithDuration(0.2,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.addTextButton.alpha = 0.0
                self.deleteTextButton.alpha = 0.0
                self.acceptFontButton.alpha = self.options.enabledOverlayButtonAlpha
                self.rejectFontButton.alpha = self.options.enabledOverlayButtonAlpha
                self.pullableFontSelectorView.alpha = 1.0
                self.fontQuickSelectorView.alpha = 1.0
                self.view.layoutIfNeeded()
            },
            completion: { finished in
                if finished {
                    self.addTextButton.hidden = true
                    self.deleteTextButton.hidden = true
                }
        })
        updateFontSelectorData()
    }

    private func updateFontSelectorData() {
        if textLabel.layer.borderWidth > 0 {
            fontSelectorView.text = textLabel.text!
            fontSelectorView.selectedFontName = textLabel.font!.fontName
            fontQuickSelectorView.selectedFontName = textLabel.font!.fontName
            selectTextFontButton.fontName = textLabel.font!.fontName
        }
    }

    private func hideFontSelctionViews() {
        if pullableFontSelectorView.opened {
            pullableFontSelectorView.setOpened(false, animated: true)
        }
        addTextButton.hidden = false
        deleteTextButton.hidden = false

        acceptFontButtonConstraint.constant = -lowerOverlayButtonConstant
        rejectFontButtonConstraint.constant = -lowerOverlayButtonConstant
        addTextButtonConstraint.constant = -lowerOverlayButtonConstant
        deleteButtonConstraint.constant = -lowerOverlayButtonConstant

        let buttonAlpha = textLabel.layer.borderWidth > 0 ? options.enabledOverlayButtonAlpha : options.disabledOverlayButtonAlpha

        view.needsUpdateConstraints()
        UIView.animateWithDuration(0.2,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.addTextButton.alpha = self.options.enabledOverlayButtonAlpha
                self.deleteTextButton.alpha = buttonAlpha
                self.acceptFontButton.alpha = 0.0
                self.rejectFontButton.alpha = 0.0
                self.pullableFontSelectorView.alpha = 0.0
                self.fontQuickSelectorView.alpha = 0.0
                self.view.layoutIfNeeded()
            },
            completion: { finished in
                if finished {
                    self.acceptFontButton.hidden = true
                    self.rejectFontButton.hidden = true
                    self.fontQuickSelectorView.hidden = true
                    self.pullableFontSelectorView.hidden = true
                }
        })
    }
}

// MARK: - extensions

extension TextEditorViewController: TextColorSelectorViewDelegate {
    public func textColorSelectorView(selectorView: TextColorSelectorView, didSelectColor color: UIColor) {
        if selectBackgroundColor {
            colorPickerView.color = color
            textLabel.backgroundColor = color
            selectBackgroundColorButton.imageView.tintColor = color
        } else {
            colorPickerView.color = color
            textLabel.textColor = color
            textColor = color
            selectTextColorButton.imageView.tintColor = color
        }

    }
}

extension TextEditorViewController: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }

    public func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        hideBlurredContainer()

        if let newText = textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
            if newText.characters.count > 0 {
                if createNewText {
                    unSelectTextLabel(textLabel)
                    textLabel = TextLabel()
                    configureTextLabel()
                    textLabel.text = newText
                    setInitialTextLabelSize()
                    textClipView.bringSubviewToFront(textLabel)
                } else if newText.characters.count > 0 {
                    textLabel.text = newText
                    textLabel.sizeToFit()
                }
                selectTextLabel(textLabel)
                updateButtonStatus()
                updateFontSelectorData()
            } else {
                if !createNewText {
                    textLabel.removeFromSuperview()
                }
            }
        }
        navigationItem.rightBarButtonItem?.enabled = true
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, textLabel)

        return true
    }

    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension TextEditorViewController: FontSelectorViewDelegate {
    public func fontSelectorView(fontSelectorView: FontSelectorView, didSelectFontWithName fontName: String) {
        self.fontName = fontName
        fontQuickSelectorView.selectedFontName = fontName
        if textLabel.layer.borderWidth > 0 {
            textLabel.font = UIFont(name: fontName, size: currentTextSize)
            textLabel.sizeToFit()
            selectTextFontButton.fontName = fontName
        }
    }
}

extension TextEditorViewController: FontQuickSelectorViewDelegate {
    public func fontSelectorView(selectorView: FontQuickSelectorView, didSelectFont fontName: String) {
        self.fontName = fontName
        fontSelectorView.selectedFontName = fontName
        if textLabel.layer.borderWidth > 0 {
            textLabel.font = UIFont(name: fontName, size: currentTextSize)
            textLabel.sizeToFit()
            selectTextFontButton.fontName = fontName
        }
    }
}

extension TextEditorViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UIPinchGestureRecognizer && otherGestureRecognizer is UIRotationGestureRecognizer) || (gestureRecognizer is UIRotationGestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer) {
            return true
        }
        return false
    }
}

extension TextEditorViewController: ColorPickerViewDelegate {
    public func colorPicked(colorPickerView: ColorPickerView, didPickColor color: UIColor) {
        if selectBackgroundColor {
            textLabel.backgroundColor = color
//            selectBackgroundColorButton.imageView.tintColor = color
            selectBackgroundColorButton.imageView.image = colorButtonImageGenerator.imageWithColor(color)
        } else {
            textLabel.textColor = color
            textColor = color
            selectTextColorButton.imageView.image = colorButtonImageGenerator.imageWithColor(color)
            //selectTextColorButton.imageView.tintColor = color
        }
    }

    public func canceledColorPicking(colorPickerView: ColorPickerView) {
        hideBlurredContainer()
    }
}
