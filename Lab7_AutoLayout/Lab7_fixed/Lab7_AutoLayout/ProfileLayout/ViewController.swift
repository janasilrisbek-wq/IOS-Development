//
//  ViewController.swift
//  ProfileLayout
//
//  Created by Zhanassyl Rysbek on 21.10.2026.
//
//  Variant A · Profile.
//  Every view and every constraint lives in Main.storyboard.
//  This file only fills the labels with data — no frames, no constraints, no anchors.
//

import UIKit

struct Profile {
    let name: String
    let subtitle: String
    let posts: String
    let followers: String
    let following: String
    let about: String

    var initials: String {
        var result = ""
        for word in name.split(separator: " ").prefix(2) {
            if let letter = word.first {
                result.append(letter)
            }
        }
        return result.uppercased()
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var avatarInitialsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!

    /// Long text test: set to true to check the 2-line name.
    private let useLongName = false

    private var profile: Profile {
        Profile(
            name: useLongName ? "Maximilian Alexander von Habsburg" : "Aigerim Bekova",
            subtitle: "iOS Developer · Almaty",
            posts: "128",
            followers: "4.2K",
            following: "312",
            about: "Building banking apps in Swift. I like clean architecture, coffee and long walks in the mountains around Almaty."
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        show(profile)
    }

    private func show(_ profile: Profile) {
        avatarInitialsLabel.text = profile.initials
        nameLabel.text = profile.name
        subtitleLabel.text = profile.subtitle
        postsLabel.text = profile.posts
        followersLabel.text = profile.followers
        followingLabel.text = profile.following
        aboutLabel.text = profile.about
    }
}
