//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Zhanassyl Rysbek on 29.10.2026.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!

    let tracks = TrackLibrary.tracks

    // state of the screen
    var currentIndex = 0
    var isPlaying = false

    // stored as a property so it is not deallocated while playing
    var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTrack()
        updateUI()
    }

    func loadTrack() {
        let track = tracks[currentIndex]

        guard let url = Bundle.main.url(forResource: track.fileName, withExtension: "mp3") else {
            print("File not found: \(track.fileName).mp3")
            player = nil
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
        } catch {
            print("Could not load \(track.fileName).mp3: \(error.localizedDescription)")
            player = nil
        }
    }

    func updateUI() {
        let track = tracks[currentIndex]
        coverImageView.image = UIImage(named: track.coverImageName)
        titleLabel.text = track.title
        artistLabel.text = track.artist

        let iconName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.configuration?.image = UIImage(systemName: iconName)
    }

    func play() {
        // play() returns false if the player is nil or the file is broken
        isPlaying = player?.play() ?? false
    }

    func changeTrack(by step: Int) {
        let wasPlaying = isPlaying
        player?.stop()

        // wrap around: after the last comes the first, before the first comes the last
        currentIndex = (currentIndex + step + tracks.count) % tracks.count
        loadTrack()

        if wasPlaying {
            play()
        } else {
            isPlaying = false
        }
        updateUI()
    }

    @IBAction func playPauseTapped(_ sender: UIButton) {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            play()
        }
        updateUI()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        changeTrack(by: 1)
    }

    @IBAction func previousTapped(_ sender: UIButton) {
        changeTrack(by: -1)
    }

    // MARK: - AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // isPlaying is still true here, so the next track starts by itself
        changeTrack(by: 1)
    }
}
