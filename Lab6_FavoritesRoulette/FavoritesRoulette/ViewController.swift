//
//  ViewController.swift
//  FavoritesRoulette
//
//  Created by Zhanassyl Rysbek on 14.10.2026.
//

import UIKit

struct Favorite {
    let imageName: String
    let title: String
    let description: String
}

class ViewController: UIViewController {

    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var spinButton: UIButton!

    private let favorites: [Favorite] = [
        Favorite(imageName: "medeu",
                 title: "Medeu",
                 description: "The famous high-mountain skating rink right above Almaty. Best on a frosty winter evening."),
        Favorite(imageName: "shymbulak",
                 title: "Shymbulak",
                 description: "Ski resort at 2,200 m. Take the gondola from Medeu and catch the view from Talgar Pass."),
        Favorite(imageName: "big_almaty_lake",
                 title: "Big Almaty Lake",
                 description: "A turquoise mountain lake at 2,500 m. Its color changes from green to blue during the day."),
        Favorite(imageName: "charyn_canyon",
                 title: "Charyn Canyon",
                 description: "The Valley of Castles: red rock walls carved by the Charyn river. Perfect for drone shots."),
        Favorite(imageName: "kolsai_lakes",
                 title: "Kolsai Lakes",
                 description: "Three lakes in a spruce forest, called the pearls of the Northern Tien Shan."),
        Favorite(imageName: "kaindy_lake",
                 title: "Kaindy Lake",
                 description: "A lake with a sunken forest: dry spruce trunks still stand straight out of the water."),
        Favorite(imageName: "singing_dune",
                 title: "Singing Dune",
                 description: "A 150-meter dune in Altyn-Emel that hums like an organ when the wind moves the sand."),
        Favorite(imageName: "kok_tobe",
                 title: "Kok-Tobe",
                 description: "The hill with the TV tower and the best night view of the city lights of Almaty."),
        Favorite(imageName: "burabay",
                 title: "Burabay",
                 description: "Lakes, pine forests and granite rocks. Often called the Kazakh Switzerland."),
        Favorite(imageName: "turkistan",
                 title: "Turkistan",
                 description: "Home of the Mausoleum of Khoja Ahmed Yasawi, a UNESCO World Heritage site.")
    ]

    private var currentIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        favoriteImageView.contentMode = .scaleAspectFill
        favoriteImageView.clipsToBounds = true
        titleLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.numberOfLines = 0
        showInitialState()
    }

    private func showInitialState() {
        favoriteImageView.image = UIImage(named: "intro")
        titleLabel.text = "Where should I go next?"
        descriptionLabel.text = "Tap the button and the roulette will pick one of my \(favorites.count) favorite places in Kazakhstan for the next weekend trip."
        spinButton.setTitle("Spin the roulette", for: .normal)
    }

    @IBAction func spinTapped(_ sender: UIButton) {
        let index = randomIndex(excluding: currentIndex)
        currentIndex = index
        show(favorites[index])
        sender.setTitle("Spin again", for: .normal)
    }

    /// Returns a random index that is never the same as the previous one.
    private func randomIndex(excluding previous: Int?) -> Int {
        guard favorites.count > 1 else { return 0 }
        var next = Int.random(in: 0..<favorites.count)
        while next == previous {
            next = Int.random(in: 0..<favorites.count)
        }
        return next
    }

    private func show(_ favorite: Favorite) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve) {
            self.favoriteImageView.image = UIImage(named: favorite.imageName)
            self.titleLabel.text = favorite.title
            self.descriptionLabel.text = favorite.description
        }
    }
}
