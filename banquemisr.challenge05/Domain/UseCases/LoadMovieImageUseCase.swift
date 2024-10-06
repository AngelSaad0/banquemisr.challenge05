//
//  LoadMovieImageUseCase.swift
//  banquemisr.challenge05
//
//  Created by Engy on 06/10/2024.
//

import Foundation

protocol LoadMovieImageUseCaseProtocol {
    func execute(imageUrl: String, completion: @escaping (Result<Data, APIError>) -> Void)
}

class LoadMovieImageUseCase: LoadMovieImageUseCaseProtocol {
    private let repository: MovieRepositoryProtocol

    init() {
        repository = MovieRepository()
    }

    func execute(imageUrl: String, completion: @escaping (Result<Data, APIError>) -> Void) {
        repository.loadImage(from: imageUrl) { data in
            if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(.networkIssue)) // Or other relevant errors
            }
        }
    }
}
