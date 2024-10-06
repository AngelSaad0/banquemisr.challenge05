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
    var loadMovieImageUseCase: LoadMovieImageUseCaseProtocol?

    // MARK: - Closures
    var setLoadingImage: () -> Void = {}
    var setNoPosterImage: () -> Void = {}
    var setLoadedImage: (Data) -> Void = {_ in}
    
    // MARK: - Initializer
    init() {
        loadMovieImageUseCase = LoadMovieImageUseCase()
        coreDataManager = MovieCoreDataManager.shared
    }
    
    func formattedVoteAverage(_ voteAverage: Double) -> String {
        return voteAverage != 0.0
            ? "★ " + String(format: "%0.1f", voteAverage)
            : "No Rating Yet"
    }

    func loadImage(for cell: Movie) {
        let baseImgUrl = "https://image.tmdb.org/t/p/w342"
        let posterPath = baseImgUrl + cell.posterPath
        setLoadingImage()

        loadMovieImageUseCase?.execute(imageUrl: posterPath) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let imageData):
                self.setLoadedImage(imageData)
                DispatchQueue.main.async {
                    self.coreDataManager?.storeMovieImage(imageData, forMovieWithId: cell.id, imageType: .poster)
                }
            case .failure:
                self.setNoPosterImage()
            }
        }
    }
}
