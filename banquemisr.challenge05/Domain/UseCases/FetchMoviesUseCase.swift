//
//  FetchMoviesUseCase.swift
//  banquemisr.challenge05
//
//  Created by Engy on 06/10/2024.
//

import Foundation

protocol FetchMoviesUseCaseProtocol {
    func execute<T: Codable>(from endpoint: MovieAPIProvider, responseType: T.Type, completion: @escaping (Result<T, APIError>) -> Void)
}

class FetchMoviesUseCase: FetchMoviesUseCaseProtocol {
    private let repository: MovieRepositoryProtocol

    init() {
        repository = MovieRepository()
    }

    func execute<T: Codable>(from endpoint: MovieAPIProvider, responseType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        repository.fetchData(from: endpoint, responseType: responseType) { data, error in
            if let error = error as? APIError {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(.emptyResponse))
            }
        }
    }
}
