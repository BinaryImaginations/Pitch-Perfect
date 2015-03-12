//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by George McMullen on 3/7/15.
//  Copyright (c) 2015 George McMullen. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    // Variables
    var receivedAudio:RecordedAudio!              // Custom class to hold filePathUrl and title for our audio
    var audioPlayer:AVAudioPlayer!                // Audio player used for modifying the rate
    var audioFile:AVAudioFile!                    // audio file used by the audio player node for pitch modifications
    var audioEngine:AVAudioEngine!                // Audio engine used to create the audio player node

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        // NOTE:  To modify the play rate, we use th AVAudioPlayer object and for the pitch, we use AVAudioPlayerNode
        //
        // AVAudioPlayer - Create the object using the generated filePathURL
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer.enableRate = true             // Enable the rate flag allowing us to modify the play rate
        // AVAudioPlayerNode - Create the AVAudioEngine and the AVAudioFile used by the audio player node
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playChipmunkAudio(sender: AnyObject) {
        // Play the current audio with a pitch of 1000
        playAudioWithVariablePitch(1000)
    }

    @IBAction func playDarthvaderAudio(sender: UIButton) {
        // Play the current audio with a pitch of -1000
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func playSlowAudio(sender: UIButton) {
        // Play the current audio with a speed of 0.5 (1/2)
        playAudioFromStart(0.5)
    }
    
    @IBAction func playFastAudio(sender: UIButton) {
        // Play the current audio with a speed of 1.5 (1 1/2)
        playAudioFromStart(1.5)
    }
    
    @IBAction func playEchoAudio(sender: UIButton) {
        // Play the current audio with an echo of 0.5
        playAudioWithEcho(0.25)
    }
    
    @IBAction func playReverbAudio(sender: UIButton) {
        // Play the current audio with a reverb
        playAudioWithReverb(50)
    }
    
    @IBAction func stopAudioPlayback(sender: UIButton) {
        // Stop all playback
        stopAudioPlayback()
    }
    
    @IBAction func stopAudioPlayback() {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
    
    func playAudioWithEcho(echo: NSTimeInterval) {
        // Stop all playback
        stopAudioPlayback()
        
        // Create and initialize the audio player node
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        // Create and initialize the audio unit dealy (echo)
        var audioDelay = AVAudioUnitDelay()
        audioDelay.delayTime = echo
        
        // Attach the audio unit delay to the audio engine
        audioEngine.attachNode(audioDelay)
        
        // Connect the player node to the engine
        audioEngine.connect(audioPlayerNode, to: audioDelay, format: nil)
        // Connect the audio unit delay to the engine's output
        audioEngine.connect(audioDelay, to: audioEngine.outputNode, format: nil)
        
        // Add the audio file to the player node
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        // Start the audio engine
        audioEngine.startAndReturnError(nil)
        
        // Redirect the audio to the external speaker
        redirectAudioToSpeaker()
        
        // Start audio playback
        audioPlayerNode.play()
    }
    
    func playAudioWithReverb(reverb: Float) {
        // Stop all playback
        stopAudioPlayback()
        
        // Create and initialize the audio player node
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        // Create and initialize the audio unit reverb
        var audioReverb = AVAudioUnitReverb()
        
        audioReverb.wetDryMix = reverb
        
        // Attach the audio unit delay to the audio engine
        audioEngine.attachNode(audioReverb)
        
        // Connect the player node to the engine
        audioEngine.connect(audioPlayerNode, to: audioReverb, format: nil)
        // Connect the audio unit delay to the engine's output
        audioEngine.connect(audioReverb, to: audioEngine.outputNode, format: nil)
        
        // Add the audio file to the player node
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        // Start the audio engine
        audioEngine.startAndReturnError(nil)
        
        // Redirect the audio to the external speaker
        redirectAudioToSpeaker()
        
        // Start audio playback
        audioPlayerNode.play()
    }
    
    func playAudioWithVariablePitch(pitch: Float) {
        // Stop all playback
        stopAudioPlayback()
        
        // Create and initialize the audio player node
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        // Create and initialize the audio unit time pitch
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        
        // Attach the audio unit time pitch to the audio engine
        audioEngine.attachNode(changePitchEffect)
        
        // Connect the player node to the engine
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        // Connect the unit time pitch to the engine's output
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        // Add the audio file to the player node
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        // Start the audio engine
        audioEngine.startAndReturnError(nil)
        
        // Redirect the audio to the external speaker
        redirectAudioToSpeaker()
        
        
        // Start audio playback
        audioPlayerNode.play()
    }
    
    func playAudioFromStart(speed: Float) {
        // Stop all playback
        stopAudioPlayback()
        
        // Set the play rate
        audioPlayer.rate = speed
        // Reset to the start of the clip
        audioPlayer.currentTime = 0.0
        // Set the volume to 100%
        audioPlayer.volume = 1
        
        // Redirect the audio to the external speaker
        redirectAudioToSpeaker()
        
        // Start the audio playback
        audioPlayer.play()
    }

    func redirectAudioToSpeaker() {
        // Redirect the playback to the large speakers on the iPhone devices (bottom of the device)
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker, error: nil)
    }
}
