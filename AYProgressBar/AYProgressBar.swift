//
//  AYProgressBar.swift
//  AYProgressBar
//
//  Created by Abdorahman Youssef on 12/22/18.
//  Copyright © 2018 Abdorahman Youssef. All rights reserved.
//

import UIKit

enum ProgressLabelFormat: Int{
    case full
    case mid
    case short
    
    public func exampleFormat() -> String{
        switch self {
        case .full:
            return "0d:0h:0m"
        case .mid:
            return "0h:0m"
        case .short:
            return "0m"
        }
    }
    
    public init(value: Int){
        switch value {
        case ProgressLabelFormat.full.rawValue:
            self = ProgressLabelFormat.full
        case ProgressLabelFormat.mid.rawValue:
            self = ProgressLabelFormat.mid
        case ProgressLabelFormat.short.rawValue:
            self = ProgressLabelFormat.short
        default:
            self = ProgressLabelFormat.full
        }
    }
}

@IBDesignable
class AYProgressBar: UIView {
    
    // MARK: -Properties

    private var trackLayer: CAShapeLayer = CAShapeLayer()
    private var progressLayer: CAShapeLayer = CAShapeLayer()
    lazy private var viewCenter: CGPoint = CGPoint(x: frame.width / 2, y: frame.height / 2)
    private var radius: CGFloat{
        get{
            var minimumLenght = frame.height
            if frame.width < minimumLenght{
                minimumLenght = frame.width
            }
            return (minimumLenght * 0.9) / 2
        }
        set{
            self.radius = newValue
        }
    }
    private var timer : Timer?
    // It represented as seconds
    private var counter: Double = 0{
        didSet{
            handleTimerLabelLogic()
        }
    }
    private var progressLabel: UILabel = UILabel()
    
    // MARK: -Constants
    
    private let min = Double(60)
    private let hour = Double(60 * 60)
    private let day = Double(24 * 60 * 60)
    private let minAbbr = "m"
    private let hourAbbr = "h"
    private let dayAbbr = "d"
    
    // MARK: -Inespectables
    
    @IBInspectable
    var labelTextColor: UIColor = UIColor.black{
        didSet{
            progressLabel.textColor = labelTextColor
        }
    }
    var labelFont: UIFont = UIFont.systemFont(ofSize: 17){
        didSet{
            progressLabel.font = labelFont
        }
    }
    @IBInspectable
    var trackStrokeColor: UIColor = UIColor.lightGray{
        didSet{
            trackLayer.strokeColor = trackStrokeColor.cgColor
        }
    }
    @IBInspectable
    var progressStrokeColor: UIColor = UIColor.red{
        didSet{
            progressLayer.strokeColor = progressStrokeColor.cgColor
        }
    }
    @IBInspectable
    var strokeWidth: CGFloat = 5{
        didSet{
            trackLayer.lineWidth = strokeWidth
            progressLayer.lineWidth = strokeWidth
        }
    }
    @IBInspectable
    var progressLabelType: Int = ProgressLabelFormat.full.rawValue {
        didSet{
            let labelFormat = ProgressLabelFormat.init(value: progressLabelType)
            progressLabel.text = labelFormat.exampleFormat()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        setupView()
    }
    // MARK: -Methods
    
    private func setupView(){
        setupTrackView()
        setupProgressView()
        setupLabel()
    }
    
    private func setupTrackView(){
        let path = UIBezierPath.init(arcCenter: viewCenter, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: true)
        trackLayer.path = path.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackStrokeColor.cgColor
        trackLayer.lineWidth = strokeWidth
        layer.addSublayer(trackLayer)
    }
    
    private func setupProgressView(){
        let path = UIBezierPath.init(arcCenter: viewCenter, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: true)
        progressLayer.path = path.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressStrokeColor.cgColor
        progressLayer.lineWidth = 5
        progressLayer.strokeEnd = 0
        progressLayer.lineCap = kCALineCapRound
        layer.addSublayer(progressLayer)
    }
    
    private func handleProgressBarAnimation(){
        let animation = CABasicAnimation.init(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = counter
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "move")
    }
    
    private func setupLabel(){
        addSubview(progressLabel)
        progressLabel.textAlignment = .center
        progressLabel.adjustsFontSizeToFitWidth = true
        progressLabel.minimumScaleFactor = 0.5
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        progressLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        progressLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        progressLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        progressLabel.text = ProgressLabelFormat.init(value: progressLabelType).exampleFormat()
    }
    
    func startProgress(withValue value: Double){
        guard timer == nil || !(timer?.isValid ?? true) else {
            return
        }
        // convert it to seconds
        counter = value * min
        handleTimerLabelLogic()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerDidChange), userInfo: nil, repeats: true)
        handleProgressBarAnimation()
    }
    
    @objc public func timerDidChange(){
        guard counter != 0 else {
            print("Timer finished")
            timer?.invalidate()
            return
        }
        counter -= 1
    }
    
    private func handleTimerLabelLogic(){
        var progressNewText = String()
        switch progressLabelType {
        case ProgressLabelFormat.full.rawValue:
            progressNewText = handleFullFormat(withValue: counter)
        case ProgressLabelFormat.mid.rawValue:
            progressNewText = handleMidFormat(withValue: counter)
        case ProgressLabelFormat.short.rawValue:
            progressNewText = handleShortFormat(withValue: counter)
        default:
            progressNewText = handleFullFormat(withValue: counter)
        }
        progressLabel.text = progressNewText
    }
    
    private func handleFullFormat(withValue value: Double) -> String{
        let dayCounter = value / day
        let substractedValue = value.truncatingRemainder(dividingBy: day)
        let hourText = handleMidFormat(withValue: substractedValue)
        return "\(Int(dayCounter))\(dayAbbr):\(hourText)"
    }
    
    private func handleMidFormat(withValue value: Double) -> String{
        let hourCounter = value / hour
        let substractedValue = value.truncatingRemainder(dividingBy: hour)
        let minText = handleShortFormat(withValue: substractedValue)
        return "\(Int(hourCounter))\(hourAbbr):\(minText)"
    }

    private func handleShortFormat(withValue value: Double) -> String{
        return "\(Int(value / min))\(minAbbr)"
    }
}
