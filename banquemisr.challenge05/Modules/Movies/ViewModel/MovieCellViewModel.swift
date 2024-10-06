//
//  MovieCellViewModel.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/5/24.
//

import Foundation

class MovieCellViewModel {
    // MARK: - Properties
    var coreDataManager: MovieCoreDataServiceProtocol?

    // MARK: - Closures
    var setLoadingImage: () -> Void = {}
    var setNoPosterImage: () -> Void = {}
    var setLoadedImage: (Data) -> Void = {_ in}
    
    // MARK: - Initializer
    init() {
        coreDataManager = MovieCoreDataManager.shared
    }
    
    func formattedVoteAverage(_ voteAverage: Double) -> String {
        return voteAverage != 0.0
            ? "★ " + String(format: "%0.1f", voteAverage)
            : "No Rating Yet"
    }

    func loadImage(for cell: Movie) {
        print(cell)
        let baseImgUrl = "https://image.tmdb.org/t/p/w342"

        guard let posterPath = URL(string: baseImgUrl + cell.posterPath) else {
            print("Error in image cell URL")
            setNoPosterImage()
            return
        }

        setLoadingImage()

        DispatchQueue.global(qos: .background).async { [weak self] in
            if let imageData = try? Data(contentsOf: posterPath) {
                self?.setLoadedImage(imageData)
                DispatchQueue.main.async {
                    self?.coreDataManager?.storeMovieImage(imageData, forMovieWithId: cell.id, imageType: .poster)
                }
            } else {
                self?.setNoPosterImage()
            }
        }
    }
}
