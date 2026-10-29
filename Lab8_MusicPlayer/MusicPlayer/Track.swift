//
//  Track.swift
//  MusicPlayer
//
//  Created by Zhanassyl Rysbek on 29.10.2026.
//

import Foundation

struct Track {
    let title: String
    let artist: String
    let fileName: String
    let coverImageName: String
}

enum TrackLibrary {
    static let tracks: [Track] = [
        Track(title: "Midnight Drive", artist: "Almaty Nights", fileName: "midnight_drive", coverImageName: "midnight_drive"),
        Track(title: "Medeu Ice", artist: "Almaty Nights", fileName: "medeu_ice", coverImageName: "medeu_ice"),
        Track(title: "Kok-Tobe Lights", artist: "Almaty Nights", fileName: "kok_tobe_lights", coverImageName: "kok_tobe_lights"),
        Track(title: "Night Bus", artist: "Almaty Nights", fileName: "night_bus", coverImageName: "night_bus"),
        Track(title: "Steppe Wind", artist: "Almaty Nights", fileName: "steppe_wind", coverImageName: "steppe_wind"),
        Track(title: "Neon Rain", artist: "Almaty Nights", fileName: "neon_rain", coverImageName: "neon_rain"),
        Track(title: "Late Lab", artist: "Almaty Nights", fileName: "late_lab", coverImageName: "late_lab"),
        Track(title: "Shymkent Heat", artist: "Almaty Nights", fileName: "shymkent_heat", coverImageName: "shymkent_heat"),
        Track(title: "Snow Peak", artist: "Almaty Nights", fileName: "snow_peak", coverImageName: "snow_peak"),
        Track(title: "Last Metro", artist: "Almaty Nights", fileName: "last_metro", coverImageName: "last_metro")
    ]
}
