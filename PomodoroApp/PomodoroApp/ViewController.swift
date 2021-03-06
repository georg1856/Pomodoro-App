//
//  ViewController.swift
//  PomodoroApp
//
//  Created by Georgiy on 22.05.2022.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, CAAnimationDelegate  {
    
    let timerLabel: UILabel = {
        let label = UILabel()
        label.text = StringInfo.labelTextWork.rawValue
        label.font = UIFont.boldSystemFont(ofSize: CGFloat(Font.font))
        label.textColor = Color.foregroundWorkColor
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let startButton: UIButton = {
        let startButton = UIButton()
        startButton.setImage(UIImage(systemName: StringInfo.startButtonImagePlay.rawValue), for: .normal)
        startButton.imageView?.layer.transform = CATransform3DMakeScale(3, 3, 3)
        startButton.tintColor = Color.foregroundWorkColor
        startButton.translatesAutoresizingMaskIntoConstraints = false
        return startButton
    }()
    
    let cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.setImage(UIImage(systemName: StringInfo.cancelButtonImage.rawValue), for: .normal)
        cancelButton.imageView?.layer.transform = CATransform3DMakeScale(3, 3, 3)
        cancelButton.tintColor = Color.foregroundWorkColor
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        return cancelButton
    }()
    
    var player: AVAudioPlayer! = nil
    var timer = Timer()
    var isTimerStarted = false
    var time = Metric.timeWork
    var isAnimationStarted = false
    var isWorkTime = true
    
    let progressLayerWork = CAShapeLayer()
    let progressLayerRelax = CAShapeLayer()
    let backProgressLayer = CAShapeLayer()
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    let animationRelax = CABasicAnimation(keyPath: "strokeEnd")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setConstraints()
        drawBackLayer(with: backProgressLayer, color: Color.backgroundColor)
        drawBackLayer(with: progressLayerWork, color: Color.foregroundWorkColor)
        
        startButton.addTarget(self,
                              action: #selector(startButtonTapped),
                              for: .touchUpInside)
        
        cancelButton.addTarget(self,
                               action: #selector(cancelButtonTapped),
                               for: .touchUpInside)
    }
    
    func startButtonTrueOperation() {
        cancelButton.isEnabled = true
        cancelButton.alpha = 1
        if !isTimerStarted {
            startResumeAnimation()
            startTimer()
            isTimerStarted = true
            startButton.setImage(UIImage(systemName: StringInfo.startButtonImagePause.rawValue), for: .normal)
            startButton.tintColor = UIColor.black
        } else {
            pauseAnimation(with: progressLayerWork)
            timer.invalidate()
            isTimerStarted = false
            startButton.setImage(UIImage(systemName: StringInfo.startButtonImagePlay.rawValue), for: .normal)
            startButton.tintColor = UIColor.red
        }
    }
    
    func startButtonFalseOperation() {
        cancelButton.isEnabled = true
        cancelButton.alpha = 1
        if !isTimerStarted {
            startResumeAnimation()
            startTimer()
            isTimerStarted = true
            startButton.setImage(UIImage(systemName: StringInfo.startButtonImagePause.rawValue), for: .normal)
            startButton.tintColor = UIColor.black
        } else {
            pauseAnimation(with: progressLayerRelax)
            timer.invalidate()
            isTimerStarted = false
            startButton.setImage(UIImage(systemName: StringInfo.startButtonImagePlay.rawValue), for: .normal)
            startButton.tintColor = UIColor.green
        }
    }
    
    @objc func startButtonTapped() {
        isWorkTime ? startButtonTrueOperation() : startButtonFalseOperation()
    }
    
    func cancelButtonTrueOperation() {
        stopAnimation(with: progressLayerWork)
        cancelButton.isEnabled = false
        cancelButton.alpha = 0.5
        
        timer.invalidate()
        time = Metric.timeWork
        isTimerStarted = false
        timerLabel.text = StringInfo.labelTextWork.rawValue
        startButton.setImage(UIImage(systemName: StringInfo.startButtonImagePlay.rawValue), for: .normal)
        startButton.tintColor = UIColor.red
        drawBackLayer(with: progressLayerWork, color: UIColor.red)
    }
    
    func cancelButtonFalseOperation() {
        stopAnimation(with: progressLayerRelax)
        cancelButton.isEnabled = false
        cancelButton.alpha = 0.5
        
        timer.invalidate()
        time = Metric.timeRelax
        isTimerStarted = false
        timerLabel.text = StringInfo.labelTextRelax.rawValue
        startButton.setImage(UIImage(systemName: StringInfo.startButtonImagePlay.rawValue), for: .normal)
        startButton.tintColor = UIColor.green
        drawBackLayer(with: progressLayerRelax, color: UIColor.green)
    }
    
    @objc func cancelButtonTapped() {
        isWorkTime ? cancelButtonTrueOperation() : cancelButtonFalseOperation()
    }
    
    @objc func updateTimer() {
        if time <= 0 && !isWorkTime {
            startButton.setImage(UIImage(systemName: "play"), for: .normal)
            startButton.tintColor = UIColor.red
            cancelButton.tintColor = UIColor.red
            time = 10
            timerLabel.text = "00:10"
            timerLabel.textColor = UIColor.red
            timer.invalidate()
            isTimerStarted = false
            isWorkTime = true
            drawBackLayer(with: backProgressLayer, color: UIColor.gray)
            drawBackLayer(with: progressLayerWork, color: UIColor.red)
            isAnimationStarted = false
            music()
        } else if time <= 0 {
            startButton.setImage(UIImage(systemName: "play"), for: .normal)
            startButton.tintColor = UIColor.green
            time = 5
            timerLabel.text = "00:05"
            timerLabel.textColor = UIColor.green
            timer.invalidate()
            isTimerStarted = false
            isWorkTime = false
            drawBackLayer(with: backProgressLayer, color: UIColor.gray)
            drawBackLayer(with: progressLayerRelax, color: UIColor.green)
            cancelButton.tintColor = UIColor.green
            isAnimationStarted = false
            music()
        } else {
            time -= 0.01
            timerLabel.text = formatTime()
        }
    }
    
    func music() {
        let url = Bundle.main.url(forResource: Sound.name, withExtension: Sound.format)
        player = try! AVAudioPlayer(contentsOf: url!)
        player.play()
    }
}
