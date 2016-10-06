//
//  DGRunkeeperSwitch.swift
//  DGRunkeeperSwitchExample
//
//  Created by Danil Gontovnik on 9/3/15.
//  Copyright © 2015 Danil Gontovnik. All rights reserved.
//

import UIKit

// MARK: -
// MARK: DGRunkeeperSwitchRoundedLayer

public class DGRunkeeperSwitchRoundedLayer: CALayer {
    
    override public var bounds: CGRect {
        didSet { cornerRadius = bounds.height / 2.0 }
    }
    
}

// MARK: -
// MARK: DGRunkeeperSwitch


@IBDesignable
public class DGRunkeeperSwitch: UIControl {
    
    // MARK: -
    // MARK: Public vars
    
    @IBInspectable
    public var leftTitle: String {
        set { (leftTitleLabel.text, selectedLeftTitleLabel.text) = (newValue, newValue) }
        get { return leftTitleLabel.text! }
    }
    
    @IBInspectable
    public var centerTitle: String {
        set { (centerTitleLabel.text, selectedCenterTitleLabel.text) = (newValue, newValue) }
        get { return centerTitleLabel.text! }
    }
    
    @IBInspectable
    public var rightTitle: String {
        set { (rightTitleLabel.text, selectedRightTitleLabel.text) = (newValue, newValue) }
        get { return rightTitleLabel.text! }
    }
    
    @IBInspectable
    private(set) public var selectedIndex: Int = 0
    
    public var selectedBackgroundInset: CGFloat = 2.0 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable
    public var selectedBackgroundColor: UIColor! {
        set { selectedBackgroundView.backgroundColor = newValue }
        get { return selectedBackgroundView.backgroundColor }
    }
    
    @IBInspectable
    public var titleColor: UIColor! {
        set { (leftTitleLabel.textColor, centerTitleLabel.textColor, rightTitleLabel.textColor) = (newValue, newValue, newValue) }
        get { return leftTitleLabel.textColor }
    }
    
    @IBInspectable
    public var selectedTitleColor: UIColor! {
        set { (selectedLeftTitleLabel.textColor, selectedCenterTitleLabel.textColor, selectedRightTitleLabel.textColor) = (newValue, newValue, newValue) }
        get { return selectedLeftTitleLabel.textColor }
    }
    
    public var titleFont: UIFont! {
        set { (leftTitleLabel.font, centerTitleLabel.font, rightTitleLabel.font, selectedLeftTitleLabel.font, selectedCenterTitleLabel.font, selectedRightTitleLabel.font) = (newValue, newValue, newValue, newValue, newValue, newValue) }
        get { return leftTitleLabel.font }
    }
    
    public var animationDuration: NSTimeInterval = 0.3
    public var animationSpringDamping: CGFloat = 0.75
    public var animationInitialSpringVelocity: CGFloat = 0.0
    
    // MARK: -
    // MARK: Private vars
    
    private var titleLabelsContentView = UIView()
    public var leftTitleLabel = UILabel()
    public var centerTitleLabel = UILabel()
    public var rightTitleLabel = UILabel()
    
    private var selectedTitleLabelsContentView = UIView()
    public var selectedLeftTitleLabel = UILabel()
    public var selectedCenterTitleLabel = UILabel()
    public var selectedRightTitleLabel = UILabel()
    
    private(set) var selectedBackgroundView = UIView()
    
    private var titleMaskView: UIView = UIView()
    
    private var tapGesture: UITapGestureRecognizer!
    private var panGesture: UIPanGestureRecognizer!
    
    private var initialSelectedBackgroundViewFrame: CGRect?
    
    // MARK: -
    // MARK: Constructors
    
    public init(leftTitle: String!, centerTitle: String!, rightTitle: String!) {
        super.init(frame: CGRect.zero)
        
        self.leftTitle = leftTitle
        self.centerTitle = centerTitle
        self.rightTitle = rightTitle
        
        
        finishInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        finishInit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        finishInit()
    }
    
    private func finishInit() {
        // Setup views
        (leftTitleLabel.lineBreakMode, centerTitleLabel.lineBreakMode, rightTitleLabel.lineBreakMode) = (.ByTruncatingTail, .ByTruncatingTail, .ByTruncatingTail)
        
        titleLabelsContentView.addSubview(leftTitleLabel)
        titleLabelsContentView.addSubview(centerTitleLabel)
        titleLabelsContentView.addSubview(rightTitleLabel)
        addSubview(titleLabelsContentView)
        
        object_setClass(selectedBackgroundView.layer, DGRunkeeperSwitchRoundedLayer.self)
        addSubview(selectedBackgroundView)
        
        selectedTitleLabelsContentView.addSubview(selectedLeftTitleLabel)
        selectedTitleLabelsContentView.addSubview(selectedCenterTitleLabel)
        selectedTitleLabelsContentView.addSubview(selectedRightTitleLabel)
        addSubview(selectedTitleLabelsContentView)
        
        (leftTitleLabel.textAlignment, rightTitleLabel.textAlignment, centerTitleLabel.textAlignment, selectedLeftTitleLabel.textAlignment, selectedRightTitleLabel.textAlignment, selectedCenterTitleLabel.textAlignment) = (.Center, .Center, .Center, .Center, .Center, .Center)
        
        (leftTitleLabel.font, rightTitleLabel.font, centerTitleLabel.font, selectedLeftTitleLabel.font, selectedRightTitleLabel.font, selectedCenterTitleLabel.font) = (leftTitleLabel.font.fontWithSize(8), rightTitleLabel.font.fontWithSize(8), centerTitleLabel.font.fontWithSize(8), selectedLeftTitleLabel.font.fontWithSize(8), selectedRightTitleLabel.font.fontWithSize(8), selectedCenterTitleLabel.font.fontWithSize(8))
        
        object_setClass(titleMaskView.layer, DGRunkeeperSwitchRoundedLayer.self)
        titleMaskView.backgroundColor = .blackColor()
        selectedTitleLabelsContentView.layer.mask = titleMaskView.layer
        
        // Setup defaul colors
        backgroundColor = .blackColor()
        selectedBackgroundColor = .whiteColor()
        titleColor = .whiteColor()
        selectedTitleColor = .blackColor()
        
        // Gestures
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(DGRunkeeperSwitch.tapped(_:)))
        addGestureRecognizer(tapGesture)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(DGRunkeeperSwitch.pan(_:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        
        addObserver(self, forKeyPath: "selectedBackgroundView.frame", options: .New, context: nil)
    }
    
    // MARK: -
    // MARK: Destructor
    
    deinit {
        removeObserver(self, forKeyPath: "selectedBackgroundView.frame")
    }
    
    // MARK: -
    // MARK: Observer
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "selectedBackgroundView.frame" {
            titleMaskView.frame = selectedBackgroundView.frame
        }
    }
    
    // MARK: -
    
    override public class func layerClass() -> AnyClass {
        return DGRunkeeperSwitchRoundedLayer.self
    }
    
    func tapped(gesture: UITapGestureRecognizer!) {
        let location = gesture.locationInView(self)
        if location.x < bounds.width / 3.0 {
            setSelectedIndex(0, animated: true)
        } else if location.x < bounds.width / 1.9 {
            setSelectedIndex(1, animated: true)
        } else {
            setSelectedIndex(2, animated: true)
        }
    }
    
    func pan(gesture: UIPanGestureRecognizer!) {
        if gesture.state == .Began {
            initialSelectedBackgroundViewFrame = selectedBackgroundView.frame
        } else if gesture.state == .Changed {
            var frame = initialSelectedBackgroundViewFrame!
            frame.origin.x += gesture.translationInView(self).x
            frame.origin.x = max(min(frame.origin.x, bounds.width - selectedBackgroundInset - frame.width), selectedBackgroundInset)
            selectedBackgroundView.frame = frame
        } else if gesture.state == .Ended || gesture.state == .Failed || gesture.state == .Cancelled {
            let velocityX = gesture.velocityInView(self).x
            if velocityX > 500.0 {
                setSelectedIndex(1, animated: true)
            } else if velocityX < -500.0 {
                setSelectedIndex(0, animated: true)
            } else if selectedBackgroundView.center.x >= bounds.width / 3.0 {
                setSelectedIndex(1, animated: true)
            } else if selectedBackgroundView.center.x < bounds.size.width / 2.0 {
                setSelectedIndex(0, animated: true)
            } else {
                setSelectedIndex(2, animated: true)
            }
        }
    }
    
    public func setSelectedIndex(selectedIndex: Int, animated: Bool) {
        
        // Reset switch on half pan gestures
        var catchHalfSwitch:Bool = false
        if self.selectedIndex == selectedIndex {
            catchHalfSwitch = true
        }
        
        self.selectedIndex = selectedIndex
        if animated {
            if (!catchHalfSwitch) {
                self.sendActionsForControlEvents(.ValueChanged)
            }
            UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: animationSpringDamping, initialSpringVelocity: animationInitialSpringVelocity, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseOut], animations: { () -> Void in
                self.layoutSubviews()
                }, completion: nil)
        } else {
            layoutSubviews()
            sendActionsForControlEvents(.ValueChanged)
        }
    }
    
    // MARK: -
    // MARK: Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let selectedBackgroundWidth = bounds.width / 3.0 - selectedBackgroundInset * 3.0 + 2
        selectedBackgroundView.frame = CGRect(x: selectedBackgroundInset + CGFloat(selectedIndex) * (selectedBackgroundWidth + selectedBackgroundInset * 3.0), y: selectedBackgroundInset + 1, width: selectedBackgroundWidth, height: bounds.height - selectedBackgroundInset * 3.0)
        
        (titleLabelsContentView.frame, selectedTitleLabelsContentView.frame) = (bounds, bounds)
        
        let titleLabelMaxWidth = selectedBackgroundWidth
        let titleLabelMaxHeight = bounds.height - selectedBackgroundInset * 3.0
        
        var leftTitleLabelSize = leftTitleLabel.sizeThatFits(CGSize(width: titleLabelMaxWidth, height: titleLabelMaxHeight))
        leftTitleLabelSize.width = min(leftTitleLabelSize.width, titleLabelMaxWidth)
        
        let leftTitleLabelOrigin = CGPoint(x: floor((bounds.width / 3.0 - leftTitleLabelSize.width) / 3.0), y: floor((bounds.height - leftTitleLabelSize.height) / 3.0) + 5)
        let leftTitleLabelFrame = CGRect(origin: leftTitleLabelOrigin, size: leftTitleLabelSize)
        (leftTitleLabel.frame, selectedLeftTitleLabel.frame) = (leftTitleLabelFrame, leftTitleLabelFrame)
        
        var centerTitleLabelSize = centerTitleLabel.sizeThatFits(CGSize(width: titleLabelMaxWidth, height: titleLabelMaxHeight))
        centerTitleLabelSize.width = min(centerTitleLabelSize.width, titleLabelMaxWidth)
        
        
        
        let centerTitleLabelOrigin = CGPoint(x: floor(bounds.size.width / 3.0 + (bounds.width / 3.0 - centerTitleLabelSize.width) / 3.0), y: floor((bounds.height - centerTitleLabelSize.height) / 3.0) + 5)
        let centerTitleLabelFrame = CGRect(origin: centerTitleLabelOrigin, size: centerTitleLabelSize)
        (centerTitleLabel.frame, selectedCenterTitleLabel.frame) = (centerTitleLabelFrame, centerTitleLabelFrame)
        
        
        var rightTitleLabelSize = rightTitleLabel.sizeThatFits(CGSize(width: titleLabelMaxWidth, height: titleLabelMaxHeight))
        rightTitleLabelSize.width = min(rightTitleLabelSize.width, titleLabelMaxWidth)
        
        let x1 = bounds.size.width / 3.0 + (bounds.width / 3.0 - rightTitleLabelSize.width) / 3.0
        let x2 = bounds.size.width / 3.0 + (bounds.width / 3.0 - leftTitleLabelSize.width) / 3.0
        
        let x = x1 + x2 - 4
        
        let rightTitleLabelOrigin = CGPoint(x: floor(x), y: floor((bounds.height - rightTitleLabelSize.height) / 3.0) + 5)
        let rightTitleLabelFrame = CGRect(origin: rightTitleLabelOrigin, size: rightTitleLabelSize)
        (rightTitleLabel.frame, selectedRightTitleLabel.frame) = (rightTitleLabelFrame, rightTitleLabelFrame)
        
    }
    public func setSelectedIndexSwitch(selectedIndex: Int, animated: Bool) {
        guard 0..<3 ~= selectedIndex else { return }
        
        // Reset switch on half pan gestures
        var catchHalfSwitch:Bool = false
        if self.selectedIndex == selectedIndex {
            catchHalfSwitch = true
        }
        
        self.selectedIndex = selectedIndex
        if animated {
            if (!catchHalfSwitch) {
                self.sendActionsForControlEvents(.ValueChanged)
            }
            UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: animationSpringDamping, initialSpringVelocity: animationInitialSpringVelocity, options: [UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseOut], animations: { () -> Void in
                self.layoutSubviews()
                }, completion: nil)
        } else {
            layoutSubviews()
            sendActionsForControlEvents(.ValueChanged)
        }
    }
    
}

// MARK: -
// MARK: UIGestureRecognizer Delegate

extension DGRunkeeperSwitch: UIGestureRecognizerDelegate {
    
    override public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGesture {
            return selectedBackgroundView.frame.contains(gestureRecognizer.locationInView(self))
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
}
