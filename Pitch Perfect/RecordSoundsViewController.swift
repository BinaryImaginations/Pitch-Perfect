//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by George McMullen on 3/5/15.
//  Copyright (c) 2015 George McMullen. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    // Variables
    @IBOutlet weak var recordingInProgress: UILabel!    // Flag used to determine if we are currently recording
    @IBOutlet weak var stopButton: UIButton!            // Stop record button outlet
    @IBOutlet weak var recordButton: UIButton!          // Record button outlet
    
    var audioRecorder:AVAudioRecorder!                  // Audio recorder
    var recordedAudio:RecordedAudio!                    // Recorded audio
   
    var microphoneImage: UIImage!                       // Dynamic microphone images
    var microphoneAddImage: UIImage!
    var microphonePauseImage: UIImage!
    
    var recordingStarted = false                        // Recoring started flag
    var recordingFlag = false                           // Currently recording flag

    override func viewDidLoad() {
        super.viewDidLoad()
        // Used for intitial setup
        // Do any additional setup after loading the view, typically from a nib
        
        // Load the dynamic record (microphone) images
        microphoneImage = UIImage(named: "Microphone.png")
        microphoneAddImage = UIImage(named: "MicrophoneAdd.png")
        microphonePauseImage = UIImage(named: "MicrophonePause.png")
        // Validate that they all loaded
        if (microphoneImage == nil || microphoneAddImage == nil || microphonePauseImage == nil) {
            println("RecordSoundsViewController.viewDidLoad() - Unable to load microphone images")
        }
        
        // Initial state setup
        stopButton.hidden = true                        // Hide the stop button
        recordButton.setImage(microphoneImage, forState: .Normal)   // Set the initial microphone image
        recordButton.enabled = true                     // Display the record button
        recordingStarted = false                        // Initial state is that we haven't started yet
        recordingFlag = false                           // Initial state is that we aren't currently recording
        setRecordingMessage("Tap to Record")            // Set initial recording message
    }
    
    override func viewDidAppear(animated: Bool) {
        stopButton.hidden = true                        // Set the state to hidden
        
        // Set the initial state and image for the record button
        recordButton.setImage(microphoneImage, forState: .Normal)
        recordButton.enabled = true
        recordingStarted = false                        // Initial state is that we haven't started yet
        recordingFlag = false                           // Initial state is that we aren't currently recording
        setRecordingMessage("Tap to Record")            // Set initial recording message
    }
    
    override func viewWillAppear(animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func recordAudio(sender: UIButton) {
        //
        // Record (microphone) button was pressed
        // Check the current state to determine what to do
        if (recordingFlag) {                            // We are currently recording
            // Pause the recording
            recordingFlag = false
            recordButton.setImage(microphoneAddImage, forState: .Normal)
            audioRecorder.pause()                       // Pause the recorder
            setRecordingMessage("Press to Resume Recording") // Set recording message
        } else if (recordingStarted) {                  // We are current paused
            // Resume recording
            recordingFlag = true
            recordButton.setImage(microphonePauseImage, forState: .Normal)
            setRecordingMessage("Recording In Progress...") // Set recording message
            audioRecorder.record()                      // Start recording
        } else {                                        // Start a new recording
            // Start new recording
            recordingFlag = true
            recordingStarted = true
            recordButton.setImage(microphonePauseImage, forState: .Normal)
            setRecordingMessage("Recording In Progress...") // Set recording message
            stopButton.hidden = false                   // Display the stop recording button
            startRecording()                            // Start the recording
        }
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        recordingInProgress.hidden = true               // Hide the recording in progress label
        audioRecorder.stop()                            // Stop the recording
        // Get the audio session
        var audioSession = AVAudioSession.sharedInstance()
        // Deactivate it
        audioSession.setActive(false, error: nil)
    }
    
    // Simple method to set the text on the recording label and display it
    func setRecordingMessage(message: NSString?) {
        let value = String?(message!)
        recordingInProgress.text = value
        recordingInProgress.hidden = false
    }
    
    // Create the recording object and start a new recording
    func startRecording() {
        //
        // Record users voice
        // Create a path to the document directory
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        // Create unique filename using today's date and time and extension '.wav'
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        let pathArray = [dirPath, recordingName]
        // Build complete URL file path
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        // Setup audio session
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        // Initialize and prepare the audio recorder
        audioRecorder = AVAudioRecorder(URL:  filePath, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    // Initiate segue once we're finished processing the recording
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if (flag) {                                     // If successfully recorded
            // Create the custom recorded audio object
            recordedAudio = RecordedAudio(filepathurl: recorder.url!, title: recorder.url.lastPathComponent!)
            // Trigger a segue for 'stopRecording' and pass the recordedAudio objectx
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {                                        // Unsuccessful recording
            // Print an error
            println("RecordSoundViewController.audioRecorderDidFinishRecording() - Recording didn't successfully finish")
        }
    }
    
    // Perform segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Segue case statement:
        if let segueID = segue.identifier {
            switch (segueID) {
            case "stopRecording":                       // Stop Recording segue
                let playSoundVC:PlaySoundsViewController = segue.destinationViewController as PlaySoundsViewController
                let data = sender as RecordedAudio
                playSoundVC.receivedAudio = data
                break
            default:                                    // Unknown or default seque
                break
                
            }
        }
    }
}

